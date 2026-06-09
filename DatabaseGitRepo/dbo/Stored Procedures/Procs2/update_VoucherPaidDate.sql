

CREATE Proc update_VoucherPaidDate
(
	@VoucherKey int,
	@UserKey	INT,
	@PaidDate	DateTime,
	@OutPut		BIT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @OutPut=0;

	Declare @Comment varchar(500) = '',
			@CommentKey int,
			@PrevPaidDate datetime,
			@UserName varchar(100)

	select @PrevPaidDate = PaidDate from VoucherHeader where VoucherKey = @VoucherKey
	Select @UserName = UserName from [User] where UserKey = @UserKey
	
	set @Comment = 'Voucher Paid Date changed from : ' +  convert(varchar,@PrevPaidDate,101) 
		+ '  to ' +  convert(varchar,@PaidDate,101) + ' by ' + @UserName + '<br>'

	UPDATE dbo.VoucherHeader
	SET PaidDate = @PaidDate
	WHERE VoucherKey = @VoucherKey;

	
	update VoucherHeader set InternalNote = isnull(InternalNote,'') +  @Comment where VoucherKey = @VoucherKey


	SET @OutPut=1;
END
