/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketKey" : 0, "CityKey" : 0, "TerminalKey" : 0, "DriverTypeKey" : 0, "Zone" : "", "YardPort" : "", "SearchText" : ""}'
	EXEC [COST_CostOutputReport_V3] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[COST_CostOutputReport_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT OUTPUT,
	@Reason			VARCHAR(1000) OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE 
		@MarketKey		INT = 0,
		@CityKey		INT = 0,
		@TerminalKey	INT = 0,
		@DriverTypeKey	INT = 0,
		@Zone			VARCHAR(100)='',
		@YardPort		VARCHAR(100)='',
		@SearchText		VARCHAR(200)=''

	/* Parse JSON */
	SELECT 
		@MarketKey		= MarketKey,
		@CityKey		= CityKey,
		@TerminalKey	= TerminalKey,
		@DriverTypeKey	= DriverTypeKey,
		@Zone			= Zone,
		@YardPort		= YardPort,
		@SearchText		= SearchText
	FROM OPENJSON(@JSONString)
	WITH
	(
		MarketKey			INT				'$.MarketKey',		
		CityKey				INT				'$.CityKey',		
		TerminalKey			INT				'$.TerminalKey',	
		DriverTypeKey		INT				'$.DriverTypeKey',	
		Zone				VARCHAR(100)	'$.Zone',			
		YardPort			VARCHAR(100)	'$.YardPort',		
		SearchText			VARCHAR(200)	'$.SearchText'
	)

	/* Lookup values */
	DECLARE
		@Market		VARCHAR(100),
		@City		VARCHAR(100),
		@Terminal	VARCHAR(100),
		@DriverType	VARCHAR(100)

	SELECT @Market = MarketLocation 
	FROM MarketLocation WITH (NOLOCK) 
	WHERE MarketLocationKey = @MarketKey

	SELECT @City = City 
	FROM LocationData WITH (NOLOCK) 
	WHERE CityKey = @CityKey

	SELECT @Terminal = PriceGrouping 
	FROM PriceGrouping WITH (NOLOCK) 
	WHERE PriceGroupingKey = @TerminalKey

	SELECT @DriverType = TruckType 
	FROM TruckType WITH (NOLOCK) 
	WHERE TruckTypeKey = @DriverTypeKey


	/* First aggregation (YardPortType) */
	SELECT 
	market,
	Terminal,
	City,
	State,
	ZipCode,
	Zone,
	DriverType,
	Cost,
	FSFCost,
	FSF,
	Draybase,
	EffectiveDate,
	EffectiveDateFrom,
	STRING_AGG(yardPortType, ', ') AS YardPortType
	INTO #TMP
	FROM COST_CostDataOutput WITH (NOLOCK)
	GROUP BY 
	market, Terminal, City, State, ZipCode, Zone,
	DriverType, Cost, FSFCost, FSF, Draybase,
	EffectiveDate, EffectiveDateFrom



	/* Second aggregation (Terminal merge) */
	SELECT 
	market,
	YardPortType,
	City,
	State,
	ZipCode,
	Zone,
	DriverType,
	Cost,
	FSFCost,
	FSF,
	Draybase,
	EffectiveDate,
	EffectiveDateFrom,
	STRING_AGG(Terminal, ', ') AS Terminal
	INTO #FINALDATA
	FROM #TMP
	GROUP BY
	market, YardPortType, City, State, ZipCode,
	Zone, DriverType, Cost, FSFCost, FSF,
	Draybase, EffectiveDate, EffectiveDateFrom


	/* Final Output */
	SELECT
		Market,
		Terminal,
		City,
		State,
		ZipCode,
		Zone,
		DriverType,
		YardPortType,
		Cost,
		FSF,
		DrayBase,
		CONVERT(VARCHAR,EffectiveDate,110) AS EffectiveDate,
		EffectiveDateFrom,
		FSFCost

	FROM #FINALDATA

	WHERE
		(@Market IS NULL OR @Market='' OR Market=@Market)
		AND (@City IS NULL OR @City='' OR City=@City)
		AND (@Terminal IS NULL OR @Terminal='' OR Terminal=@Terminal)
		AND (@DriverType IS NULL OR @DriverType='' OR DriverType=@DriverType)
		AND (@Zone='' OR Zone=@Zone)
		AND (@YardPort='' OR YardPortType=@YardPort)
		AND Cost > 0

	ORDER BY
		Market, City, State, ZipCode,
		Zone, DriverType, Terminal,
		EffectiveDate, EffectiveDateFrom

	FOR JSON PATH


	SET @Status = 1
	SET @Reason = 'Success'

END
