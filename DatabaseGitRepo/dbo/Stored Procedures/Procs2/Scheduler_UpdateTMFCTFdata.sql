/*
Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '', @IsDebug bit = 1
set @JsonString = '{"OrderDetailKey":131659,"TMFCheckOff":true,"IsTMFJCTPaid":false,"IsTMFCustomerPaid":true,"CTFCheckOff":true,"IsCTFJCTPaid":false,"IsCTFCustomerPaid":true}'
exec Scheduler_UpdateTMFCTFdata @UserKey, @JSONString, @Status output, @Reason output, @IsDebug
select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Scheduler_UpdateTMFCTFdata]   
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

	Declare @OrderDetailKey				int = 0,
			@TMFCheckOff				bit = 0,
			@CTFCheckOff				bit = 0,
			@IsTMFJCTPaid				bit = 0,
			@IsTMFCustomerPaid			bit = 0,
			@IsCTFJCTPaid				bit = 0,
			@IsCTFCustomerPaid			bit = 0,
			@SizeCheckOff				bit = 0,
			@PTTChecked					bit = 0

	Select @OrderDetailKey		= OrderDetailKey,
			@TMFCheckOff		= TMFCheckOff,
			@CTFCheckOff		= CTFCheckOff,
			@IsTMFJCTPaid		= IsTMFJCTPaid,
			@IsTMFCustomerPaid	= IsTMFCustomerPaid,
			@IsCTFJCTPaid		= IsCTFJCTPaid,
			@IsCTFCustomerPaid	= IsCTFCustomerPaid,
			@SizeCheckOff		= SizeCheckOff,
			@PTTChecked		    = PTTChecked
	from OpenJSON(@JsonString, '$')
	WITH (
		OrderDetailKey				int	'$.OrderDetailKey',
		TMFCheckOff					bit '$.TMFCheckOff',
		CTFCheckOff					bit '$.CTFCheckOff',
		IsTMFJCTPaid				bit '$.IsTMFJCTPaid',
		IsTMFCustomerPaid			bit '$.IsTMFCustomerPaid',
		IsCTFJCTPaid				bit '$.IsCTFJCTPaid',
		IsCTFCustomerPaid			bit '$.IsCTFCustomerPaid',
		SizeCheckOff				bit '$.SizeCheckOff',
		PTTChecked					bit '$.PTTChecked'
	)

	if(isnull(@OrderDetailKey,0) = 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'OrderDetailKey not found'
		return
	End

	Declare @IsChanged		bit = 0,
			@Msg			varchar(max),
			@UserName		varchar(100),
			@ContainerNo	varchar(20)

	Select @ContainerNo = ContainerNo,
		@IsChanged = Case when 
			ISNULL(TMFCheckOff,0)		<> ISNULL(@TMFCheckOff,0)		OR
			ISNULL(CTFCheckOff,0)		<> ISNULL(@CTFCheckOff,0)		OR
			ISNULL(IsTMFJCTPaid,0)		<> ISNULL(@IsTMFJCTPaid,0)		OR
			ISNULL(IsTMFCustomerPaid,0) <> ISNULL(@IsTMFCustomerPaid,0) OR
			ISNULL(IsCTFJCTPaid,0)		<> ISNULL(@IsCTFJCTPaid,0)		OR
			ISNULL(IsCTFCustomerPaid,0) <> ISNULL(@IsCTFCustomerPaid,0) OR
			ISNULL(SizeCheckOff,0)      <> ISNULL(@SizeCheckOff,0)      OR
			ISNULL(PTTChecked,0)		<> ISNULL(PTTChecked,0)
			Then 1 else 0 end,
		@Msg =	Case when ISNULL(TMFCheckOff,0)		<> ISNULL(@TMFCheckOff,0) then
					'TMF ' + Case when ISNULL(TMFCheckOff,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end +
				Case when ISNULL(IsTMFJCTPaid,0)	<> ISNULL(@IsTMFJCTPaid,0) then
					'TMF - JCT Paid ' + Case when ISNULL(IsTMFJCTPaid,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end +
				Case when ISNULL(IsTMFCustomerPaid,0)	<> ISNULL(@IsTMFCustomerPaid,0) then
					'TMF - Customer Paid ' + Case when ISNULL(IsTMFCustomerPaid,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end +
				Case when ISNULL(CTFCheckOff,0)	<> ISNULL(@CTFCheckOff,0) then
					'CTF ' + Case when ISNULL(CTFCheckOff,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end +
				Case when ISNULL(IsCTFJCTPaid,0)	<> ISNULL(@IsCTFJCTPaid,0) then
					'CTF - JCT Paid ' + Case when ISNULL(IsCTFJCTPaid,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end +
				Case when ISNULL(IsCTFCustomerPaid,0)	<> ISNULL(@IsCTFCustomerPaid,0) then
					'CTF - Customer Paid ' + Case when ISNULL(IsCTFCustomerPaid,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end +
				Case when ISNULL(SizeCheckOff,0)	<> ISNULL(@SizeCheckOff,0) then
					'Size CheckOff ' + Case when ISNULL(SizeCheckOff,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end +
				Case when ISNULL(PTTChecked,0)	<> ISNULL(@PTTChecked,0) then
					'PTT ' + Case when ISNULL(PTTChecked,0) = 0 then 'Ticked' else 'Unticked' end + ', ' else '' end
	From OrderDetail WITH(NOLOCK)
	where OrderDetailKey = @OrderDetailKey

	if(@IsDebug = 1)
	Begin
		Select	@OrderDetailKey as OrderDetailKey,
				ISNULL(@TMFCheckOff,0)	as 	TMFCheckOff,
				ISNULL(@CTFCheckOff,0)	as  CTFCheckOff,
				ISNULL(@IsTMFJCTPaid,0)	as  IsTMFJCTPaid,	
				ISNULL(@IsTMFCustomerPaid,0) as IsTMFCustomerPaid,
				ISNULL(@IsCTFJCTPaid,0)	as IsCTFJCTPaid,
				ISNULL(@IsCTFCustomerPaid,0) as IsCTFCustomerPaid,
				ISNULL(@PTTChecked,0) as PTTChecked,
				@IsChanged as IsChanged,
				@Msg as AuditText,
				@ContainerNo as ContainerNo
	end
	update OrderDetail SET
		TMFCheckOff = @TMFCheckOff,
		CTFCheckOff = @CTFCheckOff,
		IsTMFJCTPaid = @IsTMFJCTPaid,
		IsTMFCustomerPaid = @IsTMFCustomerPaid,
		IsCTFJCTPaid = @IsCTFJCTPaid,
		IsCTFCustomerPaid = @IsCTFCustomerPaid,
		TMFMarkDate = case when Isnull(@IsTMFJCTPaid,0) = 1 then GetDate() else null end,
		CTFMarkDate = Case when Isnull(@IsCTFJCTPaid,0) = 1 then GETDATE() else null end,
		SizeCheckOff = @SizeCheckOff,
		PTTChecked = @PTTChecked,
		PTTCheckedBy= @Userkey,
		PTTCheckedDate = getdate()
	where	OrderDetailKey = @OrderDetailKey and (
			ISNULL(TMFCheckOff,0)		<> ISNULL(@TMFCheckOff,0) OR
			ISNULL(CTFCheckOff,0)		<> ISNULL(@CTFCheckOff,0) OR
			ISNULL(IsTMFJCTPaid,0)		<> ISNULL(@IsTMFJCTPaid,0) OR
			ISNULL(IsTMFCustomerPaid,0) <> ISNULL(@IsTMFCustomerPaid,0) OR
			ISNULL(IsCTFJCTPaid,0)		<> ISNULL(@IsCTFJCTPaid,0) OR
			ISNULL(IsCTFCustomerPaid,0) <> ISNULL(@IsCTFCustomerPaid,0) OR
			ISNULL(SizeCheckOff,0)		<> ISNULL(@SizeCheckOff,0) OR
			ISNULL(PTTChecked,0)		<> ISNULL(@PTTChecked,0)
			)

	Select @UserName = UserName from [User] WITH(NOLOCK) where userkey = @UserKey 

	if(Isnull(@IsChanged,0) = 1)
	Begin
		insert into AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey,  CommentType, Comments)
		Select Getdate(), @UserName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', @Msg
	End

	EXEC Auto_ChargeTMFCTF @OrderDetailkey

	SET @Status = 1
	SET @Reason = 'SUCCESS'
END