/*

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"OrderKey":185590,"BookingNo":"Atest 123"}',
	@Status BIT=0,
	@Reason VARCHAR(1000)=''
EXEC [Update_OrderHeader_BookingNo_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
SELECT @Status, @Reason

*/
CREATE PROCEDURE [dbo].[Update_OrderHeader_BookingNo_V2]
(
	@UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='',
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    -- Initialize output parameters to failure state
    SET @Status = 0;
    SET @Reason = 'Failure';

    -- Validate required JSON input parameter
    IF (@JSONString = '' OR @JSONString IS NULL)
    BEGIN
        SET @Reason = 'JSON parameter is required and cannot be empty';
        RETURN;
    END

    -- Parse JSON input to extract order details
    DECLARE 
        @OrderKey  INT = 0,
        @BookingNo VARCHAR(50) = '';

    SELECT 
        @OrderKey  = OrderKey,
        @BookingNo = BookingNo
    FROM OPENJSON(@JSONString, '$')
    WITH (
        OrderKey  INT          '$.OrderKey',
        BookingNo VARCHAR(50)  '$.BookingNo'
    );

    -- Validate that required values were parsed from JSON
    IF (@OrderKey = 0)
    BEGIN
        SET @Reason = 'OrderKey is required in JSON input';
        RETURN;
    END

    -- Declare variables for audit logging
    DECLARE 
        @OrderNo  NVARCHAR(20) = '',
        @UserName VARCHAR(100) = '';

    -- Validate user exists and get username for audit
    IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE UserKey = @UserKey)
    BEGIN
        SET @Reason = 'Invalid user specified';
        RETURN;
    END

    SELECT @UserName = ISNULL(UserName, '') 
    FROM dbo.[User] 
    WHERE UserKey = @UserKey;

    -- Get order number for audit logging
    SELECT @OrderNo = ISNULL(OrderNo, '') 
    FROM dbo.OrderHeader 
    WHERE OrderKey = @OrderKey;

    -- Validate that the order exists
    IF (@OrderNo = '')
    BEGIN
        SET @Reason = 'Order not found with specified OrderKey';
        RETURN;
    END

    -- Update the order header with new booking number
    UPDATE dbo.OrderHeader 
    SET 
        BookingNo = @BookingNo,
        LastUpdateDate = GETDATE(),
        LastUpdateUserKey = @UserKey
    WHERE OrderKey = @OrderKey;

    -- Verify the update was successful
    IF (@@ROWCOUNT = 0)
    BEGIN
        SET @Reason = 'Failed to update order header';
        RETURN;
    END

    -- Create audit log entry for the booking number update
    INSERT INTO dbo.AuditLogDetail (
        DateCreated, 
        CreateUser, 
        RefType, 
        RefId, 
        RefKey, 
        Stage, 
        CommentType, 
        Comments
    )
    VALUES (
        GETDATE(), 
        @UserName, 
        'Order', 
        @OrderNo, 
        @OrderKey, 
        'Booking No', 
        'Text', 
        'Booking# Updated'
    );

    -- Set success status
    SET @Status = 1;
    SET @Reason = 'Success';
END