/*
DECLARE @UserKey INT, @Status INT, @Reason NVARCHAR(500);

EXEC dbo.Delete_Voucher_V2 
    @JSONString = '{"VoucherKey": 299399}',
    @Status = @Status OUTPUT,
    @Reason = @Reason OUTPUT;

SELECT @Status AS Status, @Reason AS Reason;
*/
CREATE PROCEDURE [dbo].[Delete_Voucher_V2]
(
    @UserKey    INT = 952,
    @JSONString NVARCHAR(MAX),  -- JSON format: {"VoucherKey":123, "UserKey":1}
    @Status     BIT OUTPUT,
    @Reason     NVARCHAR(500) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Initialize outputs
    SET @Status = 0;
    SET @Reason = N'';

    BEGIN TRY
        -- Validate JSON input
        IF ISJSON(@JSONString) = 0
        BEGIN
            SET @Status = 0;
            SET @Reason = N'Invalid JSON format provided.';
            RETURN;
        END

        -- Extract parameters from JSON
        DECLARE @VoucherKey INT = JSON_VALUE(@JSONString, '$.VoucherKey')

        IF @VoucherKey IS NULL OR @VoucherKey = 0
        BEGIN
            SET @Status = 0;
            SET @Reason = N'VoucherKey is required in JSON input.';
            RETURN;
        END     

        -- Check if voucher exists and is not approved (use EXISTS instead of COUNT)
        IF NOT EXISTS (
            SELECT 1 FROM dbo.VoucherHeader 
            WHERE VoucherKey = @VoucherKey 
              AND ISNULL(IsPaymentApproved, 0) = 0
        )
        BEGIN
            SET @Status = 0;
            SET @Reason = N'Voucher not found or already approved for payment.';
            RETURN;
        END

        -- Get all required data in single query (optimized)
        DECLARE @VoucherNo    VARCHAR(100),
                @UserName     VARCHAR(50),
                @ContainerNo  VARCHAR(50),
                @OrderDetailKey INT;

        SELECT @VoucherNo = VH.VoucherNo,
               @UserName  = ISNULL(U.UserName, ''),
               @ContainerNo = OD.ContainerNo,
               @OrderDetailKey = OD.OrderDetailKey
        FROM dbo.VoucherHeader VH
        CROSS JOIN dbo.[User] U
        LEFT JOIN dbo.VoucherDetail VD ON VD.Voucherkey = VH.VoucherKey
        LEFT JOIN dbo.Routes R ON R.RouteKey = VD.RouteKey
        LEFT JOIN dbo.OrderDetail OD ON OD.OrderDetailKey = R.OrderDetailKey
        WHERE VH.VoucherKey = @VoucherKey
          AND U.UserKey = @UserKey;

        BEGIN TRANSACTION;

        -- Delete in correct order (child to parent)
        DELETE FROM dbo.RouteVouchers WHERE VoucherKey = @VoucherKey;
        DELETE FROM dbo.VoucherDetail WHERE Voucherkey = @VoucherKey;
        DELETE FROM dbo.VoucherHeader WHERE VoucherKey = @VoucherKey;

        -- Insert audit record
        INSERT INTO dbo.AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, CommentType, Comments)
        VALUES (
            GETDATE(),
            @UserName,
            'Container',
            @ContainerNo,
            @OrderDetailKey,
            'Text',
            'Voucher ' + ISNULL(@VoucherNo, '') + ' deleted by ' + @UserName + ' on ' + CONVERT(VARCHAR(20), GETDATE(), 120)
        );

        COMMIT TRANSACTION;

        SET @Status = 1;
        SET @Reason = N'Voucher deleted successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 0;
        SET @Reason = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END;