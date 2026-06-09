
/*
DECLARE 	@AppVersion VARCHAR(20) = 'v2.0.1[UAT]',@Status BIT ,@Message VARCHAR(500) 
EXEC		DA_CheckAppVersion @AppVersion, @Status OUTPUT, @Message OUTPUT
SELECT		@Status, @Message
*/

CREATE PROCEDURE [dbo].[DA_CheckAppVersion] -- DA_CheckAppVersion 'ddd'
(
	@AppVersion VARCHAR(20),
	@Status BIT OUTPUT,
	@Message VARCHAR(500) OUTPUT
)

AS

BEGIN
	DECLARE @RecentVersion VARCHAR(20) = '' 
	
	SET @Status = 1
	SET @Message = ''


	SET @RecentVersion =  (SELECT AppVersion FROM DA_AppReleaseDetail WHERE ReleaseDate IN (SELECT MAX(releaseDate) FROM DA_AppReleaseDetail))

	SET @AppVersion = ISNULL(@AppVersion,'')
	SET @RecentVersion = ISNULL(@RecentVersion,'')

	IF(@AppVersion <> @RecentVersion)
		BEGIN
			SET @Status = 0
			SET @Message = 'Update the App to the latest Version'
		END
END
