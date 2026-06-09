/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '{}'
	exec Charge_GetWarehouseItemList @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Charge_GetWarehouseItemList] -- Charge_GetWarehouseItemList 0, 544
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	select M.ItemKey, 
		 M.Description as MDescription, M.PriceBasisKey, PB.PriceBasisID, PB.Description as PriceBasis,
		 M.UnitCost, 0.00 as Rate, 0 as FreeTime, 0 as MinTime, 0 as MaxTime,'' as BvsNB, TI.Name as Category
	from Item M 
	Left join ItemPriceBasis PB WITH (NOLOCK) on M.PriceBasisKey = PB.PriceBasisKey
	LEft join ItemCategory TI  WITH (NOLOCK) on M.CategoryKey = TI.CategoryKey
	where M.itemkey = M.MasterItemKey and M.StatusKey= 1 and M.CategoryKey = 4 -- Warehouse Group items only
	order by M.Description
	for JSON PATH, INCLUDE_NULL_VALUES
	
	set @Status = 1
	set @Reason = 'SUCCESS'
END