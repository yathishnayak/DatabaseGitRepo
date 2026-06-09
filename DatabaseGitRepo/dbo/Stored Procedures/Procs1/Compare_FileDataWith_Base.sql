/*

DECLARE @UserKey INT = 950, @Status BIT, @Reason VARCHAR(500), @JsonInput NVARCHAR(MAX), @IsDebug INT = 1;
SET @JsonInput = '{"FileProcessKey":147}';
EXEC [CompareFileDataWith_Base] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/
CREATE PROCEDURE [dbo].[Compare_FileDataWith_Base]
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
            SET @Reason = 'Missing FileProcessKey';
            RETURN;
        END;

		WITH Unpivoted AS (
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company - Asset' AS DriverType, 
		        TruckTypeAFROM1 AS YardPortType, 
		        CAST(IsNull(TruckTypeABaseCost1,0) AS DECIMAL(10,2)) AS BaseCost,
		        CAST(IsNull(TruckTypeAFSF1,0) AS DECIMAL(10,2)) AS FSFCost
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company - Asset', 
		        TruckTypeAFROM2, 
		        CAST(IsNull(TruckTypeABaseCost2,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeAFSF2,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company - Asset', 
		        TruckTypeAFROM3, 
		        CAST(IsNull(TruckTypeABaseCost3,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeAFSF3,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company - EV', 
		        TruckTypeDFROM1, 
		        CAST(IsNull(TruckTypeDBaseCost1,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeDFSC1,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company - EV', 
		        TruckTypeDFROM2, 
		        CAST(IsNull(TruckTypeDBaseCost2,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeDFSC2,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company - EV', 
		        TruckTypeDFROM3, 
		        CAST(IsNull(TruckTypeDBaseCost3,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeDFSC3,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Broker Carrier', 
		        TruckTypeBFROM1, 
		        CAST(IsNull(TruckTypeBBaseCost1,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeBFSC1,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Broker Carrier', 
		        TruckTypeBFROM2, 
		        CAST(IsNull(TruckTypeBBaseCost2,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeBFSC2,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Broker Carrier', 
		        TruckTypeBFROM3, 
		        CAST(IsNull(TruckTypeBBaseCost3,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeBFSC3,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company  - Owner Operator', 
		        TruckTypeCFROM1, 
		        CAST(IsNull(TruckTypeCBaseCost1,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeCFSC1,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company  - Owner Operator', 
		        TruckTypeCFROM2, 
		        CAST(IsNull(TruckTypeCBaseCost2,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeCFSC2,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        'Company  - Owner Operator', 
		        TruckTypeCFROM3, 
		        CAST(IsNull(TruckTypeCBaseCost3,0) AS DECIMAL(10,2)),
		        CAST(IsNull(TruckTypeCFSC3,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		)
		SELECT 
		    u.FileProcesskey, 
		    u.RecordSL, 
		    u.DriverType, 
		    u.YardPortType,
		    u.BaseCost AS FileUploadCost, 
		    c.Cost AS CostDataOutputCost,
		    CASE 
		        WHEN u.BaseCost = c.Cost THEN 'Match'
		        ELSE 'Mismatch'
		    END AS BaseCostComparison,
		    u.FSFCost AS FileUploadFSFCost,
		    c.FSFCost AS CostDataOutputFSFCost,
		    CASE 
		        WHEN u.FSFCost = c.FSFCost THEN 'Match'
		        ELSE 'Mismatch'
		    END AS FSFCostComparison
		FROM Unpivoted u
		JOIN COST_CostDataOutput c 
		    ON u.FileProcesskey = c.FileProcesskey  
		    AND u.DriverType = c.DriverType
		    AND u.YardPortType = c.YardPortType
		WHERE u.FileProcesskey = @FileprocessKey
		ORDER BY DriverType;

            SET @Status = 1
            SET @Reason = 'Base Comparison Successful!'

    END TRY
    BEGIN CATCH   
        SET @Status = 0;
        SET @Reason = 'Base: ' + ERROR_MESSAGE();
    END CATCH
END
