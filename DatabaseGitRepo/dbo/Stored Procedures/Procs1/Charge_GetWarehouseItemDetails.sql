/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '{"OrderDetailKey":107798}'
	exec Charge_GetWarehouseItemDetails @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Charge_GetWarehouseItemDetails] -- Charge_GetWarehouseItemDetails 0, 544
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


	Declare 
		@OrderDetailKey				INT=0

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select @OrderDetailKey = OrderDetailKey
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey			int			'$.OrderDetailKey'
	)

	select OD.OrderDetailKey, WC.WarehouseItemKey, WC.ItemKey, WC.Qty, WC.Rate, WC.TimeDuration, WC.ExtAmt, WC.BvsNB,
		 WC.CreateUserKey, WC.CreateDate, WC.UpdateUserKey, WC.UpdateDate,
		 M.Description as MDescription, M.PriceBasisKey, PB.PriceBasisID, PB.Description as PriceBasis,
		 UC.UserName as CreateUserName, UU.UserName as UpdateUserName,
		 Invoiced = Case when isnull(ID.InvoiceKey,0) > 0 then 1 else 0 end
	from OrderDetail OD  WITH (NOLOCK)
	LEft join Warehouse_Charges WC  WITH (NOLOCK) on OD.OrderDetailKey = WC.OrderDetailKey
	LEft join Item M WITH (NOLOCK) on WC.ItemKey = M.ItemKey
	Left join ItemPriceBasis PB WITH (NOLOCK) on M.PriceBasisKey = PB.PriceBasisKey
	Left join [User] UC WITH (NOLOCK) on WC.CreateUserKey = UC.UserKey
	Left join [User] UU WITH (NOLOCK) on WC.CreateUserKey = UU.UserKey
	LEft join InvoiceContainers IC WITH (NOLOCK) on OD.OrderDetailKey = IC.OrderDetailsKey
	LEFT join Invoicedetail ID WITH (NOLOCK) on IC.InvoiceKey = ID.InvoiceKey and ID.ItemKey = WC.ItemKey
	where OD.OrderDetailKey = @OrderDetailKey
	for JSON PATH, INCLUDE_NULL_VALUES
	
	set @Status = 1
	set @Reason = 'SUCCESS'
END