CREATE PROCEDURE [dbo].[InsertUpdate_BaseRates]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)

AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @BaseRateKey        INT,
	        @CityKey			INT,
			@ClientOrBrokerKey	INT,
			@CustomerKey		INT,			
			@EffectiveDate		DATETIME,
			@EmailContact	    VARCHAR(100),
			@IsBroker		    BIT,
			@IsClient		    BIT,
			@LastUpdateDate		DATETIME,
			@LastUpdateUserKey  INT,
			@UnitPrice			DECIMAL(18,2)
			

	SELECT			@BaseRateKey=BaseRateKey,@CityKey = CityKey,@ClientOrBrokerKey= ClientOrBrokerKey,@CustomerKey = CustomerKey,
	                    @EffectiveDate= EffectiveDate,@EmailContact= EmailContact,@IsBroker = IsBroker,@IsClient = IsClient,
						@LastUpdateDate = LastUpdateDate,@LastUpdateUserKey = LastUpdateUserKey,@UnitPrice = UnitPrice
	FROM OPENJSON		(@JSONString, '$')
						WITH (
						
			BaseRateKey			INT						  '$.BaseRateKey',								
		    CityKey			    INT                       '$.CityKey',
			ClientOrBrokerKey	INT			              '$.ClientOrBrokerKey',
			CustomerKey		    INT		                  '$.CustKey',
			EffectiveDate		DATETIME	              '$.EffectiveDate',
			EmailContact	    VARCHAR(100)		      '$.EmailContact',
			IsBroker		    BIT		                  '$.IsBroker',
			IsClient		    BIT			              '$.IsClient',
			LastUpdateDate		DATETIME	              '$.LastUpdateDate',
		    LastUpdateUserKey   INT			              '$.LastUpdateUserKey',
			UnitPrice			DECIMAL(18,2)			  '$.UnitPrice'
		    )
	
	
	IF(ISNULL(@BaseRateKey,0) = 0)
		BEGIN
			INSERT INTO		dbo.CustomerItemRate(CityKey,ClientOrBrokerKey,CustomerKey,EffectiveDate,EmailContact,IsBroker,
			                IsClient,LastUpdateDate,LastUpdateUserKey,UnitPrice,CreateUserKey,CreateDate)	
			Values
						   (@CityKey,@ClientOrBrokerKey,@CustomerKey,@EffectiveDate,@EmailContact,@IsBroker,@IsClient,@LastUpdateDate,@LastUpdateUserKey,@UnitPrice,@UserKey,GETDATE()) 

		    SET @BaseRateKey = SCOPE_IDENTITY();
            SET @Status = 1;
            SET @Reason = ' BaseRate Created Successfully';
		
		END
	ELSE
		BEGIN
		
			UPDATE	dbo.CustomerItemRate 
			SET		CityKey					= @CityKey,
					ClientOrBrokerKey		= @ClientOrBrokerKey,
					CustomerKey				= @CustomerKey,
					EffectiveDate			= @EffectiveDate,
					EmailContact			= @EmailContact,
					IsBroker			    = @IsBroker,
					IsClient			    = @IsClient,
					LastUpdateDate			= @LastUpdateDate,
					LastUpdateUserKey		= @UserKey,
					UnitPrice			    = @UnitPrice		
			 WHERE	BaseRateKey = @BaseRateKey			 
		

		SET @Status = 1
		SET @Reason = 'BaseRate Updated Successfully'

		END
	
END