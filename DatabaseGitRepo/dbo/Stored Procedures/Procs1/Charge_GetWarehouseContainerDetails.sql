/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '{"OrderDetailKey":107798}'
	exec Charge_GetWarehouseContainerDetails @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Charge_GetWarehouseContainerDetails] -- Charge_GetWarehouseContainerDetails 0, 544
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

	select OD.OrderDetailKey, WCD.ContainerMode, WCD.PalletCount, WCD.ContainerSize, WCD.InDate,
		 WCD.OutDate, ISNULL(WCD.IsNoOutDate,0) IsNoOutDate,GetDate() as TodaysDate, 
		 Case when WCD.InDate is null then 0
			else Case when WCD.OutDate is null then DateDiff(D,WCD.InDate, GETDATE())
				else DateDiff(D,WCD.InDate, WCD.OutDate) end
			end as StorageDays, 
		WCD.IsStoring, WCD.StatusKey,
		 WCD.CreateUserKey, WCD.CreateDate, WCD.UpdateUserKey, WCD.UpdateDate,
		 UC.UserName as CreateUserName, UU.UserName as UpdateUserName,
		 CS.Description as ContainerSizeText,
		 CS.WarehouseSizeMap as ContainerSizeNum,
		 TotalAmount = isnull( WC.TotalAmount,0)
	from OrderDetail OD  WITH (NOLOCK)
	LEft join ContainerSize CS WITH (NOLOCK) on OD.ContainerSizeKey = CS.ContainerSizeKey
	left join Warehouse_ContainerDetails WCD  WITH (NOLOCK) on OD.OrderDetailKey = WCD.OrderDetailKey
	Left join [User] UC WITH (NOLOCK) on WCD.CreateUserKey = UC.UserKey
	Left join [User] UU WITH (NOLOCK) on WCD.CreateUserKey = UU.UserKey
	Left join (Select OrderDetailKey , sum(ExtAmt) TotalAmount from Warehouse_Charges WITH (NOLOCK) 
			group by OrderDetailKey) WC On OD.OrderDetailKey = WC.OrderDetailKey
	where OD.OrderDetailKey = @OrderDetailKey
	for JSON PATH, INCLUDE_NULL_VALUES
	
	set @Status = 1
	set @Reason = 'SUCCESS'
END