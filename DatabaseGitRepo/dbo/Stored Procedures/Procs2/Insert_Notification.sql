/*
DECLARE 
    @UserKey INT = 1044,
    @JSONString NVARCHAR(MAX)= '{
        "Title": "Message from JCB",
        "Message": "LOAD OUT OF 3 Harbors AT 05/03/2026 00:01 :: NA :: LIVE UNLOAD AT Acer American Corporation (IPG-JCB) BY 05/03/2026 00:01 :: 1730 N. 1st Street Suite 400, -, San Jose, CA-95112USA :: IMPT2600913 20 HC...",
        "DriverTag": "test 123"
    }',
    @Status BIT = 0,
    @Reason VARCHAR(1000) = '',
    @IsDebug BIT = 0

EXEC [Insert_Notification] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status, @Reason
*/


CREATE PROCEDURE [dbo].[Insert_Notification]
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
        @Title         VARCHAR(200),
        @Message       VARCHAR(1000),
        @DriverTag     VARCHAR(100),
        @DriverUserKey INT

  
    SELECT 
        @Title     = Title,
        @Message   = Message,
        @DriverTag = DriverTag
    FROM OPENJSON(@JSONString)
    WITH
    (
        Title       VARCHAR(200)   '$.Title',
        Message     VARCHAR(1000)  '$.Message',
        DriverTag   VARCHAR(100)   '$.DriverTag'
    )

 
    SELECT @DriverUserKey = UserKey
    FROM [User] WITH (NOLOCK)
    WHERE UserName = @DriverTag

	PRINT @DriverUserKey

    IF ISNULL(@DriverUserKey, 0) = 0
    BEGIN
        SET @Status = 0
        SET @Reason = 'Driver not found'
        RETURN
    END

 
    INSERT INTO Notifications
    (
        UserKey,
        CreateDate,
        DetailText,
        HeadText,
        isActive,
        IsRead,
        SentUserKey
    )
    VALUES
    (
        @DriverUserKey,
        GETDATE(),
        @Message,
        @Title,
        1,
        0,
        @UserKey  
    )

 
    IF @IsDebug = 1
    BEGIN
        SELECT 
            @DriverUserKey AS DriverUserKey,
            @UserKey AS SentUserKey,
            @Title AS Title,
            @Message AS Message
    END


    SET @Status = 1
    SET @Reason = 'Notification inserted successfully'

END