

/*

DECLARE @UserKey INT = 714,@JSONString NVARCHAR(MAX), @IsDebug BIT = 0,@Status BIT	= 0, @IntError VARCHAR(1000) ,
	@ExtError VARCHAR(1000) ,@Result1 VARCHAR(200) ,	@Result2 VARCHAR(200) ,@Result3 VARCHAR(500)
	SET @JSONString = '{"RouteKey":185450,"Latitude":"13.346142","Longitude":"74.762551"}'

EXEC Procedure_Format @UserKey ,@JSONString , @IsDebug ,@Status OUTPUT, @IntError OUTPUT,	@ExtError OUTPUT,@Result1 OUTPUT, @Result2 OUTPUT,@Result3 OUTPUT
SELECT @Status Status , @IntError IntError ,	@ExtError ExtError ,@Result1 Result1 , @Result2 Result2 ,@Result3 Result3

*/
CREATE PROCEDURE [dbo].[Procedure_Format]
(
	@UserKey	INT = 714,
	@JSONString	NVARCHAR(MAX) = '{"RouteKey":185450,"Latitude":"13.346142","Longitude":"74.762551"}',
	@IsDebug	BIT = 0,
	@Param1		VARCHAR(500),
	@Param2		VARCHAR(500),
	@Param3		VARCHAR(500),

	@IsSuccess	BIT				= 0	 OUTPUT,
	@IntError	VARCHAR(1000)	= '' OUTPUT,
	@ExtError	VARCHAR(1000)	= '' OUTPUT,
	@Result1	VARCHAR(200)	= '' OUTPUT,
	@Result2	VARCHAR(200)	= '' OUTPUT,
	@Result3	VARCHAR(500)	= '' OUTPUT 
)
AS
BEGIN
	SET NOCOUNT ON;

	-- Initialize default output values
	SET @ExtError  = 'Something went wrong, Contact system administrator';
	SET @IsSuccess = 0;

	DECLARE  @RouteKey INT,@Latitude VARCHAR(50),@Longitude VARCHAR(50);

	BEGIN TRY

		/*==================================================================
			1. Validate input JSON
		==================================================================*/

		IF (ISNULL(@JSONString, '') = '')
		BEGIN
			SET @IntError = 'JSON string cannot be blank';
			RETURN;
		END

		/*==================================================================
			2. Parse the JSON input into variables
		==================================================================*/

		SELECT 	@RouteKey = RouteKey, @Latitude = Latitude, @Longitude = Longitude
		FROM	OPENJSON(@JSONString)
				WITH (
					RouteKey	INT			'$.RouteKey',
					Latitude	VARCHAR(50)	'$.Latitude',
					Longitude	VARCHAR(50)	'$.Longitude'
				);

		/*==================================================================
			3. Validate required fields
		==================================================================*/

		IF (@RouteKey IS NULL OR @RouteKey = 0)
		BEGIN
			SET @IntError = 'RouteKey cannot be 0 or null';
			RETURN;
		END

		IF (LTRIM(RTRIM(ISNULL(@Latitude, ''))) = '')
		BEGIN
			SET @IntError = 'Latitude cannot be blank';
			RETURN;
		END

		IF (LTRIM(RTRIM(ISNULL(@Longitude, ''))) = '')
		BEGIN
			SET @IntError = 'Longitude cannot be blank';
			RETURN;
		END

		/*==================================================================
			4. Begin transaction after validations
		==================================================================*/

		BEGIN TRANSACTION;

		-- ================================
		-- Main Business Logic goes here
		-- ================================
		-- Example: INSERT/UPDATE/DELETE

		/*==================================================================
			5. Set success response
		==================================================================*/

		SET @IsSuccess = 1;
		SET @IntError = 'Success';
		SET @ExtError = @IntError;

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
		SET @IsSuccess = 0;
		SET @IntError = ERROR_MESSAGE();
		SET @ExtError = 'Error occurred during processing.';
	END CATCH
END

