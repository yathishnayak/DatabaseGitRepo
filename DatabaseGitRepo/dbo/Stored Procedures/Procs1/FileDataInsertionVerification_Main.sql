/*

DECLARE @UserKey INT = 950, @Status BIT, @Reason VARCHAR(500), @JsonInput NVARCHAR(MAX), @IsDebug INT = 0;
SET @JsonInput = '{"FileProcessKey":148}';
EXEC [FileDataInsertionVerification_Main] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason;

*/

CREATE PROCEDURE [dbo].[FileDataInsertionVerification_Main]
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
	BEGIN TRANSACTION;

        DECLARE @FileProcessKey INT = JSON_VALUE(@JsonInput, '$.FileProcessKey');

        IF @FileProcessKey IS NULL
        BEGIN
            SET @Status = 0;
            SET @Reason = 'Missing FileProcessKey';
            ROLLBACK TRANSACTION;  
            RETURN;
        END;

        -- Execute child procedures
        EXEC [Compare_FileDataInsertionVerification] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug;
		Select @Status Status, @Reason Reason;
        IF @Status = 1
        BEGIN
            EXEC [Compare_FileDataWith_Base] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug;
            Select @Status Status, @Reason Reason

            EXEC [Compare_FileDataWith_Prepull] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug;
            Select @Status Status, @Reason Reason

            EXEC [Compare_FileDataWith_StopOff] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug;
            Select @Status Status, @Reason Reason

            EXEC [Compare_FileDataWith_YardShuttle] @UserKey, @JsonInput, @Status OUTPUT, @Reason OUTPUT, @IsDebug;
            Select @Status Status, @Reason Reason

            SET @Status = 1;
            SET @Reason = 'Validation Successful!';
        END;
        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END;
