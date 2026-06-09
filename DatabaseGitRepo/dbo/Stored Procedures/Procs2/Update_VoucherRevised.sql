CREATE Procedure [dbo].[Update_VoucherRevised]
@voucherKey INT,
@UserKey	INT,
@Output		BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE 
			@UserName	varchar(50)

	select top 1 @UserName = isnull(UserName,'') from [User] where UserKey = @UserKey

	SET @Output=0;

	UPDATE dbo.VoucherHeader
	SET StatusKey = 1, IsPaymentApproved=0, RevisionDate = GETDATE(), RevisionUserKey = @UserKey, IsRevised = 1 -- is payment approved condition added by SS-7/20
	WHERE StatusKey in (2,3) and VoucherKey = @voucherKey;

	update VoucherHeader set InternalNote = isnull(InternalNote,'') + 'voucher Revised by ' + @UserName + ' on ' 
			+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; ' + '<br>' 
			+ case when isnull(IsPaid,0) = 1 then '[Revised after Paid]' else '' end
			where VoucherKey = @voucherKey
	
	SET @Output=1;
END
