/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"OrderDetailKey":131152}'
exec Charge_ConfirmChargesAsComplete @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Charge_ConfirmChargesAsComplete]   
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

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	DECLARE
		@OrderDetailKey		int,
		@ContainerNo		varchar(20)

	update OE SET OrderDetailKey = Rt.OrderDetailKey
	from ORderExpense OE
	inner join Routes RT WITH (NOLOCK) on OE.RouteKey = RT.RouteKey
	where OE.OrderDetailKey is null

	Select @OrderDetailKey = OrderDetailKey
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey		int				'$.OrderDetailKey'
	)
	print @OrderDetailKey

	declare @PendingCount	int = 0
	select @PendingCount =count(1) from OrderExpense  OE
	LEFT JOIN ITEM IT WITH (NOLOCK) ON OE.Itemkey = IT.ItemKey
	LEFT JOIN ITEM IM WITH (NOLOCK) ON IT.MasterItemKey = IM.ItemKey
	LEFT JOIN ITEMTYPE TT WITH (NOLOCK) ON IM.ItemTypeKey = TT.ItemTypeKey
	where OE.orderdetailkey = @OrderDetailKey and ( isnull(IsCSRApproved,0) = 0 OR  Isnull(IsChargeSharedWithCustomer,0) = 0) AND TT.ItemType='Service' 

	if(@PendingCount > 0)
	Begin
			SET @Status = 0
			set @Reason = 'Pending CSR Approve / Customer Notify'
			Return
	End

	Update OE SET
		IsCustomerApprovedCharge = 1,
		CustomerApprovedChargeBy = @UserKey,
		CustomerApprovedChargeDate = Getdate()
	From OrderExpense OE
	where OE.OrderDetailKey = @OrderDetailKey and isnull(IsCustomerApprovedCharge,0) = 0

	Update OD SET
		isCustApprovedCharges = 1,
		isCSChargeConfirmed = 1,
		CSChargeConfirmedBy = @UserKey,
		CSChargeConfirmedDate = GetDate()
	From OrderDetail OD
	Where OrderDetailKey = @OrderDetailKey

	Select @ContainerNo = ContainerNo from ORderDetail where OrderDetailKey = @OrderDetailKey

	insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType,Comments)
	SElect Getdate(),  U.UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', 'CS -Charges Approved by Customer'
	from [User]  U
	where UserKey = @UserKey
	
	set @Status = 1
	set @Reason = 'SUCCESS'

END