/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@JSONSTRING		NVARCHAR(Max) = '[{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":418,"Rate":50001,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":1,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":354,"Rate":-50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":355,"Rate":-50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":347,"Rate":25,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":143,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":142,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":17,"Rate":0.25,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":81,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":266,"Rate":25,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":274,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":138,"Rate":100,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":396,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":399,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":345,"Rate":25,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":246,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":150,"Rate":80,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":149,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":16,"Rate":60,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":14,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":145,"Rate":75,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":309,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":207,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":154,"Rate":60,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":273,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":318,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":7,"Rate":100,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":397,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":398,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":402,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":400,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":401,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":403,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":40,"Rate":25,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":234,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":280,"Rate":60.5,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":139,"Rate":35,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":162,"Rate":75,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":10,"Rate":35,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":164,"Rate":1,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":11,"Rate":60,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":161,"Rate":100,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":232,"Rate":100,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":137,"Rate":500,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":170,"Rate":15,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":119,"Rate":50,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":22,"Rate":10,"CompanyKey":1},{"CityKey":25191,"EffectiveDate":"2026-05-03T00:00:00.000Z","ItemKey":5,"Rate":60,"CompanyKey":1}]'
	EXEC [InsertUpdate_DriverItemRate_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[InsertUpdate_DriverItemRate_V2]
(
    @UserKey		int = 0,
	@JSONString     nvarchar(max) = '',
	@Status         Bit = 0 OUTPUT,
    @Reason			VARCHAR(50) = ''OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

--DECLARE	@DriverRateKey		INT=0,
--        @DriverKey			INT,
--        @CityKey			INT,
--        @ItemKey			INT,
--        @UnitCost			DECIMAL(18,2),
--        @EffectiveDate		VARCHAR(10),--DATE,
--        @CompanyKey			INT=1,
--	    @_ConvEffectiveDate	DATE,	  
--	    @_EmailContact		VARCHAR(200),
--	    @_UnitCost		    DECIMAL(18,2)

--	SELECT @_ConvEffectiveDate = CONVERT(DATE,@EffectiveDate)

--	SET @CityKey=		CASE WHEN @CityKey=0     THEN NULL ELSE @CityKey		END	
--	SET @CompanyKey=	CASE WHEN @CompanyKey=0   THEN NULL ELSE @CompanyKey	END
--	SET @UserKey=		CASE WHEN @UserKey=0      THEN NULL ELSE @UserKey		END


--		SELECT				@DriverRateKey = DriverRateKey, @DriverKey = DriverKey, @CityKey = CityKey, @ItemKey = ItemKey, @UnitCost = UnitCost
--						,@EffectiveDate = EffectiveDate, @CompanyKey = CompanyKey, @_ConvEffectiveDate= _ConvEffectiveDate,
--						@_EmailContact= _EmailContact
						
--	FROM OPENJSON		(@JSONString, '$')
--						WITH (
--								DriverRateKey			INT		       '$.DriverRateKey',
--								DriverKey			    INT	           '$.DriverKey',
--								CityKey			        INT		       '$.CityKey',
--								ItemKey			        INT	           '$.ItemKey',
--								UnitCost		        DECIMAL(18,2)  '$.UnitCost',
--								EffectiveDate		    VARCHAR(10)  	'$.EffectiveDate',
--								CompanyKey		        INT		        '$.CompanyKey',
--								_ConvEffectiveDate	    DATE			'$._ConvEffectiveDate',
--								_EmailContact		    VARCHAR(200)	'$._EmailContact'		
--							 )

--	IF @ItemKey IS NULL 
--	BEGIN
--		SET @OutPut=0;
--		RETURN ;
--	END
	
--	IF ISNULL(@DriverRateKey,0)>0
--	BEGIN
--		SELECT @_UnitCost=@UnitCost
--		FROM   DriverLocationItem WITH (NOLOCK)
--		WHERE  DriverRateKey=@DriverRateKey

--		IF (  @_UnitCost <> @UnitCost )
--		BEGIN
--			UPDATE dbo.DriverLocationItem
--			SET 
--				UnitCost=			@UnitCost,				
--				LastUpdateDate=		GETDATE(),
--				LastUpdateUserKey=	@UserKey				
--			WHERE DriverRateKey=@DriverRateKey
--		END
--	END
--	ELSE
--	BEGIN
--	  delete  from DriverLocationItem
--	  where  isnull(Driverkey,0)= isnull(@DriverKey,0) and ItemKey= @ItemKey and CityKey= @CityKey and EffectiveDate= @_ConvEffectiveDate

--	  INSERT INTO dbo.DriverLocationItem( Driverkey,ItemKey,CityKey,UnitCost,EffectiveDate,CreateDate,CreateUserKey,LastUpdateDate,LastUpdateUserKey,CompanyKey) 
--	  VALUES (  @DriverKey,@ItemKey,@CityKey,@UnitCost,@_ConvEffectiveDate,GETDATE(),@UserKey,GETDATE(),@UserKey,@CompanyKey) ;	
--	END
--		SET @Status = 1
--		SET @Reason = 'Success'
--	    SET @OutPut=1;

	BEGIN TRY

        -- 🔹 Validate input
        IF ISNULL(@JSONString, '') = ''
        BEGIN
            SET @Status = 0;
            SET @Reason = 'JSON string is empty';
            RETURN;
        END

        ------------------------------------------------------------------
        -- 🔹 Parse JSON into table
        ------------------------------------------------------------------
        DECLARE @Data TABLE
        (
            DriverRateKey INT,
            DriverKey     INT ,
            CityKey       INT ,
            ItemKey       INT NOT NULL,
            UnitCost      DECIMAL(18,2),
            EffectiveDate DATE,
            CompanyKey    INT
        );

        INSERT INTO @Data
        (
            DriverRateKey,
            DriverKey,
            CityKey,
            ItemKey,
            UnitCost,
            EffectiveDate,
            CompanyKey
        )
        SELECT 
            DriverRateKey,
            DriverKey,
            CityKey,
            ItemKey,
            Rate, 
            CONVERT(DATE, EffectiveDate),
            CompanyKey
        FROM OPENJSON(@JSONString)
        WITH
        (
            DriverRateKey INT '$.DriverRateKey',
            DriverKey     INT '$.DriverKey',
            CityKey       INT '$.CityKey',
            ItemKey       INT '$.ItemKey',
            Rate          DECIMAL(18,2) '$.Rate',
            EffectiveDate DATETIME '$.EffectiveDate',
            CompanyKey    INT '$.CompanyKey'
        );

        ------------------------------------------------------------------
        -- 🔹 Validation
        ------------------------------------------------------------------
        IF NOT EXISTS (SELECT 1 FROM @Data)
        BEGIN
            SET @Status = 0;
            SET @Reason = 'No valid data found in JSON';
            RETURN;
        END

        ------------------------------------------------------------------
        -- 🔹 DELETE existing duplicates (based on business key)
        ------------------------------------------------------------------
        DELETE D
        FROM DriverLocationItem D
        INNER JOIN @Data T
            ON ISNULL(D.DriverKey, 0) = ISNULL(T.DriverKey, 0)
           AND D.ItemKey = T.ItemKey
           AND D.CityKey = T.CityKey
           AND D.EffectiveDate = T.EffectiveDate;

        ------------------------------------------------------------------
        -- 🔹 INSERT new records
        ------------------------------------------------------------------
        INSERT INTO DriverLocationItem
        (
            DriverKey,
            ItemKey,
            CityKey,
            UnitCost,
            EffectiveDate,
            CreateDate,
            CreateUserKey,
            LastUpdateDate,
            LastUpdateUserKey,
            CompanyKey
        )
        SELECT
            DriverKey,
            ItemKey,
            CityKey,
            UnitCost,
            EffectiveDate,
            GETDATE(),
            @UserKey,
            GETDATE(),
            @UserKey,
            CompanyKey
        FROM @Data;

        ------------------------------------------------------------------
        -- 🔹 Success
        ------------------------------------------------------------------
        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH

        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();

    END CATCH
END;


--select * from DriverLocationItem