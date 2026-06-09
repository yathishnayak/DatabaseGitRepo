/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status bit = 0,@Reason varchar(1000) = '' 
set @JsonString = '{"ShowOnlyMapped":false,"Legkey":3,"Routekey":417741,"ItemType":"Expense"}'
exec Charge_GetItemDetailbyCategory_sumantha @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Charge_GetItemDetailbyCategory] -- Charge_GetItemDetailbyCategory 0, 544
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	--//PRevious Parameters
	--@Legkey			INT=0,
	--@Routekey			INT=384,
	--@ShowOnlyMapped	BIT=0

	DECLARE 
		@Legkey				INT=0,
		@Routekey			INT=384,
		@ShowOnlyMapped		BIT=0,
		@ItemType			VARCHAR(50) = 'Expense'

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	SELECT @Legkey = LegKey, @RouteKey = RouteKey, @ShowOnlyMapped = ShowOnlyMapped, @ItemType = ItemType
	FROM OPENJSON(@JsonString, '$')
	WITH (
		LegKey			INT			'$.LegKey',
		RouteKey		INT			'$.Routekey'	,
		ShowOnlyMapped	BIT			'$.ShowOnlyMapped',
		ItemType		VARCHAR(50)	'$.ItemType'
	)

	IF(ISNULL(@ItemType, '') = '')
	BEGIN
		SET @ItemType = 'Expence'
	END
	SET @Routekey		= ISNULL(@Routekey,0)
	SET @Legkey			= ISNULL(@Legkey,0)
	SET @ShowOnlyMapped = ISNULL(@ShowOnlyMapped,0)
	
	IF(@Routekey <> 0 and @Legkey = 0)
	BEGIN
		SELECT @Legkey = LegKey FROM dbo.Routes WHERE RouteKey = @Routekey
	END

	SELECT		0 RouteKey, 0 LegKey,
				I.ItemKey itemkey,I.ItemTypeKey ,I.ItemID itemid,IC.Name CategoryName,
				'General' FromLocation,'General' ToLocation,isnull(M.Description,I.Description) as description , 
				COALESCE(I.Unitcost,OE.UnitCost,I.UnitCost)  AS unitcost, isnull(OE.Qty,0) as qty,
				 CASE WHEN @ItemType = 'ALL'	THEN REPLACE(TT.Description,'Both Order and Driver Expenses','Driver Expenses') 
					 WHEN @ItemType = 'Expense' THEN REPLACE(TT.Description,'Both Order and Driver Expenses','Driver Expenses') 
					 WHEN @ItemType = 'Service' THEN REPLACE(TT.Description,'Both Order and Driver Expenses','Order Expenses') 
				ELSE '' END AS itemtype
				,PB.Description PriceBasisDescription,
				i.PriceBasisKey,DateFrom WaitDateFrom,DateTo WaitDateTo, 
				M.InvoiceItemDesc,InternalNotes,PvsNP,TimeDuration
	FROM		ITem I WITH (NOLOCK)
	LEFT JOIN	Item M WITH (NOLOCK) on I.MasterItemKey = M.ItemKey
	LEFT JOIN	ItemType TT WITH (NOLOCK) on I.ItemTypeKey = TT.ItemTypeKey
	INNER JOIN	itemcategory IC	WITH (NOLOCK) ON IC.CategoryKey=I.CategoryKey
	INNER JOIN	ItemPriceBasis PB WITH (NOLOCK)  ON I.PriceBasisKey = PB.PriceBasisKey
	LEFT JOIN	OrderExpense OE WITH (NOLOCK)  on I.ItemKey = OE.Itemkey and OE.RouteKey = @Routekey
	LEFT JOIN	Routes RT WITH (NOLOCK) on RT.RouteKey =@Routekey
	LEFT JOIN	LEG L WITH (NOLOCK) on RT.LEgKey = L.LegKey
	WHERE		(@ItemType = 'ALL' OR TT.ItemType like   '%' + @ItemType + '%')
	AND			I.StatusKey = 1 and ic.CategoryKey <> 4 --and I.itemkey not in(5,162)
	ORDER BY	IC.name, isnull(M.Description,I.Description) 
	FOR JSON PATH , INCLUDE_NULL_VALUES

	SET @Status = 1
	SET @Reason = 'SUCCESS'
END
