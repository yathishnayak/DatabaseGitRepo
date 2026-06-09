CREATE Procedure [dbo].[Update_VoucherDetail]
@VoucherKey			INT,
@VoucherLineKey		INT,
@Qty				DECIMAL(18,4),
@UnitCost			DECIMAL(18,4),
@UserKey			INT,
@Remarks            varchar(2000),
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	
	SET @OutPut=0;

		UPDATE dbo.VoucherDetail
		SET Qty= @Qty,UnitCost= @UnitCost,ExtCost= (@Qty*@UnitCost) , Remarks = @Remarks ,UpdateUserKey= @UserKey,UpdateDate= GETDATE()
		WHERE VoucherKey=@VoucherKey AND VoucherLineKey= @VoucherLineKey;

		UPDATE dbo.VoucherHeader
		SET VoucherAmount= ( SELECT SUM((ExtCost)) FROM dbo.VoucherDetail WHERE VoucherKey=@VoucherKey ),
		UpdateuserKey=@UserKey
		WHERE VoucherKey= @VoucherKey;

	SET @OutPut=1;
END;
