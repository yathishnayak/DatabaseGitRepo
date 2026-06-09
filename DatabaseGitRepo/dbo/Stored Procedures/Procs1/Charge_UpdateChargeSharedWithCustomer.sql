/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
set @JsonString = '{"OrderDetailKey":127574,"ItemKeys":[{"ItemKey":-1}]}}'
exec Charge_UpdateChargeSharedWithCustomer @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Charge_UpdateChargeSharedWithCustomer]   
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
		@ItemKeys			nvarchar(max),
		@ContainerNo		varchar(20)

	update OE SET OrderDetailKey = Rt.OrderDetailKey
	from ORderExpense OE
	inner join Routes RT WITH (NOLOCK) on OE.RouteKey = RT.RouteKey
	where OE.OrderDetailKey is null

	Select @OrderDetailKey = OrderDetailKey, @ItemKeys = ItemKeys
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey		int				'$.OrderDetailKey',
		ItemKeys			nvarchar(max)	'$.ItemKeys' as JSON
	)
	print @OrderDetailKey
	--select @ItemKeys

	if(isnull(ltrim(rtrim(@ItemKeys)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Item details missing'
		return
	End

	Create table #Items
	(
		ItemKey		int
	)

	insert into #Items (ItemKey)
	Select ItemKey
	from OpenJSON(@Itemkeys, '$')
	WITH (
		ItemKey			int	'$.ItemKey'
	)
	--select * from #Items

	if((select count(1) from #Items where itemkey = -1) > 0)
	Begin
		delete from #Items where itemkey = -1
		insert into #Items (ItemKey)
		Select itemkey from OrderExpense
		where OrderDetailKey = @OrderDetailKey
	End

	if((Select count(1) from #Items) = 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'Item details missing'
		return
	end

	declare @MissingItems int = 0
	select @MissingItems = count(1) 
	from #Items I
	Left join OrderExpense OE on I.ItemKey = OE.Itemkey and OE.OrderDetailKey = @OrderDetailKey
	where OE.itemkey is null 

	if(@MissingItems > 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'Some items not saved yet. Update Charges first.'
		return
	End

	Declare @NotApprovedCount int = 0
	select @NotApprovedCount =Count(1)
	from OrderExpense OE
	inner join #Items I on OE.itemKey = I.ItemKey
	where OE.OrderDetailKey = @OrderDetailKey and isnull(IsCSRApproved,0) = 0

	if(@NotApprovedCount > 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'Some items Not Approved by CSR.'
		return
	End

	Update OE SET
		IsChargeSharedWithCustomer = 1,
		ChargeSharedWithCustBy = @UserKey,
		ChargeSharedWithCustDate = Getdate()
	From OrderExpense OE
	Inner join #Items I on OE.Itemkey = I.ItemKey
	where OE.OrderDetailKey = @OrderDetailKey and isnull(IsChargeSharedWithCustomer,0) = 0

	Update OD SET
		isChargesSharedWithCust = 1,
		ChargeSharedWithCustBy = @UserKey,
		ChargeSharedWithCustDate = Getdate()
	From OrderDetail OD
	Where OrderDetailKey = @OrderDetailKey

	Select @ContainerNo = ContainerNo from ORderDetail where OrderDetailKey = @OrderDetailKey

	insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType,Comments)
	SElect Getdate(),  U.UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', 'CS -Charges shared with Customer'
	from [User]  U
	where UserKey = @UserKey
	
	drop table #Items
	set @Status = 1
	set @Reason = 'SUCCESS'

END