/*

DECLARE @UserKey INT = 950, @Status BIT, @Reason VARCHAR(500), @JsonInput NVARCHAR(MAX), @IsDebug INT = 1;
SET @JsonInput = '{"FileProcessKey":146}';
EXEC [CompareFileDataWith_YardShuttle] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/
CREATE PROCEDURE [dbo].[Compare_FileDataWith_YardShuttle]
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
				City,
				State,
		        YardshuttledirectionFROM1 AS YardFrom, 
		        YardshuttledirectionTO1 AS YardTo,
		        CAST(IsNull(Yardshuttlecost1,0) AS DECIMAL(10,2)) AS YardCost
		    FROM COST_FileUploadData_LongBeach
		    UNION ALL
			SELECT 
		        FileProcesskey, 
		        RecordSL,
				City,
				State,
		        YardshuttledirectionFROM2, 
		        YardshuttledirectionTO2,
		        CAST(IsNull(Yardshuttlecost2,0) AS DECIMAL(10,2))
		    FROM COST_FileUploadData_LongBeach
		)
		SELECT 
		    u.FileProcesskey, 
		    u.RecordSL,
			u.City,
			u.State,
		    u.YardFrom,
			u.YardTo,
		    u.YardCost AS FileUploadYardCost, 
		    c.YardCost AS CostDataOutputYardCost,
		    CASE 
		        WHEN u.YardCost = c.YardCost THEN 'Match'
		        ELSE 'Mismatch'
		    END AS YardCostComparison
		FROM Unpivoted u
		JOIN COST_CostDataOutput_YardShuttle c 
		    ON u.FileProcesskey = c.FileProcesskey 
			AND u.RecordSL = c.RecordSL
		    AND u.City = c.City
		    AND u.State = c.State
		    AND u.YardFrom = c.YardFrom
		    AND u.YardTo = c.YardTo
		WHERE u.FileProcesskey = @FileProcessKey;

            SET @Status = 1
            SET @Reason = 'YardShuttle Comparison Successful!'
    END TRY
    BEGIN CATCH   
        SET @Status = 0;
        SET @Reason = 'YardShuttle: ' + ERROR_MESSAGE();
    END CATCH
END
