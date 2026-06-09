--select top 100 * from orderdetail order by  orderdetailkey desc

/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '', @IsDebug bit = 1
set @JsonString = '{"OrderDetailKey":131659}'
exec Scheduler_GetTMFCTFdata @UserKey, @JSONString, @Status output, @Reason output
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Scheduler_GetTMFCTFdata]   
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
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

	Declare @OrderDetailKey		int = 0

	Select @OrderDetailKey = OrderDetailKey
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey				int	'$.OrderDetailKey'
	)

	if(isnull(@OrderDetailKey,0) = 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'OrderDetailKey not found'
		return
	End

	Select OD.OrderDetailKey, 
		ISNULL(OD.TMFCheckOff, 0 ) as TMFCheckOff,
		ISNULL(OD.IsTMFJCTPaid,0) as IsTMFJCTPaid,
		ISNULL(OD.IsTMFCustomerPaid,0) as IsTMFCustomerPaid,
		ISNULL(OD.CTFCheckOff, 0) as CTFCheckOff,
		ISNULL(OD.IsCTFJCTPaid,0) as IsCTFJCTPaid,
		ISNULL(OD.IsCTFCustomerPaid,0) as IsCTFCustomerPaid
	from OrderDetail OD WITH (NOLOCK) 
	where OrderDetailKey = @OrderDetailKey
	FOR JSON PATH, Without_array_wrapper
	SET @Status = 1
	SET @Reason = 'SUCCESS'
END
