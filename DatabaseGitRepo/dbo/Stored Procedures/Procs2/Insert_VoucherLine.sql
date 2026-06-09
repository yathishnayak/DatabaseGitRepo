
CREATE PROCEDURE [dbo].[Insert_VoucherLine]
@VoucherKey			INT,
@ItemKey			INT,
@RouteKey			INT=0,
@Qty				DECIMAL(18,4),
@UnitCost           DECIMAL(18,4)=0,
@UserKey			INT,
@Remarks            varchar(2000),
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	DECLARE @ItemDescription VARCHAR(255);

	SET @UnitCost = ( SELECT CASE WHEN ISNULL(@UnitCost,0)=0 THEN UnitCost ELSE @UnitCost END FROM Item WHERE ItemKey= @ItemKey );

	SET @ItemDescription= ( SELECT [Description] FROM Item WHERE ItemKey= @ItemKey )	;
		
	INSERT INTO [dbo].[VoucherDetail]([Voucherkey],[ItemKey],[Description],[UnitCost],[Qty],[ExtCost],RouteKey,Remarks,CreateDate,CreateUserKey)
	VALUES ( @VoucherKey,@ItemKey,@ItemDescription,@UnitCost,@Qty,(@Qty*@UnitCost),@RouteKey, @Remarks,GETDATE(),@UserKey );

	UPDATE dbo.VoucherHeader
	SET VoucherAmount=(  SELECT SUM(ISNULL(ExtCost,0)) FROM dbo.VoucherDetail WHERE VoucherKey=@VoucherKey ),
	UpdateuserKey=@UserKey
	WHERE VoucherKey= @VoucherKey
	
	SET @OutPut=1;
END;
