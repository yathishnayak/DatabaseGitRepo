/*
DECLARE 
	@UserKey INT = 951, 
	@JSONString NVARCHAR(MAX) = '{"LineKey":0,"ScacCode":"11","LineName":"AA","IsActive":true}',
	@Status BIT = 0,
	@Reason VARCHAR(1000), 
	@IsDebug BIT = 1 
EXEC [SteamShipLine_InsertUpdate_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[SteamShipLine_InsertUpdate_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS

BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF
 
	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;
 
	DECLARE @LineKey		INT,
			@LineName		VARCHAR(100),
			@ScacCode       VARCHAR(30),
			@IsActive		BIT = 0

	SELECT  @LineKey  = LineKey,
			@LineName = LineName,
			@ScacCode = ScacCode,
			@IsActive = IsActive
	FROM OpenJSON(@JSONString, '$')
	WITH (
		LineKey			    INT					'$.LineKey',
		LineName			VARCHAR(100)		'$.LineName',
		ScacCode			VARCHAR(30)		    '$.ScacCode',
		IsActive			BIT					'$.IsActive'
	)

	BEGIN TRY
	IF EXISTS (
        SELECT 1
        FROM SteamShipLine
        WHERE LineName = @LineName
          AND LineKey <> ISNULL(@LineKey,0)
    )
    BEGIN
        SET @Status = 0
        SET @Reason = 'Steamship Line Already Exist'
        RETURN
    END

	IF (ISNULL(@LineKey,0) = 0)
	BEGIN
		INSERT INTO SteamShipLine (LineName,ScacCode,IsActive, CreateUser, CreateDate)
		SELECT @LineName,@ScacCode,@IsActive, @UserKey, GETDATE()
		SET @LineKey = SCOPE_IDENTITY();

		 SET @Status = 1
		 SET @Reason = 'Steamship Line Created successfully'  

	END
	ELSE
	BEGIN
		UPDATE SteamShipLine 
		SET
			LineName = @LineName,
			ScacCode = @ScacCode,
			IsActive = @IsActive,
			UpdateDate = GETDATE(),
			UpdateUser = @UserKey
		WHERE LineKey = @LineKey

		 SET @Status = 1
		 SET @Reason = 'Steamship Line Updated successfully'
	END


	END TRY
	BEGIN CATCH
		SET @Status = 0
		SET @Reason = ERROR_MESSAGE()
	END CATCH

END