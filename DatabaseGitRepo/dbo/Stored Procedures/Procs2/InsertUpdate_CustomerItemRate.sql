CREATE PROCEDURE [dbo].[InsertUpdate_CustomerItemRate]
@Baseratekey		INT=0,
@BrokerKey			INT,
@Customerkey		INT,
@CityKey			INT,
@ItemKey			INT,
@UnitPrice			DECIMAL(18,2),
@EmailAddress		VARCHAR(200),
@Zip				VARCHAR(50),
@EffectiveDate		varchar(10),--DATE,
@UserKey			INT,
@CompnayKey			INT=1,
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	Declare  @ConvEffectiveDate Date
	DECLARE  @_ClientOrBrokerKey INT
	DECLARE  @_UnitPrice		 DECIMAL(18,2)
	DECLARE  @_EmailContact		 VARCHAR(200)

	SELECT @ConvEffectiveDate = CONVERT(DATE,@EffectiveDate)
	SET @BrokerKey=		CASE WHEN @BrokerKey=0     THEN NULL ELSE @BrokerKey    END
	SET @Customerkey=	CASE WHEN @Customerkey=0   THEN NULL ELSE @Customerkey  END
	SET @CompnayKey=	CASE WHEN @CompnayKey=0    THEN NULL ELSE @CompnayKey   END
	SET @UserKey=		CASE WHEN @UserKey=0       THEN NULL ELSE @UserKey      END
	SET @ItemKey=		CASE WHEN @ItemKey=0       THEN NULL ELSE @ItemKey      END
	SET @EmailAddress=	CASE WHEN @EmailAddress='' THEN NULL ELSE @EmailAddress END

	IF @ItemKey IS NULL 
	BEGIN
		SET @OutPut=0;
		RETURN ;
	END
	--IF ( SELECT COUNT(1) FROM dbo.BaseRate WHERE CustomerKey=@Customerkey AND Itemkey=@ItemKey AND BaseRateKey=@Baseratekey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )>0
	IF ISNULL(@Baseratekey,0)>0
	BEGIN
		SELECT @_ClientOrBrokerKey=ClientOrBrokerKey,
			   @_UnitPrice=UnitPrice,@_EmailContact=EmailContact 
		FROM   CustomerItemRate 
		WHERE  BaseRateKey=@Baseratekey

		IF ( @_ClientOrBrokerKey <> @BrokerKey OR @_UnitPrice <> @UnitPrice OR @_EmailContact <> @EmailAddress )
		BEGIN
			UPDATE 
			dbo.CustomerItemRate
			SET ClientOrBrokerKey=  @BrokerKey,
				UnitPrice=			@UnitPrice,
				EmailContact=		@EmailAddress,
				LastUpdateDate=		GETDATE(),
				LastUpdateUserKey=	@UserKey,			
				CompanyKey=			@CompnayKey
			WHERE BaseRateKey=@Baseratekey --CustomerKey=@Customerkey AND CityKey= @CityKey AND BaseRateKey=@Baseratekey AND Itemkey=@ItemKey AND EffectiveDate=@EffectiveDate
		END
	END
	ELSE
	BEGIN
	  INSERT INTO dbo.CustomerItemRate(ClientOrBrokerKey,CustomerKey,CityKey,UnitPrice,
				  EmailContact,CreateDate,CreateUserKey,LastUpdateDate,LastUpdateUserKey,EffectiveDate,Itemkey,CompanyKey) 
	  VALUES (  @BrokerKey,@Customerkey,@CityKey,@UnitPrice,@EmailAddress,GETDATE(),@UserKey,GETDATE(),@UserKey,
				@ConvEffectiveDate,@ItemKey, @CompnayKey) ;	
	END

	SET @OutPut=1;
END;


