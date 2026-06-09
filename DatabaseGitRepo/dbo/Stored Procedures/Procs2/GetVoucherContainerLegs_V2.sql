/**

DECLARE 
    @UserKey    INT = 512,
    @JSONString NVARCHAR(MAX) = '{"VoucherKey": 299376}',
    @Status     BIT = 0,
    @Reason     VARCHAR(1000) = '';

EXEC [dbo].[GetVoucherContainerLegs_V2] 
    @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT;

SELECT @Status AS Status, @Reason AS Reason;

**/
CREATE PROCEDURE [dbo].[GetVoucherContainerLegs_V2]
(
    @UserKey    INT = 512,
    @JSONString NVARCHAR(MAX) = '',
    @Status     BIT = 0 OUTPUT,
    @Reason     VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    -- Initialize output parameters
    SET @Status = 0;
    SET @Reason = 'Failure';

    -- Validate JSON input
    IF (ISNULL(LTRIM(RTRIM(@JSONString)), '') = '')
    BEGIN
        SET @Reason = 'JSON parameter is required and cannot be empty';
        RETURN;
    END

    -- Parse JSON input to extract VoucherKey
    DECLARE @VoucherKey INT = 0;
    
    SELECT @VoucherKey = VoucherKey
    FROM OPENJSON(@JSONString, '$')
    WITH (
        VoucherKey INT '$.VoucherKey'
    );

    -- Validate VoucherKey
    IF (@VoucherKey = 0)
    BEGIN
        SET @Reason = 'VoucherKey is required in JSON input';
        RETURN;
    END

    -- Get voucher container legs data with Pascal case output
    SELECT 
        OrderDetailKey,
        ContainerNo,
        ContainerID,
        LegID,
        VoucherKey,
        RouteKey
    FROM dbo.vVoucherContainerLegs WITH(NOLOCK)
    WHERE VoucherKey = @VoucherKey
    FOR JSON PATH;

    -- Set success status
    SET @Status = 1;
    SET @Reason = 'Success';
END