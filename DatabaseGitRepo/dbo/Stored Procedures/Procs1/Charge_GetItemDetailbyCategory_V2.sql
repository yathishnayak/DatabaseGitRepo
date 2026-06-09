/*
Declare @UserKey int=951,@JSONString nvarchar(max),@Status bit = 0,@Reason varchar(1000) = '' 
set @JsonString = '{"ShowOnlyMapped":false,"LegKey":0,"Routekey":728769,"ItemType":"Expense"}'
exec [Charge_GetItemDetailbyCategory_V2] @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Charge_GetItemDetailbyCategory_V2] -- Charge_GetItemDetailbyCategory 0, 544
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
		RouteKey		INT			'$.RouteKey'	,
		ShowOnlyMapped	BIT			'$.ShowOnlyMapped',
		ItemType		VARCHAR(50)	'$.ItemType'
	)

	IF(ISNULL(@ItemType, '') = '')
	BEGIN
		SET @ItemType = 'Expense'
	END
	SET @Routekey		= ISNULL(@Routekey,0)
	SET @Legkey			= ISNULL(@Legkey,0)
	SET @ShowOnlyMapped = ISNULL(@ShowOnlyMapped,0)
	
	IF(@Routekey <> 0 and @Legkey = 0)
	BEGIN
		SELECT @Legkey = LegKey FROM dbo.Routes WHERE RouteKey = @Routekey
	END

	SELECT		0 RouteKey, 0 LegKey,
				I.ItemKey ItemKey,I.ItemTypeKey ,I.ItemID ItemId,IC.Name CategoryName,
				'General' FromLocation,'General' ToLocation,isnull(M.Description,I.Description) as Description , 
				COALESCE(OE.UnitCost, I.Unitcost) AS UnitCost, isnull(OE.Qty,0) as Qty,
				 CASE WHEN @ItemType = 'ALL'	THEN REPLACE(TT.Description,'Both Order and Driver Expenses','Driver Expenses') 
					 WHEN @ItemType = 'Expense' THEN REPLACE(TT.Description,'Both Order and Driver Expenses','Driver Expenses') 
					 WHEN @ItemType = 'Service' THEN REPLACE(TT.Description,'Both Order and Driver Expenses','Order Expenses') 
				ELSE '' END AS ItemType
				,PB.Description PriceBasisDescription,
				i.PriceBasisKey,DateFrom WaitDateFrom,DateTo WaitDateTo, 
				M.InvoiceItemDesc,InternalNotes,PvsNP,TimeDuration
	FROM		ITem I WITH (NOLOCK)
	LEFT JOIN	Item M WITH (NOLOCK) on I.MasterItemKey = M.ItemKey
	LEFT JOIN	ItemType TT WITH (NOLOCK) on I.ItemTypeKey = TT.ItemTypeKey
	INNER JOIN	itemcategory IC	WITH (NOLOCK) ON IC.CategoryKey=I.CategoryKey
	INNER JOIN	ItemPriceBasis PB WITH (NOLOCK)  ON I.PriceBasisKey = PB.PriceBasisKey
	LEFT JOIN	OrderExpense OE WITH (NOLOCK)  on I.ItemKey = OE.ItemKey and OE.RouteKey = @Routekey
	LEFT JOIN	Routes RT WITH (NOLOCK) on RT.RouteKey=@RouteKey
	LEFT JOIN	LEG L WITH (NOLOCK) on RT.LEgKey = L.LegKey
	WHERE		(@ItemType = 'ALL' OR TT.ItemType like   '%' + @ItemType + '%')
	AND			I.StatusKey = 1 and ic.CategoryKey <> 4 and I.ItemKey not in(5,162) 
	ORDER BY	IC.name, isnull(M.Description,I.Description) 
	FOR JSON PATH , INCLUDE_NULL_VALUES

	SET @Status = 1
	SET @Reason = 'SUCCESS'
END


--select * from Item where statuskey = 1 and description like '%wait%'