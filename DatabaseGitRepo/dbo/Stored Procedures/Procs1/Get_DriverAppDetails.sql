/*
DECLARE 
    @UserKey INT = 953,
    @JSONString NVARCHAR(MAX)= '{
        "DriverTag": "Rene Cazares"
    }',
    @Status BIT = 1,
    @Reason VARCHAR(1000) = '',
    @IsDebug BIT = 0

EXEC [Get_DriverAppDetails] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status, @Reason
*/

CREATE  PROCEDURE [dbo].[Get_DriverAppDetails]
(
    @UserKey        INT = 0,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    IF (ISNULL(LTRIM(RTRIM(@JSONString)), '') = '')
    BEGIN
        SET @Status = 0
        SET @Reason = 'Parameters not found'
        RETURN
    END

  
    DECLARE 
        @DriverTag     VARCHAR(100),
        @DriverUserKey INT,
        @DriverAppKey  UNIQUEIDENTIFIER = '1B51350D-9554-4D37-80C7-DECA1730592E'

   
    SELECT 
        @DriverTag = DriverTag
    FROM OPENJSON(@JSONString)
    WITH
    (
        DriverTag VARCHAR(100) '$.DriverTag'
    )


    SELECT @DriverUserKey = UserKey
    FROM [User] WITH (NOLOCK)
    WHERE UserName = @DriverTag

    IF ISNULL(@DriverUserKey, 0) = 0
    BEGIN
        SET @Status = 0
        SET @Reason = 'Driver not found'
        RETURN
    END


    IF @IsDebug = 1
    BEGIN
        SELECT @DriverUserKey AS DriverUserKey
    END

    SELECT 
        AppKey        = UF.AppID,
        DeviceID      = UF.DeviceID,
        UserKey       = UF.UserKey,
        FirebaseToken = UF.FirebaseToken
    FROM UserFirebase UF WITH (NOLOCK)
    WHERE UF.UserKey = @DriverUserKey
      AND UF.AppID = @DriverAppKey
	FOR JSON PATH

    SET @Status = 1
    SET @Reason = 'Success'

END