CREATE PROCEDURE [dbo].[Delete_VoucherLine]
@VoucherlineKey	INT,
@VocuherKey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DELETE 
	FROM dbo.VoucherDetail
	WHERE VoucherLineKey = @VoucherlineKey and Voucherkey =@VocuherKey;  

	UPDATE dbo.VoucherHeader
	SET VoucherAmount= ( SELECT SUM(ExtCost) FROM dbo.VoucherDetail WHERE Voucherkey=@VocuherKey )
	WHERE VoucherKey=@VocuherKey;

	SET @OutPut=1;

END
