
/*
DECLARE @Status BIT, @IntMsg VARCHAR(500), @ExtMsg VARCHAR(500)

EXEC dbo.DA_CheckAppVersionStatus  @AppVersion = '', @AppStatus = @Status OUTPUT, @IntMessage = @IntMsg OUTPUT,@ExtMessage = @ExtMsg OUTPUT

SELECT @Status AS AppStatus, @IntMsg AS IntMessage, @ExtMsg AS ExtMessage
*/

CREATE PRocedure [dbo].[DA_CheckAppVersionStatus]
(
	@AppVersion VARCHAR(20),
    @AppStatus BIT OUTPUT,
    @IntMessage VARCHAR(500) OUTPUT,
    @ExtMessage VARCHAR(500) OUTPUT
)
AS
BEGIN
    DECLARE @CNT INT = 0
    DECLARE @ReleaseDate DATETIME

    -- Set latest release date
    SELECT @ReleaseDate = MAX(ReleaseDate) FROM DA_AppReleaseDetail

    SET @AppVersion = ISNULL(@AppVersion, '')

    -- Get count of matching records
    SELECT @CNT = COUNT(*) 
    FROM DA_AppReleaseDetail
    WHERE AppVersion = @AppVersion 
      AND ReleaseDate = @ReleaseDate

    SET @CNT = ISNULL(@CNT, 0)

    -- Default values
    SET @AppStatus = 1
    SET @IntMessage = ''
    SET @ExtMessage = ''

    IF (@AppVersion = '')
    BEGIN
        SET @AppStatus = 0
        SET @IntMessage = 'AppVersion Cannot be Blank'
        SET @ExtMessage = 'Something Went Wrong , Contact System Administrator'
    END
    ELSE IF (@CNT <> 1)
    BEGIN
        SET @AppStatus = 0
        SET @IntMessage = 'Kindly Update the App to the latest version'
        SET @ExtMessage = @IntMessage
    END
END
