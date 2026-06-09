/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketKey":null,"TerminalKey":4,"Zone":"","YardPort":""}'
	EXEC [COST_CostOutputReport_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[COST_CostOutputReport_V2]
(
    @UserKey        INT = 1144,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN

    IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Status = 0
        SET @Reason = 'Parameters not found'
        RETURN
    END

    DECLARE 
        @MarketKey      INT = NULL,
        @CityKey        INT = NULL,
        @TerminalKey    INT = NULL,
        @DriverTypeKey  INT = NULL,
        @Zone           VARCHAR(100) = NULL,
        @YardPort       VARCHAR(100) = NULL,
        @SearchText     VARCHAR(200) = NULL

    SET @MarketKey      = TRY_CAST(JSON_VALUE(@JSONString, '$.MarketKey')       AS INT)
    SET @CityKey        = TRY_CAST(JSON_VALUE(@JSONString, '$.CityKey')         AS INT)
    SET @TerminalKey    = TRY_CAST(JSON_VALUE(@JSONString, '$.TerminalKey')     AS INT)
    SET @DriverTypeKey  = TRY_CAST(JSON_VALUE(@JSONString, '$.DriverTypeKey')   AS INT)
    SET @Zone           = NULLIF(TRIM(JSON_VALUE(@JSONString, '$.Zone')),        '')
    SET @YardPort       = NULLIF(TRIM(JSON_VALUE(@JSONString, '$.YardPort')),    '')
    SET @SearchText     = NULLIF(TRIM(JSON_VALUE(@JSONString, '$.SearchText')),  '')

    DECLARE @Market     VARCHAR(100) = NULL,
            @City       VARCHAR(100) = NULL,
            @Terminal   VARCHAR(100) = NULL,
            @DriverType VARCHAR(100) = NULL

    SET @Market     = (SELECT MarketLocation FROM MarketLocation  WITH (NOLOCK) WHERE MarketLocationKey  = @MarketKey)
    SET @City       = (SELECT City           FROM LocationData    WITH (NOLOCK) WHERE CityKey            = @CityKey)
    SET @Terminal   = (SELECT PriceGrouping  FROM PriceGrouping   WITH (NOLOCK) WHERE PriceGroupingKey   = @TerminalKey)
    SET @DriverType = (SELECT TruckType      FROM TruckType       WITH (NOLOCK) WHERE TruckTypeKey       = @DriverTypeKey)

    IF @IsDebug = 1
    BEGIN
        SELECT 
            @MarketKey      AS MarketKey,
            @CityKey        AS CityKey,
            @TerminalKey    AS TerminalKey,
            @DriverTypeKey  AS DriverTypeKey,
            @Zone           AS Zone,
            @YardPort       AS YardPort,
            @SearchText     AS SearchText,
            @Market         AS Market,
            @City           AS City,
            @Terminal       AS Terminal,
            @DriverType     AS DriverType
    END

    SELECT TOP 300
        market, Terminal, City, State, ZipCode, Zone, DriverType,
        Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom,
        STUFF((
            SELECT ', ' + SS.yardPortType
            FROM COST_CostDataOutput SS WITH (NOLOCK)
            WHERE CD.market           = SS.market
              AND CD.Terminal         = SS.Terminal
              AND CD.City             = SS.City
              AND CD.State            = SS.State
              AND ISNULL(CD.ZipCode,'') = ISNULL(SS.ZipCode,'')
              AND CD.Zone             = SS.Zone
              AND CD.DriverType       = SS.DriverType
              AND CD.Cost             = SS.Cost
              AND CD.FSFCost          = SS.FSFCost
              AND CD.FSF              = SS.FSF
              AND CD.Draybase         = SS.Draybase
              AND CD.EffectiveDate    = SS.EffectiveDate
              AND CD.EffectiveDateFrom = SS.EffectiveDateFrom
            FOR XML PATH('')
        ), 1, 1, '') AS YardPortType
    INTO #TMP
    FROM COST_CostDataOutput CD WITH (NOLOCK)
    GROUP BY market, Terminal, City, State, ZipCode, Zone, DriverType,
             Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom

    SELECT TOP 300
        market, YardPortType, City, State, ZipCode, Zone, DriverType,
        Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom,
        STUFF((
            SELECT ', ' + SS.Terminal
            FROM #TMP SS
            WHERE CD.market             = SS.market
              AND CD.City               = SS.City
              AND CD.State              = SS.State
              AND ISNULL(CD.ZipCode,'') = ISNULL(SS.ZipCode,'')
              AND CD.Zone               = SS.Zone
              AND CD.DriverType         = SS.DriverType
              AND CD.Cost               = SS.Cost
              AND CD.FSFCost            = SS.FSFCost
              AND CD.FSF                = SS.FSF
              AND CD.Draybase           = SS.Draybase
              AND CD.EffectiveDate      = SS.EffectiveDate
              AND CD.EffectiveDateFrom  = SS.EffectiveDateFrom
              AND CD.YardPortType       = SS.YardPortType
            FOR XML PATH('')
        ), 1, 1, '') AS Terminal
    INTO #FINALDATA
    FROM #TMP CD
    GROUP BY market, YardPortType, City, State, ZipCode, Zone, DriverType,
             Cost, FSFCost, FSF, Draybase, EffectiveDate, EffectiveDateFrom

    SELECT TOP 300
        Market, Terminal, City, State, ZipCode, Zone, DriverType, YardPortType,
        Cost, FSF, DrayBase,
        CONVERT(VARCHAR, EffectiveDate, 110) AS EffectiveDate,
        EffectiveDateFrom, FSFCost
    FROM #FINALDATA
    WHERE 
        --(Market = @Market OR @Market IS NULL)
        --AND (City = @City OR @City IS NULL)
        --AND (
        --    (',' + REPLACE(Terminal, ' ', '') + ',' LIKE '%,' + REPLACE(@Terminal, ' ', '') + ',%')
        --    OR @Terminal IS NULL
        --)
        --AND (DriverType = @DriverType OR @DriverType IS NULL)
        --AND (Zone = @Zone OR @Zone IS NULL)
        --AND (
        --    (',' + REPLACE(YardPortType, ' ', '') + ',' LIKE '%,' + REPLACE(@YardPort, ' ', '') + ',%')
        --    OR @YardPort IS NULL
        --)
        (
            (',' + REPLACE(Market, ' ', '') + ',' LIKE '%,' + REPLACE(@Market, ' ', '') + ',%')
            OR @Market IS NULL
        )
        AND (
            (',' + REPLACE(City, ' ', '') + ',' LIKE '%,' + REPLACE(@City, ' ', '') + ',%')
            OR @City IS NULL
        )
        AND (
            (',' + REPLACE(Terminal, ' ', '') + ',' LIKE '%,' + REPLACE(@Terminal, ' ', '') + ',%')
            OR @Terminal IS NULL
        )
        AND (
            (',' + REPLACE(YardPortType, ' ', '') + ',' LIKE '%,' + REPLACE(@YardPort, ' ', '') + ',%')
            OR @YardPort IS NULL
        )
        AND (
            (',' + REPLACE(DriverType, ' ', '') + ',' LIKE '%,' + REPLACE(@DriverType, ' ', '') + ',%')
            OR @DriverType IS NULL
        )
        AND Cost > 0
    ORDER BY Market, City, State, ZipCode, Zone, DriverType, Terminal, EffectiveDate, EffectiveDateFrom
    FOR JSON PATH;

    SET @Status = 1
    SET @Reason = 'Success'

END