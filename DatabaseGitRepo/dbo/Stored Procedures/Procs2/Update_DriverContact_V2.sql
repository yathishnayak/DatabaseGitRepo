/*
DECLARE 
    @UserKey INT = 1144,
    @JSONString NVARCHAR(MAX)= '{
        "DriverKey": 1664,
        "DriverContact": "9876543210"
    }',
    @Status BIT = 0,
    @Reason VARCHAR(1000) = '',
    @IsDebug BIT = 0

EXEC [Update_DriverContact_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status, @Reason
*/

CREATE PROCEDURE [dbo].[Update_DriverContact_V2]
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
        @DriverKey     INT,
        @DriverContact VARCHAR(20)

    SELECT 
        @DriverKey     = DriverKey,
        @DriverContact = DriverContact
    FROM OPENJSON(@JSONString)
    WITH
    (
        DriverKey      INT           '$.DriverKey',
        DriverContact  VARCHAR(20)   '$.DriverContact'
    )

    IF ISNULL(@DriverKey, 0) = 0
    BEGIN
        SET @Status = 0
        SET @Reason = 'Invalid DriverKey'
        RETURN
    END

    UPDATE A 
    SET Phone = @DriverContact
    FROM Driver D WITH (NOLOCK)
    INNER JOIN Address A WITH (NOLOCK) ON D.AddrKey = A.AddrKey
    WHERE D.DriverKey = @DriverKey

    IF @IsDebug = 1
    BEGIN
        SELECT 
            @DriverKey AS DriverKey,
            @DriverContact AS DriverContact
    END

    SET @Status = 1
    SET @Reason = 'Driver contact updated successfully'

END