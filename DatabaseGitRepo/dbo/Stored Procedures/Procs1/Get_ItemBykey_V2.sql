CREATE PROCEDURE [dbo].[Get_ItemBykey_V2]
(
/*
Scheduler Screen
*/

	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '[{"ItemKey": 0}]',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	declare @Itemkey int;
	select @Itemkey = itemkey
	from openjson(@JSONString, '$')
	with (
			Itemkey int '$.ItemKey'
		 )

	--IF(ISNULL(@Itemkey, 0)=0)
	--BEGIN
	--	SET @Status = 0;
	--	SET @Reason = 'Invalid or missing ItemKey in JSON';
	--	RETURN;
	--END

	SELECT 			I.ItemKey, IT.ItemTypeKey, I.ItemID,I.Description, I.UnitCost, IT.Description AS ItemType,	I.CreateDate	
					,IPB.Description 'PriceBasisDescription',
					ST.StatusName, St.StatusKey, IPB.PriceBasisKey, I.InvoiceItemDesc, ECC.Code EDICode, ECC.[Description] AS EDIChargeCodeDesc,
					CI.DriverNonDriverCostDesc AS CostGrpDescription, CI.DriverNonDriverCostKey AS CostGrp, I.InternalCost As InternalCost, CategoryKey
	into			#mainresult
	FROM			dbo.Item I 
	INNER JOIN		dbo.ItemType IT ON I.ItemTypeKey = IT.ItemTypeKey
	INNER JOIN		dbo.[Status] ST ON ST.StatusKey = I.StatusKey
	INNER JOIN		[dbo].[ItemPriceBasis] IPB ON IPB.PriceBasisKey = I.PriceBasisKey 
	LEFT JOIN		EDIChargeCode ECC WITH (NOLOCK) ON ECC.Code=I.EDICode
	LEFT JOIN		DriverNonDriverCostItems CI WITH (NOLOCK) ON CI.DriverNonDriverCostKey=I.CostGrp
	WHERE			i.ItemKey = @ItemKey --.StatusName='Active';	

	SELECT ItemList = (
			SELECT * FROM #mainresult WITH (NOLOCK)
			FOR JSON PATH
		), 
		DropDowns = (SELECT
			ItemTypeList					 =		(SELECT I.ItemTypeKey,I.ItemType,I.Description AS ItemTypeDescription,CreateDate
													FROM dbo.ItemType I
													FOR JSON PATH),
			ItemPriceBasisList				 =		(select PriceBasisKey,	PriceBasisID,	[Description],	StatusKey,	StatusDate,	CreateUserKey,	CreateDate,	CompanyKey
													FROM [dbo].[ItemPriceBasis] nolock
													FOR JSON PATH),
			ItemCategoryList				 =		(SELECT CategoryKey,[Name] CategoryName
													FROM ItemCategory
													FOR JSON PATH), 
			DriverNonDriverCostItemGroupList =		(SELECT DriverNonDriverCostKey,DriverNonDriverCostId,DriverNonDriverCostDesc
													FROM DriverNonDriverCostItems WHERE ISActive=1 AND IsDeleted=0
													FOR JSON PATH),
			StatusList						=		(SELECT [StatusKey],[StatusName],[CompanyKey],[IsActive],[CreateDate],[Type]
													FROM [dbo].[Status]
													FOR JSON PATH),
			EDIChargeCodeList				=		(SELECT Code, [Description] FROM EDIChargeCode
													ORDER BY [Description] ASC
													FOR JSON PATH)										
			FOR JSON PATH
		)
		FOR JSON PATH

		SET @Status = 1
		SET @Reason = 'SUCCESS'
END