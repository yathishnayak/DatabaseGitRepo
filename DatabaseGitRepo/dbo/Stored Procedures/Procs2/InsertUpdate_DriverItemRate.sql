
CREATE PROCEDURE [dbo].[InsertUpdate_DriverItemRate]
@DriverRateKey		INT=0,
@DriverKey			INT,
@CityKey			INT,
@ItemKey			INT,
@UnitCost			DECIMAL(18,2),
@EffectiveDate		VARCHAR(10),--DATE,
@UserKey			INT,
@CompanyKey			INT=1,
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE  @_ConvEffectiveDate	DATE
	DECLARE  @_UnitCost		DECIMAL(18,2)
	DECLARE  @_EmailContact		VARCHAR(200)

	SELECT @_ConvEffectiveDate = CONVERT(DATE,@EffectiveDate)

	SET @CityKey=		CASE WHEN @CityKey=0     THEN NULL ELSE @CityKey		END	
	SET @CompanyKey=	CASE WHEN @CompanyKey=0   THEN NULL ELSE @CompanyKey	END
	SET @UserKey=		CASE WHEN @UserKey=0      THEN NULL ELSE @UserKey		END

	IF @ItemKey IS NULL 
	BEGIN
		SET @OutPut=0;
		RETURN ;
	END
	
	IF ISNULL(@DriverRateKey,0)>0
	BEGIN
		SELECT @_UnitCost=@UnitCost
		FROM   DriverLocationItem
		WHERE  DriverRateKey=@DriverRateKey

		IF (  @_UnitCost <> @UnitCost )
		BEGIN
			UPDATE dbo.DriverLocationItem
			SET 
				UnitCost=			@UnitCost,				
				LastUpdateDate=		GETDATE(),
				LastUpdateUserKey=	@UserKey				
			WHERE DriverRateKey=@DriverRateKey
		END
	END
	ELSE
	BEGIN
	  delete  from DriverLocationItem
	  where  isnull(Driverkey,0)= isnull(@DriverKey,0) and ItemKey= @ItemKey and CityKey= @CityKey and EffectiveDate= @_ConvEffectiveDate

	  INSERT INTO dbo.DriverLocationItem( Driverkey,ItemKey,CityKey,UnitCost,EffectiveDate,CreateDate,CreateUserKey,LastUpdateDate,LastUpdateUserKey,CompanyKey) 
	  VALUES (  @DriverKey,@ItemKey,@CityKey,@UnitCost,@_ConvEffectiveDate,GETDATE(),@UserKey,GETDATE(),@UserKey,@CompanyKey) ;	
	END

	SET @OutPut=1;
END;


