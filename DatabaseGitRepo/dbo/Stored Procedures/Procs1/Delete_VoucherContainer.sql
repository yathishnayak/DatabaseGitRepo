CREATE PROCEDURE [dbo].[Delete_VoucherContainer]
@VoucherKey		INT = 0,
@OrderDetailKey INT = 0,
@UserKey		INT = 1,
@OutPut			BIT = 0 OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DISTINCT RouteKey INTO #VouchLeg
	FROM dbo.Routes 
	WHERE OrderDetailKey=@OrderDetailKey;

	SELECT VoucherLineKey,RouteKey  INTO #DeleteVouchLine
	FROM dbo.VoucherDetail 
	WHERE Voucherkey=@VoucherKey AND RouteKey IN ( SELECT RouteKey FROM #VouchLeg );

	IF 
	(
		SELECT COUNT(1) FROM VoucherHeader 
		WHERE Voucherkey=@VoucherKey AND ISNULL(IsPaymentApproved,0)=0
	)>0 AND ( SELECT COUNT(1) FROM #DeleteVouchLine)>0
	BEGIN;
		BEGIN TRY;
		BEGIN TRANSACTION;		
			DELETE FROM dbo.RouteVouchers 
			WHERE Voucherkey=@VoucherKey AND RouteKey IN ( SELECT DISTINCT RouteKey FROM #DeleteVouchLine) ;

			DELETE FROM dbo.VoucherDetail WHERE Voucherkey=@VoucherKey AND RouteKey IN (SELECT DISTINCT RouteKey FROM #DeleteVouchLine ) ;
			
			UPDATE dbo.VoucherHeader
			SET VoucherAmount=  ISNULL(( SELECT SUM(ISNULL(ExtCost,0)) FROM dbo.VoucherDetail WHERE VoucherKey= @VoucherKey ),0)
			WHERE VoucherKey= @VoucherKey

			IF ( SELECT COUNT(1) FROM dbo.VoucherDetail WHERE Voucherkey=@VoucherKey)=0
			BEGIN			
				DELETE FROM dbo.VoucherHeader 
				WHERE VoucherKey= @VoucherKey AND ISNULL(VoucherAmount,0)=0	
			END

			SET @OutPut=1;
		COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH;
			ROLLBACK TRANSACTION;
			SET @OutPut=0;
		END CATCH;
	END ;
	ELSE
	BEGIN
		SET @OutPut=0;	
	END;
END;