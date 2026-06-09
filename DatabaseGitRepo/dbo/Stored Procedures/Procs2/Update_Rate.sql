CREATE PROCEDURE [dbo].[Update_Rate]
/*
dbo.fn_update_rate
*/
@RateKey		INT,
@CustomerKey	INT,
@ItemKey		INT,
@UnitPrice		DECIMAL(18,2),
@UserKey		INT,
@OutPut			BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF (SELECT COUNT(1) FROM dbo.RateSheet where RateKey = @Ratekey ) >0
	BEGIN
		UPDATE dbo.RateSheet 
		SET UnitPrice= @UnitPrice ,LastUpdateDate = GETDATE(),LastUpdateUserKey=@UserKey 
		WHERE RateKey = @Ratekey;
	END 
	ELSE
	BEGIN
		INSERT INTO dbo.RateSheet(CustomerKey , ItemKey, UnitPrice,CreateUserKey,CreateDate) 
		VALUES (@CustomerKey,@ItemKey,@UnitPrice,@UserKey,GETDATE()) ;
	END 
	SET @OutPut=1
END
