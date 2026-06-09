CREATE PROCEDURE [dbo].[Get_ItemDetail_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '[{"StatusKey": "1:2:3", "DriverNonDriverCostKey": "3:5:6:7", "PriceBasisKey": 1, "CategoryKey": "3:8", "ItemTypeKey": "1:4:5"}]',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	declare
	@StatusKey					VARCHAR(50),
	@PriceBasisKey				VARCHAR(50),
	@DriverNonDriverCostKey		VARCHAR(50),
	@CategoryKey				VARCHAR(50),
	@ItemTypeKey				VARCHAR(50)

	SELECT @StatusKey = StatusKey, @PriceBasisKey = PriceBasisKey, @DriverNonDriverCostKey = DriverNonDriverCostKey, @CategoryKey = CategoryKey, @ItemTypeKey = ItemTypeKey
	from openjson(@JSONString, '$')
	with (
			StatusKey					VARCHAR(50)				'$.StatusKey',
			PriceBasisKey				VARCHAR(50)				'$.PriceBasisKey',
			DriverNonDriverCostKey		VARCHAR(50)				'$.DriverNonDriverCostKey',
			CategoryKey					VARCHAR(50) 			'$.CategoryKey',
			ItemTypeKey					VARCHAR(50) 			'$.ItemTypeKey'
		 )

	create table #StatusKeys				(StatusKey					int)
	create table #PriceBasisKeys			(PriceBasisKey				int)
	create table #DriverNonDriverCostKeys	(DriverNonDriverCostKey		int)
	create table #CategoryKeys				(CategoryKey				int)
	create table #ItemTypeKeys				(ItemTypeKey				int)

		IF(ISNULL(@StatusKey,'') <> '')
		BEGIN
			INSERT INTO	#StatusKeys(StatusKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@StatusKey)
		END

		IF(ISNULL(@PriceBasisKey,'') <> '')
		BEGIN
			INSERT INTO	#PriceBasisKeys(PriceBasisKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@PriceBasisKey)
		END

		IF(ISNULL(@DriverNonDriverCostKey,'') <> '')
		BEGIN
			INSERT INTO	#DriverNonDriverCostKeys(DriverNonDriverCostKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@DriverNonDriverCostKey)
		END

		IF(ISNULL(@CategoryKey,'') <> '')
		BEGIN
			INSERT INTO	#CategoryKeys(CategoryKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@CategoryKey)
		END


		IF(ISNULL(@ItemTypeKey,'') <> '')
		BEGIN
			INSERT INTO	#ItemTypeKeys(ItemTypeKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@ItemTypeKey)
		END

		IF (@IsDebug = 1)
		BEGIN
			SELECT * FROM #StatusKeys
			SELECT * FROM #PriceBasisKeys 
		END

	SELECT 			I.ItemKey AS ItemKey,IT.ItemTypeKey,I.ItemID as ItemID,I.Description AS Description,I.UnitCost as UnitCost, 
					IT.Description AS ItemType,I.CreateDate	,IPB.Description 'PriceBasisDescription',ST.StatusName,
					IPB.PriceBasisKey, I.InvoiceItemDesc, ECC.Code AS EDICode,ECC.[Description] AS EDIChargeCodeDesc,
					CI.DriverNonDriverCostDesc AS CostGrpDescription, CI.DriverNonDriverCostKey AS CostGrp, I.InternalCost As InternalCost, IC.Name AS CategoryName
	into			#mainlist
	FROM			dbo.Item I 
	INNER JOIN		dbo.ItemType IT ON I.ItemTypeKey = IT.ItemTypeKey
	INNER JOIN		dbo.[Status] ST ON ST.StatusKey = I.StatusKey
	LEFT JOIN		[dbo].[ItemPriceBasis] IPB ON IPB.PriceBasisKey = I.PriceBasisKey 
	LEFT JOIN		EDIChargeCode ECC WITH (NOLOCK) ON ECC.Code=I.EDICode
	LEFT JOIN		DriverNonDriverCostItems CI WITH (NOLOCK) ON CI.DriverNonDriverCostKey=I.CostGrp
	LEFT JOIN		ItemCategory IC WITH (NOLOCK) ON IC.CategoryKey = I.CategoryKey
	WHERE			(ISNULL(@StatusKey, '') = '' OR ST.StatusKey IN (SELECT StatusKey FROM #StatusKeys))
					AND   (ISNULL(@PriceBasisKey, '') = '' OR IPB.PriceBasisKey IN (SELECT PriceBasisKey FROM #PriceBasisKeys))
					AND   (ISNULL(@DriverNonDriverCostKey, '') = '' OR CI.DriverNonDriverCostKey IN (SELECT DriverNonDriverCostKey FROM #DriverNonDriverCostKeys))
					AND   (ISNULL(@CategoryKey, '') = '' OR IC.CategoryKey IN (SELECT CategoryKey FROM #CategoryKeys))
					AND   (ISNULL(@ItemTypeKey, '') = '' OR I.ItemTypeKey IN (SELECT ItemTypeKey FROM #ItemTypeKeys))
	--WHERE ST.StatusName='Active';	

	IF (@IsDebug = 1)
		BEGIN
			SELECT * FROM #mainlist
		END

	SELECT	ItemList = (
			SELECT * FROM #mainlist WITH (NOLOCK)
			FOR JSON PATH
		), 
		DropDowns = (SELECT
			ItemTypeList					 =	(SELECT I.ItemTypeKey,I.ItemType,I.Description AS ItemTypeDescription,CreateDate
												FROM	dbo.ItemType I WITH (NOLOCK)
												FOR JSON PATH),
			ItemPriceBasisList				 =	(select PriceBasisKey,	PriceBasisID,	[Description],	StatusKey,	StatusDate,	CreateUserKey,	CreateDate,	CompanyKey
												FROM	[dbo].[ItemPriceBasis] WITH (NOLOCK)
												FOR JSON PATH),
			ItemCategoryList				 =	(SELECT CategoryKey,[Name] CategoryName
												FROM	ItemCategory WITH (NOLOCK)
												FOR JSON PATH), 
			DriverNonDriverCostItemGroupList =	(SELECT DriverNonDriverCostKey,DriverNonDriverCostId,DriverNonDriverCostDesc
												FROM	DriverNonDriverCostItems WITH (NOLOCK) WHERE ISActive=1 AND IsDeleted=0
												FOR JSON PATH),
			StatusList						=	(SELECT [StatusKey],[StatusName],[CompanyKey],[IsActive],[CreateDate],[Type]
												FROM [dbo].[Status]
												FOR JSON PATH)
													
			FOR JSON PATH
		)
	 FOR JSON PATH

		SET @Status = 1
		SET @Reason = 'Success'
END
