/*

DECLARE @UserKey INT = 950, @Status BIT, @Reason VARCHAR(500), @JsonInput NVARCHAR(MAX), @IsDebug INT = 1;
SET @JsonInput = '{"FileProcessKey":148}';
EXEC [CompareFileDataWith_StopOff] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/
CREATE PROCEDURE [dbo].[Compare_FileDataWith_StopOff]
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
		        StopOffLocation1 AS StopOffLocation, 
		        CAST(IsNull(StopOffcost1,0) AS DECIMAL(10,2)) AS StopOffcost
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        StopOffLocation2 AS StopOffLocation, 
		        CAST(IsNull(StopOffcost2,0) AS DECIMAL(10,2)) AS StopOffcost
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        StopOffLocation3 AS StopOffLocation, 
		        CAST(IsNull(StopOffcost3,0) AS DECIMAL(10,2)) AS StopOffcost
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        StopOffLocation4 AS StopOffLocation, 
		        CAST(IsNull(StopOffcost4,0) AS DECIMAL(10,2)) AS StopOffcost
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
		    SELECT 
		        FileProcesskey, 
		        RecordSL, 
		        StopOffLocation5 AS StopOffLocation, 
		        CAST(IsNull(StopOffcost5,0) AS DECIMAL(10,2)) AS StopOffcost
		    FROM COST_FileUploadData_LongBeach
		)
		SELECT 
		    u.FileProcesskey, 
		    u.RecordSL, 
		    u.StopOffLocation AS FileStopOffLocation, 
		    c.StopOffLocation AS CostDataOutputStopOffLocation,
		    CASE 
		        WHEN u.StopOffLocation = c.StopOffLocation THEN 'Match'
		        ELSE 'Mismatch'
		    END AS BaseCostComparison,
		    u.StopOffcost AS FileStopOffcost,
		    c.StopOffCost AS CostDataOutputStopOffcost,
		    CASE 
		        WHEN u.StopOffcost = c.StopOffCost THEN 'Match'
		        ELSE 'Mismatch'
		    END AS StopOffCostComparison
		FROM Unpivoted u
		JOIN COST_CostDataOutput_StopOff c 
		    ON u.FileProcesskey = c.FileProcesskey  
		    AND u.StopOffLocation = c.StopOffLocation
		WHERE u.FileProcesskey = @FileProcessKey
		ORDER BY u.StopOffLocation;

            SET @Status = 1
            SET @Reason = 'StopOff Comparison Successful!'

    END TRY
    BEGIN CATCH   
        SET @Status = 0;
        SET @Reason = 'StopOff: ' + ERROR_MESSAGE();
    END CATCH
END
