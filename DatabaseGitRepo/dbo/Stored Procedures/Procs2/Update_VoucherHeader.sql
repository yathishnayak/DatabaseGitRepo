CREATE PROCEDURE [dbo].[Update_VoucherHeader]
@VoucherKey			INT,
@IsPmtApproved		BIT,
@UserKey			INT,
@VoucherDate		DATE,
@DueDate			DATE,
@DriverNote			VARCHAR(300),
@InternalNote		VARCHAR(300),
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @OutPut=0;

	IF ( SELECT COUNT(1) FROM dbo.VoucherHeader WHERE IsPaymentApproved <> ISNULL(@IsPmtApproved,IsPaymentApproved))>0
	BEGIN
		UPDATE dbo.VoucherHeader
		SET IsPaymentApproved= @IsPmtApproved,
		PmtApprovedUser= @UserKey,
		StatusKey= CASE WHEN IsPaymentApproved =1 OR  @IsPmtApproved=1 THEN 2 ELSE 1 END	,
		DriverNote= @DriverNote		,
		InternalNote= @InternalNote	
		WHERE VoucherKey=@VoucherKey;
	END;

		UPDATE dbo.VoucherHeader
		SET VoucherDate=ISNULL(@VoucherDate,VoucherDate) ,DueDate= ISNULL(@DueDate,DueDate),
			UpdateuserKey=@UserKey,UpdateDate=GETDATE(),DriverNote= @DriverNote		,
			InternalNote= @InternalNote	
		WHERE VoucherKey=@VoucherKey;
	
	SET @OutPut=1;

END
