/*
DECLARE 
    @UserKey    INT = 953, 
    @JSONString NVARCHAR(MAX),
    @Status     BIT = 0,
    @Reason     VARCHAR(1000), 
    @IsDebug    BIT = 1 
SET @JSONString = '{"VoucherKey":299435, "VoucherLineKey":442436}'
 
EXEC dbo.Delete_VoucherLine_V2 @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[Delete_VoucherLine_V2]
(
    @UserKey    INT,
    @JSONString NVARCHAR(MAX) = '',
    @Status     BIT = 0 OUTPUT,
    @Reason     NVARCHAR(MAX) = '' OUTPUT,
    @IsDebug    BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Initialize outputs
    SET @Status = 0;
    SET @Reason = '';

    BEGIN TRY
        -- Validate JSON input
        IF ISNULL(LTRIM(RTRIM(@JSONString)), '') = ''
        BEGIN
            SET @Reason = 'JSONString cannot be blank';
            RETURN;
        END

        IF ISJSON(@JSONString) = 0
        BEGIN
            SET @Reason = 'Invalid JSON format';
            RETURN;
        END

        -- Parse JSON parameters
        DECLARE @VoucherKey     INT,
                @VoucherLineKey INT;

        SELECT @VoucherKey     = VoucherKey,
               @VoucherLineKey = VoucherLineKey
        FROM OPENJSON(@JSONString, '$')
        WITH (
            VoucherKey     INT '$.VoucherKey',
            VoucherLineKey INT '$.VoucherLineKey'
        );

        -- Validate required parameters
        IF @VoucherKey IS NULL OR @VoucherKey = 0
        BEGIN
            SET @Reason = 'VoucherKey is required';
            RETURN;
        END

        IF @VoucherLineKey IS NULL OR @VoucherLineKey = 0
        BEGIN
            SET @Reason = 'VoucherLineKey is required';
            RETURN;
        END

        -- Gather required data in single query
        DECLARE @RouteKey       INT,
                @OrderDetailKey INT,
                @ContainerNo    VARCHAR(100),
                @UserName       VARCHAR(100),
                @VoucherNo      VARCHAR(100);

        SELECT @VoucherNo      = VH.VoucherNo,
               @RouteKey       = VD.RouteKey,
               @OrderDetailKey = R.OrderDetailKey,
               @ContainerNo    = OD.ContainerNo,
               @UserName       = U.UserName
        FROM dbo.VoucherHeader VH
        INNER JOIN dbo.VoucherDetail VD ON VH.VoucherKey = VD.VoucherKey
        LEFT JOIN dbo.Routes R ON VD.RouteKey = R.RouteKey
        LEFT JOIN dbo.OrderDetail OD ON R.OrderDetailKey = OD.OrderDetailKey
        CROSS JOIN dbo.[User] U
        WHERE VH.VoucherKey = @VoucherKey
          AND VD.VoucherLineKey = @VoucherLineKey
          AND U.UserKey = @UserKey;

        -- Validate voucher line exists
        IF @VoucherNo IS NULL
        BEGIN
            SET @Reason = 'Voucher or VoucherLine not found';
            RETURN;
        END

        BEGIN TRANSACTION;

        -- Delete voucher line
        DELETE FROM dbo.VoucherDetail
        WHERE VoucherLineKey = @VoucherLineKey 
          AND VoucherKey = @VoucherKey;

        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SET @Reason = 'No voucher line was deleted';
            RETURN;
        END

        -- Update voucher amount
        UPDATE dbo.VoucherHeader
        SET VoucherAmount = ISNULL((
            SELECT SUM(ExtCost) 
            FROM dbo.VoucherDetail 
            WHERE VoucherKey = @VoucherKey
        ), 0)
        WHERE VoucherKey = @VoucherKey;

        -- Insert audit log
        INSERT INTO dbo.AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
        VALUES (
            GETDATE(),
            @UserName,
            'Container',
            @ContainerNo,
            @OrderDetailKey,
            NULL,
            'Text',
            'Voucher line item deleted for voucher ' + ISNULL(@VoucherNo, '') + ' by ' + ISNULL(@UserName, '')
        );

        COMMIT TRANSACTION;

        SET @Status = 1;
        SET @Reason = 'Success';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 0;
        SET @Reason = ERROR_MESSAGE();
    END CATCH
END;