/*
DECLARE @UserKey INT = 951, 
        @JSONString NVARCHAR(MAX), 
        @IsDebug BIT = 1,
        @Status BIT=0,
	    @Reason VARCHAR(100)=''
SET @JSONString = '{}'

EXEC [Container_GetLocationList] @UserKey, @JSONString, @IsDebug, @Status OUTPUT, @Reason OUTPUT 
SELECT @Status Status, @Reason Reason

*/
CREATE PROCEDURE [dbo].[Container_GetLocationList]
(
	@UserKey	INT = 951,
	@JSONString	NVARCHAR(MAX) = '',
	@IsDebug	BIT = 0,
    @Status     BIT = 0 OUTPUT,
    @Reason     VARCHAR(100) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	BEGIN TRY

		/*==================================================================
			1. Validate input JSON
		==================================================================*/

		--IF (ISNULL(@JSONString, '') = '')
		--BEGIN
		--	SET @IntError = 'JSON string cannot be blank';
		--	RETURN;
		--END

		/*==================================================================
			2. Parse the JSON input into variables
		==================================================================*/


		/*==================================================================
			3. Validate required fields
		==================================================================*/

		-- Necessary Validations

		/*==================================================================
			4. Begin transaction after validations
		==================================================================*/

		BEGIN TRANSACTION;

		-- ================================
		-- Main Business Logic goes here
		-- ================================
		
		DECLARE @JSONResult NVARCHAR(MAX) = ''

        -- SET @JSONResult = (
        --     SELECT LocationText
        --         FROM (
        --             SELECT DISTINCT 'FROM ' + LC.LocationConvert AS LocationText
        --             FROM leg L
        --             INNER JOIN LocationConversion LC ON LC.[Location] = L.FROMLocation

        --             UNION

        --             SELECT DISTINCT 'TO ' + LC.LocationConvert AS LocationText
        --             FROM leg L
        --             INNER JOIN LocationConversion LC ON LC.[Location] = L.ToLocation
        --         ) AS LocationList
        --     FOR JSON PATH
        -- );

        SELECT @JSONResult = 
            JSON_QUERY(
                '[' + STRING_AGG('"' + LocationText + '"', ',') + ']'
            )
        FROM (
            SELECT DISTINCT 'From ' + LC.LocationConvert AS LocationText
            FROM leg L
            INNER JOIN LocationConversion LC ON LC.[Location] = L.FROMLocation

            UNION

            SELECT DISTINCT 'To ' + LC.LocationConvert AS LocationText
            FROM leg L
            INNER JOIN LocationConversion LC ON LC.[Location] = L.ToLocation
        ) LocationList;

		SELECT @JSONResult AS JSONResult

		/*==================================================================
			5. Set success response
		==================================================================*/

		SET @Status = 1;
		SET @Reason = 'Success';

		/*==================================================================
			6. Commit transaction
		==================================================================*/

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		-- Roll back the transaction if it was started------------------------------------------------------------
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		-- Set error output ---------------------------------------------------------------------------------------
		SET @Status = 0;
		SET @Reason = ERROR_MESSAGE();
	END CATCH
END

