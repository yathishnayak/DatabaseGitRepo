/*

DECLARE @UserKey INT = 950, @Status BIT, @Reason VARCHAR(500), @JsonInput NVARCHAR(MAX), @IsDebug INT = 1;
SET @JsonInput = '{"FileProcessKey":151}';
EXEC [FileDataInsertionVerification] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/
CREATE PROCEDURE [dbo].[Compare_FileDataInsertionVerification]
(
    @UserKey        INT,
    @JsonInput      NVARCHAR(MAX),
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(500) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
    BEGIN TRY

        DECLARE @FileProcessKey INT = JSON_VALUE(@JsonInput, '$.FileProcessKey')

        IF @FileProcessKey IS NULL
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Missing required fields';
            RETURN;
        END

        DECLARE @FileContent NVARCHAR(MAX)
        SET @FileContent = (SELECT FileContent FROM Cost_FileContent WHERE FileProcessKey = @FileProcessKey)
        
        IF (@IsDebug = 1)
        BEGIN
            SELECT @FileContent AS FileContent_JSON
        END

        -- Create temp table for JSON data with row numbers
        CREATE TABLE #JsonData (
            RowNum INT IDENTITY(1,1),
			Market						VARCHAR(100),
			Terminal					VARCHAR(100),
			City						VARCHAR(100),
			State						VARCHAR(100),
			ZipCode						VARCHAR(100),
			Zone						VARCHAR(100),
			Prepulllocation1			VARCHAR(100),
			Prepullcost1				VARCHAR(100),
			Prepulllocation2			VARCHAR(100),
			Prepullcost2				VARCHAR(100),
			Prepulllocation3			VARCHAR(100),
			Prepullcost3				VARCHAR(100),
			Prepulllocation4			VARCHAR(100),
			Prepullcost4				VARCHAR(100),
			Prepulllocation5			VARCHAR(100),
			Prepullcost5				VARCHAR(100),
			Stopofflocation1			VARCHAR(100),
			Stopoffcost1				VARCHAR(100),
			Stopofflocation2			VARCHAR(100),
			Stopoffcost2				VARCHAR(100),
			Stopofflocation3			VARCHAR(100),
			Stopoffcost3				VARCHAR(100),
			Stopofflocation4			VARCHAR(100),
			Stopoffcost4				VARCHAR(100),
			Stopofflocation5			VARCHAR(100),
			Stopoffcost5				VARCHAR(100),
			YardshuttledirectionTO1		VARCHAR(100),
			YardshuttledirectionFROM1	VARCHAR(100),
			Yardshuttlecost1			VARCHAR(100),
			YardshuttledirectionTO2		VARCHAR(100),
			YardshuttledirectionFROM2	VARCHAR(100),
			Yardshuttlecost2			VARCHAR(100),
			TruckTypeA					VARCHAR(100),
			TruckTypeABaseCost1			VARCHAR(100),
			TruckTypeAFSF1				VARCHAR(100),
			TruckTypeAFROM1				VARCHAR(100),
			TruckTypeABaseCost2			VARCHAR(100),
			TruckTypeAFSF2				VARCHAR(100),
			TruckTypeAFROM2				VARCHAR(100),
			TruckTypeABaseCost3			VARCHAR(100),
			TruckTypeAFSF3				VARCHAR(100),
			TruckTypeAFROM3				VARCHAR(100),
			TruckTypeB					VARCHAR(100),
			TruckTypeBBaseCost1			VARCHAR(100),
			TruckTypeBFSC1				VARCHAR(100),
			TruckTypeBFROM1				VARCHAR(100),
			TruckTypeBBaseCost2			VARCHAR(100),
			TruckTypeBFSC2				VARCHAR(100),
			TruckTypeBFROM2				VARCHAR(100),
			TruckTypeBBaseCost3			VARCHAR(100),
			TruckTypeBFSC3				VARCHAR(100),
			TruckTypeBFROM3				VARCHAR(100),
			TruckTypeC					VARCHAR(100),
			TruckTypeCBaseCost1			VARCHAR(100),
			TruckTypeCFSC1				VARCHAR(100),
			TruckTypeCFROM1				VARCHAR(100),
			TruckTypeCBaseCost2			VARCHAR(100),
			TruckTypeCFSC2				VARCHAR(100),
			TruckTypeCFROM2				VARCHAR(100),
			TruckTypeCBaseCost3			VARCHAR(100),
			TruckTypeCFSC3				VARCHAR(100),
			TruckTypeCFROM3				VARCHAR(100),
			TruckTypeD					VARCHAR(100),
			TruckTypeDBaseCost1			VARCHAR(100),
			TruckTypeDFSC1				VARCHAR(100),
			TruckTypeDFROM1				VARCHAR(100),
			TruckTypeDBaseCost2			VARCHAR(100),
			TruckTypeDFSC2				VARCHAR(100),
			TruckTypeDFROM2				VARCHAR(100),
			TruckTypeDBaseCost3			VARCHAR(100),
			TruckTypeDFSC3				VARCHAR(100),
			TruckTypeDFROM3				VARCHAR(100),
			EffectiveDate				VARCHAR(100),
			EffectiveDateFrom			VARCHAR(100)
        )

        -- Insert JSON data with sequential numbering
        INSERT INTO #JsonData (
            Market, Terminal, City, State, ZipCode, Zone, 
			Prepulllocation1, Prepullcost1, Prepulllocation2, Prepullcost2, Prepulllocation3, Prepullcost3, 
			Prepulllocation4, Prepullcost4, Prepulllocation5, Prepullcost5, 
			Stopofflocation1, Stopoffcost1, Stopofflocation2, Stopoffcost2, Stopofflocation3, Stopoffcost3, 
			Stopofflocation4, Stopoffcost4, Stopofflocation5, Stopoffcost5, 
			YardshuttledirectionTO1, YardshuttledirectionFROM1, Yardshuttlecost1, 
			YardshuttledirectionTO2, YardshuttledirectionFROM2, Yardshuttlecost2, 
			TruckTypeA, TruckTypeABaseCost1, TruckTypeAFSF1, TruckTypeAFROM1, 
			TruckTypeABaseCost2, TruckTypeAFSF2, TruckTypeAFROM2, 
			TruckTypeABaseCost3, TruckTypeAFSF3, TruckTypeAFROM3, 
			TruckTypeB, TruckTypeBBaseCost1, TruckTypeBFSC1, TruckTypeBFROM1, 
			TruckTypeBBaseCost2, TruckTypeBFSC2, TruckTypeBFROM2, 
			TruckTypeBBaseCost3, TruckTypeBFSC3, TruckTypeBFROM3, 
			TruckTypeC, TruckTypeCBaseCost1, TruckTypeCFSC1, TruckTypeCFROM1, 
			TruckTypeCBaseCost2, TruckTypeCFSC2, TruckTypeCFROM2, 
			TruckTypeCBaseCost3, TruckTypeCFSC3, TruckTypeCFROM3, 
			TruckTypeD, TruckTypeDBaseCost1, TruckTypeDFSC1, TruckTypeDFROM1, 
			TruckTypeDBaseCost2, TruckTypeDFSC2, TruckTypeDFROM2, 
			TruckTypeDBaseCost3, TruckTypeDFSC3, TruckTypeDFROM3, 
			EffectiveDate, EffectiveDateFrom
        )
        SELECT 
            Market, Terminal, City, State, ZipCode, Zone, 
			Prepulllocation1, Prepullcost1, Prepulllocation2, Prepullcost2, Prepulllocation3, Prepullcost3, 
			Prepulllocation4, Prepullcost4, Prepulllocation5, Prepullcost5, 
			Stopofflocation1, Stopoffcost1, Stopofflocation2, Stopoffcost2, Stopofflocation3, Stopoffcost3, 
			Stopofflocation4, Stopoffcost4, Stopofflocation5, Stopoffcost5, 
			YardshuttledirectionTO1, YardshuttledirectionFROM1, Yardshuttlecost1, 
			YardshuttledirectionTO2, YardshuttledirectionFROM2, Yardshuttlecost2, 
			TruckTypeA, TruckTypeABaseCost1, TruckTypeAFSF1, TruckTypeAFROM1, 
			TruckTypeABaseCost2, TruckTypeAFSF2, TruckTypeAFROM2, 
			TruckTypeABaseCost3, TruckTypeAFSF3, TruckTypeAFROM3, 
			TruckTypeB, TruckTypeBBaseCost1, TruckTypeBFSC1, TruckTypeBFROM1, 
			TruckTypeBBaseCost2, TruckTypeBFSC2, TruckTypeBFROM2, 
			TruckTypeBBaseCost3, TruckTypeBFSC3, TruckTypeBFROM3, 
			TruckTypeC, TruckTypeCBaseCost1, TruckTypeCFSC1, TruckTypeCFROM1, 
			TruckTypeCBaseCost2, TruckTypeCFSC2, TruckTypeCFROM2, 
			TruckTypeCBaseCost3, TruckTypeCFSC3, TruckTypeCFROM3, 
			TruckTypeD, TruckTypeDBaseCost1, TruckTypeDFSC1, TruckTypeDFROM1, 
			TruckTypeDBaseCost2, TruckTypeDFSC2, TruckTypeDFROM2, 
			TruckTypeDBaseCost3, TruckTypeDFSC3, TruckTypeDFROM3, 
			EffectiveDate, EffectiveDateFrom
        FROM OPENJSON(@FileContent, '$')
        WITH (
            Market						varchar(100)	'$.Market',
			Terminal					varchar(100)	'$.Terminal',
			City						varchar(100)	'$.City',
			State						varchar(100)	'$.State',
			ZipCode						varchar(100)	'$.ZipCode',
			Zone						varchar(100)	'$.Zone',
			Prepulllocation1			varchar(100)	'$.Prepulllocation1',
			Prepullcost1				varchar(100)	'$.Prepullcost1',
			Prepulllocation2			varchar(100)	'$.Prepulllocation2',
			Prepullcost2				varchar(100)	'$.Prepullcost2',
			Prepulllocation3			varchar(100)	'$.Prepulllocation3',
			Prepullcost3				varchar(100)	'$.Prepullcost3',
			Prepulllocation4			varchar(100)	'$.Prepulllocation4',
			Prepullcost4				varchar(100)	'$.Prepullcost4',
			Prepulllocation5			varchar(100)	'$.Prepulllocation5',
			Prepullcost5				varchar(100)	'$.Prepullcost5',
			Stopofflocation1			varchar(100)	'$.Stopofflocation1',
			Stopoffcost1				varchar(100)	'$.Stopoffcost1',
			Stopofflocation2			varchar(100)	'$.Stopofflocation2',
			Stopoffcost2				varchar(100)	'$.Stopoffcost2',
			Stopofflocation3			varchar(100)	'$.Stopofflocation3',
			Stopoffcost3				varchar(100)	'$.Stopoffcost3',
			Stopofflocation4			varchar(100)	'$.Stopofflocation4',
			Stopoffcost4				varchar(100)	'$.Stopoffcost4',
			Stopofflocation5			varchar(100)	'$.Stopofflocation5',
			Stopoffcost5				varchar(100)	'$.Stopoffcost5',
			YardshuttledirectionTO1		varchar(100)	'$.YardshuttledirectionTO1',
			YardshuttledirectionFROM1	varchar(100)	'$.YardshuttledirectionFROM1',
			Yardshuttlecost1			varchar(100)	'$.Yardshuttlecost1',
			YardshuttledirectionTO2		varchar(100)	'$.YardshuttledirectionTO2',
			YardshuttledirectionFROM2	varchar(100)	'$.YardshuttledirectionFROM2',
			Yardshuttlecost2			varchar(100)	'$.Yardshuttlecost2',
			TruckTypeA					varchar(100)	'$.TruckTypeA',
			TruckTypeABaseCost1			varchar(100)	'$.TruckTypeABaseCost1',
			TruckTypeAFSF1				varchar(100)	'$.TruckTypeAFSF1',
			TruckTypeAFROM1				varchar(100)	'$.FROM',
			TruckTypeABaseCost2			varchar(100)	'$.TruckTypeABaseCost2',
			TruckTypeAFSF2				varchar(100)	'$.TruckTypeAFSF2',
			TruckTypeAFROM2				varchar(100)	'$.TruckTypeAFROM2',
			TruckTypeABaseCost3			varchar(100)	'$.TruckTypeABaseCost3',
			TruckTypeAFSF3				varchar(100)	'$.TruckTypeAFSF3',
			TruckTypeAFROM3				varchar(100)	'$.TruckTypeAFROM3',
			TruckTypeB					varchar(100)	'$.TruckTypeB',
			TruckTypeBBaseCost1			varchar(100)	'$.TruckTypeBBaseCost1',
			TruckTypeBFSC1				varchar(100)	'$.TruckTypeBFSC1',
			TruckTypeBFROM1				varchar(100)	'$.TruckTypeBFROM1',
			TruckTypeBBaseCost2			varchar(100)	'$.TruckTypeBBaseCost2',
			TruckTypeBFSC2				varchar(100)	'$.TruckTypeBFSC2',
			TruckTypeBFROM2				varchar(100)	'$.TruckTypeBFROM2',
			TruckTypeBBaseCost3			varchar(100)	'$.TruckTypeBBaseCost3',
			TruckTypeBFSC3				varchar(100)	'$.TruckTypeBFSC3',
			TruckTypeBFROM3				varchar(100)	'$.TruckTypeBFROM3',
			TruckTypeC					varchar(100)	'$.TruckTypeC',
			TruckTypeCBaseCost1			varchar(100)	'$.TruckTypeCBaseCost1',
			TruckTypeCFSC1				varchar(100)	'$.TruckTypeCFSC1',
			TruckTypeCFROM1				varchar(100)	'$.TruckTypeCFROM1',
			TruckTypeCBaseCost2			varchar(100)	'$.TruckTypeCBaseCost2',
			TruckTypeCFSC2				varchar(100)	'$.TruckTypeCFSC2',
			TruckTypeCFROM2				varchar(100)	'$.TruckTypeCFROM2',
			TruckTypeCBaseCost3			varchar(100)	'$.TruckTypeCBaseCost3',
			TruckTypeCFSC3				varchar(100)	'$.TruckTypeCFSC3',
			TruckTypeCFROM3				varchar(100)	'$.TruckTypeCFROM3',
			TruckTypeD					varchar(100)	'$.TruckTypeD',
			TruckTypeDBaseCost1			varchar(100)	'$.TruckTypeDBaseCost1',
			TruckTypeDFSC1				varchar(100)	'$.TruckTypeDFSC1',
			TruckTypeDFROM1				varchar(100)	'$.TruckTypeDFROM1',
			TruckTypeDBaseCost2			varchar(100)	'$.TruckTypeDBaseCost2',
			TruckTypeDFSC2				varchar(100)	'$.TruckTypeDFSC2',
			TruckTypeDFROM2				varchar(100)	'$.TruckTypeDFROM2',
			TruckTypeDBaseCost3			varchar(100)	'$.TruckTypeDBaseCost3',
			TruckTypeDFSC3				varchar(100)	'$.TruckTypeDFSC3',
			TruckTypeDFROM3				varchar(100)	'$.TruckTypeDFROM3',
			EffectiveDate				varchar(100)	'$.EffectiveDate',
			EffectiveDateFrom			varchar(100)	'$.EffectiveDateFrom'
        )
		Order by City

--- Date Validation Logic Begin
		UPDATE #JsonData
		SET EffectiveDate = CASE 
		WHEN ISNUMERIC(EffectiveDate) = 1 THEN FORMAT(DATEADD(DAY, CAST(EffectiveDate AS INT), '1899-12-30'), 'yyyy-MM-ddTHH:mm:ss')
		WHEN TRY_CAST(EffectiveDate AS DATETIME) IS NOT NULL THEN FORMAT(CAST(EffectiveDate AS DATETIME), 'yyyy-MM-ddTHH:mm:ss')
		ELSE NULL
		END
--- Date Validation Logic End

		IF (@IsDebug = 1)
        BEGIN
            SELECT * from #JsonData order by RowNum
        END

        -- Create temp table for DB data with row numbers
        CREATE TABLE #DbData (
            RecordSL					INT,
            Market						VARCHAR(100),
			Terminal					VARCHAR(100),
			City						VARCHAR(100),
			State						VARCHAR(100),
			ZipCode						VARCHAR(100),
			Zone						VARCHAR(100),
			Prepulllocation1			VARCHAR(100),
			Prepullcost1				VARCHAR(100),
			Prepulllocation2			VARCHAR(100),
			Prepullcost2				VARCHAR(100),
			Prepulllocation3			VARCHAR(100),
			Prepullcost3				VARCHAR(100),
			Prepulllocation4			VARCHAR(100),
			Prepullcost4				VARCHAR(100),
			Prepulllocation5			VARCHAR(100),
			Prepullcost5				VARCHAR(100),
			Stopofflocation1			VARCHAR(100),
			Stopoffcost1				VARCHAR(100),
			Stopofflocation2			VARCHAR(100),
			Stopoffcost2				VARCHAR(100),
			Stopofflocation3			VARCHAR(100),
			Stopoffcost3				VARCHAR(100),
			Stopofflocation4			VARCHAR(100),
			Stopoffcost4				VARCHAR(100),
			Stopofflocation5			VARCHAR(100),
			Stopoffcost5				VARCHAR(100),
			YardshuttledirectionTO1		VARCHAR(100),
			YardshuttledirectionFROM1	VARCHAR(100),
			Yardshuttlecost1			VARCHAR(100),
			YardshuttledirectionTO2		VARCHAR(100),
			YardshuttledirectionFROM2	VARCHAR(100),
			Yardshuttlecost2			VARCHAR(100),
			TruckTypeA					VARCHAR(100),
			TruckTypeABaseCost1			VARCHAR(100),
			TruckTypeAFSF1				VARCHAR(100),
			TruckTypeAFROM1				VARCHAR(100),
			TruckTypeABaseCost2			VARCHAR(100),
			TruckTypeAFSF2				VARCHAR(100),
			TruckTypeAFROM2				VARCHAR(100),
			TruckTypeABaseCost3			VARCHAR(100),
			TruckTypeAFSF3				VARCHAR(100),
			TruckTypeAFROM3				VARCHAR(100),
			TruckTypeB					VARCHAR(100),
			TruckTypeBBaseCost1			VARCHAR(100),
			TruckTypeBFSC1				VARCHAR(100),
			TruckTypeBFROM1				VARCHAR(100),
			TruckTypeBBaseCost2			VARCHAR(100),
			TruckTypeBFSC2				VARCHAR(100),
			TruckTypeBFROM2				VARCHAR(100),
			TruckTypeBBaseCost3			VARCHAR(100),
			TruckTypeBFSC3				VARCHAR(100),
			TruckTypeBFROM3				VARCHAR(100),
			TruckTypeC					VARCHAR(100),
			TruckTypeCBaseCost1			VARCHAR(100),
			TruckTypeCFSC1				VARCHAR(100),
			TruckTypeCFROM1				VARCHAR(100),
			TruckTypeCBaseCost2			VARCHAR(100),
			TruckTypeCFSC2				VARCHAR(100),
			TruckTypeCFROM2				VARCHAR(100),
			TruckTypeCBaseCost3			VARCHAR(100),
			TruckTypeCFSC3				VARCHAR(100),
			TruckTypeCFROM3				VARCHAR(100),
			TruckTypeD					VARCHAR(100),
			TruckTypeDBaseCost1			VARCHAR(100),
			TruckTypeDFSC1				VARCHAR(100),
			TruckTypeDFROM1				VARCHAR(100),
			TruckTypeDBaseCost2			VARCHAR(100),
			TruckTypeDFSC2				VARCHAR(100),
			TruckTypeDFROM2				VARCHAR(100),
			TruckTypeDBaseCost3			VARCHAR(100),
			TruckTypeDFSC3				VARCHAR(100),
			TruckTypeDFROM3				VARCHAR(100),
			EffectiveDate				VARCHAR(100),
			EffectiveDateFrom			VARCHAR(100)
        )

        -- Insert DB data with sequential numbering
        INSERT INTO #DbData (
            RecordSL, Market, Terminal, City, State, ZipCode, Zone, 
			Prepulllocation1, Prepullcost1, Prepulllocation2, Prepullcost2, Prepulllocation3, Prepullcost3, 
			Prepulllocation4, Prepullcost4, Prepulllocation5, Prepullcost5, 
			Stopofflocation1, Stopoffcost1, Stopofflocation2, Stopoffcost2, Stopofflocation3, Stopoffcost3, 
			Stopofflocation4, Stopoffcost4, Stopofflocation5, Stopoffcost5, 
			YardshuttledirectionTO1, YardshuttledirectionFROM1, Yardshuttlecost1, 
			YardshuttledirectionTO2, YardshuttledirectionFROM2, Yardshuttlecost2, 
			TruckTypeA, TruckTypeABaseCost1, TruckTypeAFSF1, TruckTypeAFROM1, 
			TruckTypeABaseCost2, TruckTypeAFSF2, TruckTypeAFROM2, 
			TruckTypeABaseCost3, TruckTypeAFSF3, TruckTypeAFROM3, 
			TruckTypeB, TruckTypeBBaseCost1, TruckTypeBFSC1, TruckTypeBFROM1, 
			TruckTypeBBaseCost2, TruckTypeBFSC2, TruckTypeBFROM2, 
			TruckTypeBBaseCost3, TruckTypeBFSC3, TruckTypeBFROM3, 
			TruckTypeC, TruckTypeCBaseCost1, TruckTypeCFSC1, TruckTypeCFROM1, 
			TruckTypeCBaseCost2, TruckTypeCFSC2, TruckTypeCFROM2, 
			TruckTypeCBaseCost3, TruckTypeCFSC3, TruckTypeCFROM3, 
			TruckTypeD, TruckTypeDBaseCost1, TruckTypeDFSC1, TruckTypeDFROM1, 
			TruckTypeDBaseCost2, TruckTypeDFSC2, TruckTypeDFROM2, 
			TruckTypeDBaseCost3, TruckTypeDFSC3, TruckTypeDFROM3, 
			EffectiveDate, EffectiveDateFrom
        )
        SELECT 
            RecordSL, Market, Terminal, City, State, ZipCode, Zone, 
			Prepulllocation1, Prepullcost1, Prepulllocation2, Prepullcost2, Prepulllocation3, Prepullcost3, 
			Prepulllocation4, Prepullcost4, Prepulllocation5, Prepullcost5, 
			Stopofflocation1, Stopoffcost1, Stopofflocation2, Stopoffcost2, Stopofflocation3, Stopoffcost3, 
			Stopofflocation4, Stopoffcost4, Stopofflocation5, Stopoffcost5, 
			YardshuttledirectionTO1, YardshuttledirectionFROM1, Yardshuttlecost1, 
			YardshuttledirectionTO2, YardshuttledirectionFROM2, Yardshuttlecost2, 
			TruckTypeA, TruckTypeABaseCost1, TruckTypeAFSF1, TruckTypeAFROM1, 
			TruckTypeABaseCost2, TruckTypeAFSF2, TruckTypeAFROM2, 
			TruckTypeABaseCost3, TruckTypeAFSF3, TruckTypeAFROM3, 
			TruckTypeB, TruckTypeBBaseCost1, TruckTypeBFSC1, TruckTypeBFROM1, 
			TruckTypeBBaseCost2, TruckTypeBFSC2, TruckTypeBFROM2, 
			TruckTypeBBaseCost3, TruckTypeBFSC3, TruckTypeBFROM3, 
			TruckTypeC, TruckTypeCBaseCost1, TruckTypeCFSC1, TruckTypeCFROM1, 
			TruckTypeCBaseCost2, TruckTypeCFSC2, TruckTypeCFROM2, 
			TruckTypeCBaseCost3, TruckTypeCFSC3, TruckTypeCFROM3, 
			TruckTypeD, TruckTypeDBaseCost1, TruckTypeDFSC1, TruckTypeDFROM1, 
			TruckTypeDBaseCost2, TruckTypeDFSC2, TruckTypeDFROM2, 
			TruckTypeDBaseCost3, TruckTypeDFSC3, TruckTypeDFROM3, 
			EffectiveDate, EffectiveDateFrom
        FROM COST_FileUploadData_LongBeach
        WHERE FileProcessKey = @FileProcessKey
        --ORDER BY City 

		IF (@IsDebug = 1)
        BEGIN
            SELECT * from #DbData order by RecordSL
        END

        -- Verify row counts match
        DECLARE @JsonCount INT = (SELECT COUNT(*) FROM #JsonData)
        DECLARE @DbCount INT = (SELECT COUNT(*) FROM #DbData)

        IF @JsonCount <> @DbCount
        BEGIN
            SET @Status = 0
            SET @Reason = 'Row count mismatch: JSON has ' + CAST(@JsonCount AS VARCHAR) + 
                         ' rows, DB has ' + CAST(@DbCount AS VARCHAR)
            RETURN
        END

        -- Table to store mismatches
        DECLARE @MismatchResults TABLE (
            RowNum INT,
            FieldName VARCHAR(100),
            JsonValue VARCHAR(100),
            DbValue VARCHAR(100)
        )

        -- Loop to compare rows by position
        DECLARE @CurrentRow INT = 1
        DECLARE @MaxRow INT = (SELECT MAX(RowNum) FROM #JsonData)

        WHILE @CurrentRow <= @MaxRow
        BEGIN
            -- Compare all fields for this row
            INSERT INTO @MismatchResults
            SELECT 
                @CurrentRow,
                FieldName,
                JsonValue,
                DbValue
            FROM (
			SELECT		 'City' AS FieldName,
						j.City  AS JsonValue,
						d.City  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.City, '') <> ISNULL(d.City, '')
			UNION ALL	
			SELECT		 'EffectiveDate' AS FieldName,
						j.EffectiveDate  AS JsonValue,
						d.EffectiveDate  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.EffectiveDate, '') <> ISNULL(d.EffectiveDate, '')
			UNION ALL	
			SELECT		 'EffectiveDateFrom' AS FieldName,
						j.EffectiveDateFrom  AS JsonValue,
						d.EffectiveDateFrom  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.EffectiveDateFrom, '') <> ISNULL(d.EffectiveDateFrom, '')
			UNION ALL	
			SELECT		 'Market' AS FieldName,
						j.Market  AS JsonValue,
						d.Market  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Market, '') <> ISNULL(d.Market, '')
			UNION ALL	
			SELECT		 'Prepullcost1' AS FieldName,
						j.Prepullcost1  AS JsonValue,
						d.Prepullcost1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepullcost1, '') <> ISNULL(d.Prepullcost1, '')
			UNION ALL	
			SELECT		 'Prepullcost2' AS FieldName,
						j.Prepullcost2  AS JsonValue,
						d.Prepullcost2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepullcost2, '') <> ISNULL(d.Prepullcost2, '')
			UNION ALL	
			SELECT		 'Prepullcost3' AS FieldName,
						j.Prepullcost3  AS JsonValue,
						d.Prepullcost3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepullcost3, '') <> ISNULL(d.Prepullcost3, '')
			UNION ALL	
			SELECT		 'Prepullcost4' AS FieldName,
						j.Prepullcost4  AS JsonValue,
						d.Prepullcost4  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepullcost4, '') <> ISNULL(d.Prepullcost4, '')
			UNION ALL	
			SELECT		 'Prepullcost5' AS FieldName,
						j.Prepullcost5  AS JsonValue,
						d.Prepullcost5  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepullcost5, '') <> ISNULL(d.Prepullcost5, '')
			UNION ALL	
			SELECT		 'Prepulllocation1' AS FieldName,
						j.Prepulllocation1  AS JsonValue,
						d.Prepulllocation1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepulllocation1, '') <> ISNULL(d.Prepulllocation1, '')
			UNION ALL	
			SELECT		 'Prepulllocation2' AS FieldName,
						j.Prepulllocation2  AS JsonValue,
						d.Prepulllocation2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepulllocation2, '') <> ISNULL(d.Prepulllocation2, '')
			UNION ALL	
			SELECT		 'Prepulllocation3' AS FieldName,
						j.Prepulllocation3  AS JsonValue,
						d.Prepulllocation3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepulllocation3, '') <> ISNULL(d.Prepulllocation3, '')
			UNION ALL	
			SELECT		 'Prepulllocation4' AS FieldName,
						j.Prepulllocation4  AS JsonValue,
						d.Prepulllocation4  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepulllocation4, '') <> ISNULL(d.Prepulllocation4, '')
			UNION ALL	
			SELECT		 'Prepulllocation5' AS FieldName,
						j.Prepulllocation5  AS JsonValue,
						d.Prepulllocation5  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Prepulllocation5, '') <> ISNULL(d.Prepulllocation5, '')
			UNION ALL	
			SELECT		 'State' AS FieldName,
						j.State  AS JsonValue,
						d.State  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.State, '') <> ISNULL(d.State, '')
			UNION ALL	
			SELECT		 'Stopoffcost1' AS FieldName,
						j.Stopoffcost1  AS JsonValue,
						d.Stopoffcost1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopoffcost1, '') <> ISNULL(d.Stopoffcost1, '')
			UNION ALL	
			SELECT		 
						 'Stopoffcost2' AS FieldName,
						j.Stopoffcost2  AS JsonValue,
						d.Stopoffcost2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopoffcost2, '') <> ISNULL(d.Stopoffcost2, '')
			UNION ALL	
			SELECT		 
						 'Stopoffcost3' AS FieldName,
						j.Stopoffcost3  AS JsonValue,
						d.Stopoffcost3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopoffcost3, '') <> ISNULL(d.Stopoffcost3, '')
			UNION ALL	
			SELECT		 
						 'Stopoffcost4' AS FieldName,
						j.Stopoffcost4  AS JsonValue,
						d.Stopoffcost4  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopoffcost4, '') <> ISNULL(d.Stopoffcost4, '')
			UNION ALL	
			SELECT		 
						 'Stopoffcost5' AS FieldName,
						j.Stopoffcost5  AS JsonValue,
						d.Stopoffcost5  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopoffcost5, '') <> ISNULL(d.Stopoffcost5, '')
			UNION ALL	
			SELECT		 'Stopofflocation1' AS FieldName,
						j.Stopofflocation1  AS JsonValue,
						d.Stopofflocation1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopofflocation1, '') <> ISNULL(d.Stopofflocation1, '')
			UNION ALL	
			SELECT		     
						 'Stopofflocation2' AS FieldName,
						j.Stopofflocation2  AS JsonValue,
						d.Stopofflocation2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopofflocation2, '') <> ISNULL(d.Stopofflocation2, '')
			UNION ALL	
			SELECT		     
						 'Stopofflocation3' AS FieldName,
						j.Stopofflocation3  AS JsonValue,
						d.Stopofflocation3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopofflocation3, '') <> ISNULL(d.Stopofflocation3, '')
			UNION ALL	
			SELECT		     
						 'Stopofflocation4' AS FieldName,
						j.Stopofflocation4  AS JsonValue,
						d.Stopofflocation4  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopofflocation4, '') <> ISNULL(d.Stopofflocation4, '')
			UNION ALL	
			SELECT		     
						 'Stopofflocation5' AS FieldName,
						j.Stopofflocation5  AS JsonValue,
						d.Stopofflocation5  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Stopofflocation5, '') <> ISNULL(d.Stopofflocation5, '')
			UNION ALL	
			SELECT		 'Terminal' AS FieldName,
						j.Terminal  AS JsonValue,
						d.Terminal  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Terminal, '') <> ISNULL(d.Terminal, '')
			UNION ALL	
			SELECT		 'TruckTypeA' AS FieldName,
						j.TruckTypeA  AS JsonValue,
						d.TruckTypeA  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeA, '') <> ISNULL(d.TruckTypeA, '')
			UNION ALL	
			SELECT		 'TruckTypeABaseCost1' AS FieldName,
						j.TruckTypeABaseCost1  AS JsonValue,
						d.TruckTypeABaseCost1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeABaseCost1, '') <> ISNULL(d.TruckTypeABaseCost1, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeABaseCost2' AS FieldName,
						j.TruckTypeABaseCost2  AS JsonValue,
						d.TruckTypeABaseCost2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeABaseCost2, '') <> ISNULL(d.TruckTypeABaseCost2, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeABaseCost3' AS FieldName,
						j.TruckTypeABaseCost3  AS JsonValue,
						d.TruckTypeABaseCost3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeABaseCost3, '') <> ISNULL(d.TruckTypeABaseCost3, '')
			UNION ALL	
			SELECT		 'TruckTypeAFROM1' AS FieldName,
						j.TruckTypeAFROM1  AS JsonValue,
						d.TruckTypeAFROM1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeAFROM1, '') <> ISNULL(d.TruckTypeAFROM1, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeAFROM2' AS FieldName,
						j.TruckTypeAFROM2  AS JsonValue,
						d.TruckTypeAFROM2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeAFROM2, '') <> ISNULL(d.TruckTypeAFROM2, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeAFROM3' AS FieldName,
						j.TruckTypeAFROM3  AS JsonValue,
						d.TruckTypeAFROM3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeAFROM3, '') <> ISNULL(d.TruckTypeAFROM3, '')
			UNION ALL	
			SELECT		 'TruckTypeAFSF1' AS FieldName,
						j.TruckTypeAFSF1  AS JsonValue,
						d.TruckTypeAFSF1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeAFSF1, '') <> ISNULL(d.TruckTypeAFSF1, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeAFSF2' AS FieldName,
						j.TruckTypeAFSF2  AS JsonValue,
						d.TruckTypeAFSF2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeAFSF2, '') <> ISNULL(d.TruckTypeAFSF2, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeAFSF3' AS FieldName,
						j.TruckTypeAFSF3  AS JsonValue,
						d.TruckTypeAFSF3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeAFSF3, '') <> ISNULL(d.TruckTypeAFSF3, '')
			UNION ALL	
			SELECT		 'TruckTypeB' AS FieldName,
						j.TruckTypeB  AS JsonValue,
						d.TruckTypeB  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeB, '') <> ISNULL(d.TruckTypeB, '')
			UNION ALL	
			SELECT		 'TruckTypeBBaseCost1' AS FieldName,
						j.TruckTypeBBaseCost1  AS JsonValue,
						d.TruckTypeBBaseCost1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBBaseCost1, '') <> ISNULL(d.TruckTypeBBaseCost1, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeBBaseCost2' AS FieldName,
						j.TruckTypeBBaseCost2  AS JsonValue,
						d.TruckTypeBBaseCost2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBBaseCost2, '') <> ISNULL(d.TruckTypeBBaseCost2, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeBBaseCost3' AS FieldName,
						j.TruckTypeBBaseCost3  AS JsonValue,
						d.TruckTypeBBaseCost3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBBaseCost3, '') <> ISNULL(d.TruckTypeBBaseCost3, '')
			UNION ALL	
			SELECT		 'TruckTypeBFROM1' AS FieldName,
						j.TruckTypeBFROM1  AS JsonValue,
						d.TruckTypeBFROM1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBFROM1, '') <> ISNULL(d.TruckTypeBFROM1, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeBFROM2' AS FieldName,
						j.TruckTypeBFROM2  AS JsonValue,
						d.TruckTypeBFROM2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBFROM2, '') <> ISNULL(d.TruckTypeBFROM2, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeBFROM3' AS FieldName,
						j.TruckTypeBFROM3  AS JsonValue,
						d.TruckTypeBFROM3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBFROM3, '') <> ISNULL(d.TruckTypeBFROM3, '')
			UNION ALL	
			SELECT		 'TruckTypeBFSC1' AS FieldName,
						j.TruckTypeBFSC1  AS JsonValue,
						d.TruckTypeBFSC1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBFSC1, '') <> ISNULL(d.TruckTypeBFSC1, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeBFSC2' AS FieldName,
						j.TruckTypeBFSC2  AS JsonValue,
						d.TruckTypeBFSC2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBFSC2, '') <> ISNULL(d.TruckTypeBFSC2, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeBFSC3' AS FieldName,
						j.TruckTypeBFSC3  AS JsonValue,
						d.TruckTypeBFSC3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeBFSC3, '') <> ISNULL(d.TruckTypeBFSC3, '')
			UNION ALL	
			SELECT		 'TruckTypeC' AS FieldName,
						j.TruckTypeC  AS JsonValue,
						d.TruckTypeC  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeC, '') <> ISNULL(d.TruckTypeC, '')
			UNION ALL	
			SELECT		 'TruckTypeCBaseCost1' AS FieldName,
						j.TruckTypeCBaseCost1  AS JsonValue,
						d.TruckTypeCBaseCost1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCBaseCost1, '') <> ISNULL(d.TruckTypeCBaseCost1, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeCBaseCost2' AS FieldName,
						j.TruckTypeCBaseCost2  AS JsonValue,
						d.TruckTypeCBaseCost2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCBaseCost2, '') <> ISNULL(d.TruckTypeCBaseCost2, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeCBaseCost3' AS FieldName,
						j.TruckTypeCBaseCost3  AS JsonValue,
						d.TruckTypeCBaseCost3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCBaseCost3, '') <> ISNULL(d.TruckTypeCBaseCost3, '')
			UNION ALL	
			SELECT		 'TruckTypeCFROM1' AS FieldName,
						j.TruckTypeCFROM1  AS JsonValue,
						d.TruckTypeCFROM1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCFROM1, '') <> ISNULL(d.TruckTypeCFROM1, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeCFROM2' AS FieldName,
						j.TruckTypeCFROM2  AS JsonValue,
						d.TruckTypeCFROM2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCFROM2, '') <> ISNULL(d.TruckTypeCFROM2, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeCFROM3' AS FieldName,
						j.TruckTypeCFROM3  AS JsonValue,
						d.TruckTypeCFROM3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCFROM3, '') <> ISNULL(d.TruckTypeCFROM3, '')
			UNION ALL	
			SELECT		 'TruckTypeCFSC1' AS FieldName,
						j.TruckTypeCFSC1  AS JsonValue,
						d.TruckTypeCFSC1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCFSC1, '') <> ISNULL(d.TruckTypeCFSC1, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeCFSC2' AS FieldName,
						j.TruckTypeCFSC2  AS JsonValue,
						d.TruckTypeCFSC2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCFSC2, '') <> ISNULL(d.TruckTypeCFSC2, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeCFSC3' AS FieldName,
						j.TruckTypeCFSC3  AS JsonValue,
						d.TruckTypeCFSC3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeCFSC3, '') <> ISNULL(d.TruckTypeCFSC3, '')
			UNION ALL	
			SELECT		 'TruckTypeD' AS FieldName,
						j.TruckTypeD  AS JsonValue,
						d.TruckTypeD  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeD, '') <> ISNULL(d.TruckTypeD, '')
			UNION ALL	
			SELECT		 'TruckTypeDBaseCost1' AS FieldName,
						j.TruckTypeDBaseCost1  AS JsonValue,
						d.TruckTypeDBaseCost1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDBaseCost1, '') <> ISNULL(d.TruckTypeDBaseCost1, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeDBaseCost2' AS FieldName,
						j.TruckTypeDBaseCost2  AS JsonValue,
						d.TruckTypeDBaseCost2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDBaseCost2, '') <> ISNULL(d.TruckTypeDBaseCost2, '')
			UNION ALL	
			SELECT		        
						 'TruckTypeDBaseCost3' AS FieldName,
						j.TruckTypeDBaseCost3  AS JsonValue,
						d.TruckTypeDBaseCost3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDBaseCost3, '') <> ISNULL(d.TruckTypeDBaseCost3, '')
			UNION ALL	
			SELECT		 'TruckTypeDFROM1' AS FieldName,
						j.TruckTypeDFROM1  AS JsonValue,
						d.TruckTypeDFROM1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDFROM1, '') <> ISNULL(d.TruckTypeDFROM1, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeDFROM2' AS FieldName,
						j.TruckTypeDFROM2  AS JsonValue,
						d.TruckTypeDFROM2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDFROM2, '') <> ISNULL(d.TruckTypeDFROM2, '')
			UNION ALL	
			SELECT		    
						 'TruckTypeDFROM3' AS FieldName,
						j.TruckTypeDFROM3  AS JsonValue,
						d.TruckTypeDFROM3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDFROM3, '') <> ISNULL(d.TruckTypeDFROM3, '')
			UNION ALL	
			SELECT		 'TruckTypeDFSC1' AS FieldName,
						j.TruckTypeDFSC1  AS JsonValue,
						d.TruckTypeDFSC1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDFSC1, '') <> ISNULL(d.TruckTypeDFSC1, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeDFSC2' AS FieldName,
						j.TruckTypeDFSC2  AS JsonValue,
						d.TruckTypeDFSC2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDFSC2, '') <> ISNULL(d.TruckTypeDFSC2, '')
			UNION ALL	
			SELECT		   
						 'TruckTypeDFSC3' AS FieldName,
						j.TruckTypeDFSC3  AS JsonValue,
						d.TruckTypeDFSC3  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.TruckTypeDFSC3, '') <> ISNULL(d.TruckTypeDFSC3, '')
			UNION ALL	
			SELECT		 'Yardshuttlecost1' AS FieldName,
						j.Yardshuttlecost1  AS JsonValue,
						d.Yardshuttlecost1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Yardshuttlecost1, '') <> ISNULL(d.Yardshuttlecost1, '')
			UNION ALL	
			SELECT		     
						 'Yardshuttlecost2' AS FieldName,
						j.Yardshuttlecost2  AS JsonValue,
						d.Yardshuttlecost2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Yardshuttlecost2, '') <> ISNULL(d.Yardshuttlecost2, '')
			UNION ALL	
			SELECT		 'YardshuttledirectionFROM1' AS FieldName,
						j.YardshuttledirectionFROM1  AS JsonValue,
						d.YardshuttledirectionFROM1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.YardshuttledirectionFROM1, '') <> ISNULL(d.YardshuttledirectionFROM1, '')
			UNION ALL	
			SELECT		              
						 'YardshuttledirectionFROM2' AS FieldName,
						j.YardshuttledirectionFROM2  AS JsonValue,
						d.YardshuttledirectionFROM2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.YardshuttledirectionFROM2, '') <> ISNULL(d.YardshuttledirectionFROM2, '')
			UNION ALL	
			SELECT		 'YardshuttledirectionTO1' AS FieldName,
						j.YardshuttledirectionTO1  AS JsonValue,
						d.YardshuttledirectionTO1  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.YardshuttledirectionTO1, '') <> ISNULL(d.YardshuttledirectionTO1, '')
			UNION ALL	
			SELECT		            
						 'YardshuttledirectionTO2' AS FieldName,
						j.YardshuttledirectionTO2  AS JsonValue,
						d.YardshuttledirectionTO2  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.YardshuttledirectionTO2, '') <> ISNULL(d.YardshuttledirectionTO2, '')
			UNION ALL	
			SELECT		 'ZipCode' AS FieldName,
						j.ZipCode  AS JsonValue,
						d.ZipCode  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.ZipCode, '') <> ISNULL(d.ZipCode, '')
			UNION ALL	
			SELECT		 'Zone' AS FieldName,
						j.Zone  AS JsonValue,
						d.Zone  AS DbValue
						FROM #JsonData j
						INNER JOIN #DbData d ON j.RowNum = d.RecordSL
						WHERE j.RowNum = @CurrentRow
						AND ISNULL(j.Zone, '') <> ISNULL(d.Zone, '')
                
            ) AS Comparisons

            SET @CurrentRow = @CurrentRow + 1
        END

        -- Check for any mismatches
        IF EXISTS (SELECT 1 FROM @MismatchResults)
        BEGIN
            SET @Status = 0
            SELECT @Reason = STRING_AGG(
                'Row ' + CAST(RowNum AS VARCHAR) + ': ' + FieldName + 
                ' (JSON: ' + ISNULL(JsonValue, 'NULL') + 
                ', DB: ' + ISNULL(DbValue, 'NULL') + ')', 
                ' | '
            ) FROM @MismatchResults
            
            IF @IsDebug = 1
            BEGIN
                SELECT * FROM @MismatchResults
            END
        END
        ELSE
        BEGIN
            SET @Status = 1
            SET @Reason = 'All fields match in all rows'
        END

        DROP TABLE #JsonData
        DROP TABLE #DbData

		--If (@Status = 1)
		--BEGIN

		--END

    END TRY
    BEGIN CATCH   
        SET @Status = 0;
        SET @Reason = 'X: ' + ERROR_MESSAGE();
    END CATCH
END
