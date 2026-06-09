CREATE PROCEDURE [dbo].[Update_CustomerBaseRate]
@CustKey	INT,
@BaseRate	DECIMAL(18,2),
@EffectiveDate	DATETIME ,
@UserKey		INT,
@OutPut			BIT OUTPUT
As
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	SET @EffectiveDate= CASE WHEN @EffectiveDate IS NULL THEN GETDATE() ELSE @EffectiveDate END

	IF ( SELECT COUNT(1) FROM CustomerBaseRate WHERE  Custkey=@CustKey) >0
	BEGIN
		UPDATE CustomerBaseRate
		SET IsActive=0
		WHERE Custkey=@CustKey AND IsActive<>0
	END

	INSERT INTO CustomerBaseRate ( Custkey,BaseRate,EffectiveDate,IsActive,CreateDate,CreateUserkey) 
	VALUES ( @CustKey,@BaseRate,@EffectiveDate,1,GETDATE(),@UserKey)

	SET @OutPut=1;
END
