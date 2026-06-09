CREATE PROCEDURE [dbo].[Update_PaidVoucher]
/*
Voucher Screen
*/
@VoucherKey INT,
@Output BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @Output=0;

	UPDATE dbo.VoucherHeader
	SET isPaid=1
	WHERE VoucherKey=@VoucherKey

	SET @Output=1;
END
