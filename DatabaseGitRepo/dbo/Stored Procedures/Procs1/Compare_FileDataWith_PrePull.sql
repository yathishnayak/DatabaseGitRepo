/*

DECLARE @UserKey INT = 950, @Status BIT, @Reason VARCHAR(500), @JsonInput NVARCHAR(MAX), @IsDebug INT = 1;
SET @JsonInput = '{"FileProcessKey":148}';
EXEC [CompareFileDataWith_PrePull] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/
CREATE PROCEDURE [dbo].[Compare_FileDataWith_PrePull]
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
				Prepulllocation1 AS PrepullLocation, 
				CAST(IsNull(Prepullcost1,0) AS DECIMAL(10,2)) AS Prepullcost
			FROM COST_FileUploadData_LongBeach
			UNION ALL
			SELECT 
				FileProcesskey, 
				RecordSL, 
				Prepulllocation2 AS PrepullLocation, 
				CAST(IsNull(Prepullcost2,0) AS DECIMAL(10,2)) AS Prepullcost
			FROM COST_FileUploadData_LongBeach
			UNION ALL
			SELECT 
				FileProcesskey, 
				RecordSL, 
				Prepulllocation3 AS PrepullLocation, 
				CAST(IsNull(Prepullcost3,0) AS DECIMAL(10,2)) AS Prepullcost
			FROM COST_FileUploadData_LongBeach
			UNION ALL
			SELECT 
				FileProcesskey, 
				RecordSL, 
				Prepulllocation4 AS PrepullLocation, 
				CAST(IsNull(Prepullcost4,0) AS DECIMAL(10,2)) AS Prepullcost
			FROM COST_FileUploadData_LongBeach
			UNION ALL
			SELECT 
				FileProcesskey, 
				RecordSL, 
				Prepulllocation5 AS PrepullLocation, 
				CAST(IsNull(Prepullcost5,0) AS DECIMAL(10,2)) AS Prepullcost
			FROM COST_FileUploadData_LongBeach
		)
		SELECT 
			u.FileProcesskey, 
			u.RecordSL, 
			u.Prepulllocation AS FilePrepulllocation, 
			c.Prepulllocation AS CostDataOutputPrepulllocation,
			CASE 
				WHEN u.Prepulllocation = c.Prepulllocation THEN 'Match'
				ELSE 'Mismatch'
			END AS BaseCostComparison,
			u.Prepullcost AS FilePrepullcost,
			c.PrepullCost AS CostDataOutputPrepullcost,
			CASE 
				WHEN u.Prepullcost = c.PrepullCost THEN 'Match'
				ELSE 'Mismatch'
			END AS PrepullCostComparison
		FROM Unpivoted u
		JOIN COST_CostDataOutput_Prepull c 
			ON u.FileProcesskey = c.FileProcesskey
			AND u.RecordSL = c.RecordSL
			AND u.PrepullLocation = c.Prepulllocation
		WHERE u.FileProcesskey = @FileProcessKey
		ORDER BY u.PrepullLocation;

            SET @Status = 1
            SET @Reason = 'Prepull Comparison Successful!'

    END TRY
    BEGIN CATCH   
        SET @Status = 0;
        SET @Reason = 'Prepull: ' + ERROR_MESSAGE();
    END CATCH
END
