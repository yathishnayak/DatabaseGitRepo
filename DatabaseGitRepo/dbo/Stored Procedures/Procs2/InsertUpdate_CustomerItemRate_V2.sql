/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '[{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":40,"UnitPrice":100,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":234,"UnitPrice":28,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":280,"UnitPrice":60.5,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":139,"UnitPrice":35,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":162,"UnitPrice":75,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":10,"UnitPrice":35,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":164,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":11,"UnitPrice":60,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":161,"UnitPrice":100,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":232,"UnitPrice":100,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":387,"UnitPrice":7000,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":137,"UnitPrice":500,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":170,"UnitPrice":15,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":246,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":22,"UnitPrice":10,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":5,"UnitPrice":60,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":7,"UnitPrice":103,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":386,"UnitPrice":2,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":226,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":372,"UnitPrice":12,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":42,"UnitPrice":5,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":358,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":165,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":18,"UnitPrice":100,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":166,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":360,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":361,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":362,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":363,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":158,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":322,"UnitPrice":0.05,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":350,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":328,"UnitPrice":25,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":237,"UnitPrice":350,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":265,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":205,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":294,"UnitPrice":25,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":84,"UnitPrice":10,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":357,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":329,"UnitPrice":50,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":348,"UnitPrice":11,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":275,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":365,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":229,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":93,"UnitPrice":100,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":327,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":325,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":19,"UnitPrice":56,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":103,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":29,"UnitPrice":200,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":105,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":326,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":351,"UnitPrice":150,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":247,"UnitPrice":150,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":349,"UnitPrice":15,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":330,"UnitPrice":55,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":119,"UnitPrice":50,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":250,"UnitPrice":150,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":121,"UnitPrice":25,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":231,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":159,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":385,"UnitPrice":2,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":375,"UnitPrice":2,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":376,"UnitPrice":2,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":379,"UnitPrice":2,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":382,"UnitPrice":5,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":380,"UnitPrice":5,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":374,"UnitPrice":2,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":339,"UnitPrice":600,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":341,"UnitPrice":800,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":335,"UnitPrice":325,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":334,"UnitPrice":400,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":343,"UnitPrice":900,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":344,"UnitPrice":1000,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":336,"UnitPrice":400,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":333,"UnitPrice":475,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":338,"UnitPrice":500,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":129,"UnitPrice":100,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":156,"UnitPrice":1,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":331,"UnitPrice":75,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144},{"CityKey":1,"CustKey":3195,"EffectiveDate":"2026-02-23","ItemKey":332,"UnitPrice":75,"BaserateKey":0,"CompnayKey":1,"EmailAddress":"","Zip":"14410","UserKey":1144}]'
	EXEC [InsertUpdate_CustomerItemRate_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[InsertUpdate_CustomerItemRate_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
	-- @Output			Bit = 0 OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@BaserateKey		INT=0,
		@BrokerKey			INT,
		@CustomerKey		INT,
		@CityKey			INT,
		@ItemKey			INT,
		@UnitPrice			DECIMAL(18,2),
		@EmailAddress		VARCHAR(200),
		@Zip				VARCHAR(50),
		@EffectiveDate		varchar(10),--DATE,
		-- @UserKey			INT,
		@CompnayKey			INT=1
		-- @OutPut				BIT OUTPUT
	
	DECLARE cur CURSOR FOR
	SELECT 
	BaserateKey	    ,
	BrokerKey		,
	CustomerKey		,
	CityKey			,
	ItemKey			,
	UnitPrice		,	
	EmailAddress	,	
	Zip				,
	EffectiveDate	,	
	CompnayKey			
	FROM OPENJSON(@JSONString)
	WITH
	( BaserateKey		INT					'$.BaserateKey',
	  BrokerKey			INT					'$.BrokerKey',	
	  CustomerKey		INT					'$.CustKey',
	  CityKey			INT					'$.CityKey',
	  ItemKey			INT					'$.ItemKey',
	  UnitPrice			DECIMAL(18,2)		'$.UnitPrice',	
	  EmailAddress		VARCHAR(200)		'$.EmailAddress',
	  Zip				VARCHAR(50)			'$.Zip',
	  EffectiveDate		VARCHAR(10)			'$.EffectiveDate',	
	  CompnayKey		INT					'$.CompnayKey'
	 )

    OPEN cur

	FETCH NEXT FROM cur INTO @BaserateKey, @BrokerKey, @CustomerKey, @CityKey, @ItemKey, @UnitPrice,
	@EmailAddress, @Zip, @EffectiveDate, @CompnayKey

	WHILE @@FETCH_STATUS = 0
    BEGIN
	Declare  @ConvEffectiveDate Date
	DECLARE  @_ClientOrBrokerKey INT
	DECLARE  @_UnitPrice		 DECIMAL(18,2)
	DECLARE  @_EmailContact		 VARCHAR(200)
	DECLARe @UserName varchar(30),
			@CustName varchar(50),
			@CustId varchar(20)

	SELECT @ConvEffectiveDate = CONVERT(DATE,@EffectiveDate)
	SET @BrokerKey=		CASE WHEN @BrokerKey=0     THEN NULL ELSE @BrokerKey    END
	SET @CustomerKey=	CASE WHEN @CustomerKey=0   THEN NULL ELSE @CustomerKey  END
	SET @CompnayKey=	CASE WHEN @CompnayKey=0    THEN NULL ELSE @CompnayKey   END
	SET @UserKey=		CASE WHEN @UserKey=0       THEN NULL ELSE @UserKey      END
	SET @ItemKey=		CASE WHEN @ItemKey=0       THEN NULL ELSE @ItemKey      END
	SET @EmailAddress=	CASE WHEN @EmailAddress='' THEN NULL ELSE @EmailAddress END

	IF @ItemKey IS NULL 
		BEGIN
			SET @Status=0;
			SET @Reason='ItemKey cannot be null'
			GOTO CursorEnd
		END
	--IF ( SELECT COUNT(1) FROM dbo.BaseRate WHERE CustomerKey=@CustomerKey AND Itemkey=@ItemKey AND BaserateKey=@BaserateKey AND CityKey=@CityKey AND EffectiveDate=@EffectiveDate )>0
 --   IF ISNULL(@BaserateKey,0)>0
	--BEGIN
	--	SELECT @_ClientOrBrokerKey=ClientOrBrokerKey,
	--		   @_UnitPrice=UnitPrice,@_EmailContact=EmailContact 
	--	FROM   CustomerItemRate WITH (NOLOCK) 
	--	WHERE  BaserateKey=@BaserateKey

	--	IF ( @_ClientOrBrokerKey <> @BrokerKey OR @_UnitPrice <> @UnitPrice OR @_EmailContact <> @EmailAddress )
	--	BEGIN
	--		UPDATE 
	--		dbo.CustomerItemRate
	--		SET ClientOrBrokerKey=  @BrokerKey,
	--			UnitPrice=			@UnitPrice,
	--			EmailContact=		@EmailAddress,
	--			LastUpdateDate=		GETDATE(),
	--			LastUpdateUserKey=	@UserKey,			
	--			CompanyKey=			@CompnayKey
	--		WHERE BaserateKey=@BaserateKey --CustomerKey=@CustomerKey AND CityKey= @CityKey AND BaserateKey=@BaserateKey AND Itemkey=@ItemKey AND EffectiveDate=@EffectiveDate
	--	END
	--END
	--ELSE
	--BEGIN
	--  INSERT INTO dbo.CustomerItemRate(ClientOrBrokerKey,CustomerKey,CityKey,UnitPrice,
	--			  EmailContact,CreateDate,CreateUserKey,LastUpdateDate,LastUpdateUserKey,EffectiveDate,Itemkey,CompanyKey) 
	--  VALUES (  @BrokerKey,@CustomerKey,@CityKey,@UnitPrice,@EmailAddress,GETDATE(),@UserKey,GETDATE(),@UserKey,
	--			@ConvEffectiveDate,@ItemKey, @CompnayKey) ;	
	--END
	IF EXISTS (
    SELECT 1
    FROM dbo.CustomerItemRate
    WHERE CustomerKey = @CustomerKey
      AND ItemKey = @ItemKey
      AND CityKey = @CityKey
      AND EffectiveDate = @ConvEffectiveDate
	)
	BEGIN
		UPDATE dbo.CustomerItemRate
		SET ClientOrBrokerKey = @BrokerKey,
			UnitPrice = @UnitPrice,
			EmailContact = @EmailAddress,
			LastUpdateDate = GETDATE(),
			LastUpdateUserKey = @UserKey,
			CompanyKey = @CompnayKey
		WHERE CustomerKey = @CustomerKey
		  AND ItemKey = @ItemKey
		  AND CityKey = @CityKey
		  AND EffectiveDate = @ConvEffectiveDate
	END
	ELSE
	BEGIN
		INSERT INTO dbo.CustomerItemRate
		(
			ClientOrBrokerKey, CustomerKey, CityKey, UnitPrice,
			EmailContact, CreateDate, CreateUserKey,
			LastUpdateDate, LastUpdateUserKey,
			EffectiveDate, Itemkey, CompanyKey
		)
		VALUES
		(
			@BrokerKey, @CustomerKey, @CityKey, @UnitPrice,
			@EmailAddress, GETDATE(), @UserKey,
			GETDATE(), @UserKey,
			@ConvEffectiveDate, @ItemKey, @CompnayKey
		)
	END
	FETCH NEXT FROM cur INTO @BaserateKey, @BrokerKey, @CustomerKey, @CityKey, @ItemKey, @UnitPrice,
	@EmailAddress, @Zip, @EffectiveDate, @CompnayKey    END

	CursorEnd: 

    CLOSE cur
    DEALLOCATE cur

	SET @Status=1;
	SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
	SELECT @CustName=ISNULL(CustName, '') FROM Customer WITH(NOLOCK) WHERE CustKey = @CustomerKey
	SELECT @CustId=ISNULL(CustID, '') FROM Customer WITH(NOLOCK) WHERE CustKey = @CustomerKey

	INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
	SELECT GETDATE(),@UserName,'Customer',@CustId,@CustomerKey,null,'Text','Customer Item Rate for customer ' + @CustName + ' updated by ' + @UserName

	SET @Status = 1
	SET @Reason = 'Success'
END