CREATE PROCEDURE [dbo].[Delete_Voucher]
@VoucherKey	INT  = 0,
@UserKey	 INT = 1,
@OutPut		 BIT = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF 
	(
		SELECT COUNT(1) FROM VoucherHeader 
		WHERE Voucherkey=@VoucherKey AND ISNULL(IsPaymentApproved,0)=0
	)>0
	BEGIN
		BEGIN TRY
		BEGIN TRANSACTION
			SELECT RouteKey INTO #VouDtlRoute
			FROM VoucherDetail 
			WHERE Voucherkey=@VoucherKey;

			DELETE FROM dbo.RouteVouchers WHERE Voucherkey=@VoucherKey;
			DELETE FROM dbo.VoucherDetail WHERE RouteKey IN ( SELECT RouteKey FROM #VouDtlRoute ) ;
			DELETE FROM dbo.VoucherHeader WHERE Voucherkey=@VoucherKey;
			SET @OutPut=1;
		COMMIT TRANSACTION
		END TRY
		BEGIN CATCH;
			ROLLBACK TRANSACTION
			SET @OutPut=0
		END CATCH
	END ;
	ELSE
	BEGIN
		SET @OutPut=0;
	END;
END;