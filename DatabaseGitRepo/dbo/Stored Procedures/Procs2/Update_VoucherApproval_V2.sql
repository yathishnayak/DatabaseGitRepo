/*
    DECLARE 
        @Status INT, 
        @Reason NVARCHAR(500);

    EXEC dbo.Update_VoucherApproval_V2 
        @JSONString     = '{"VoucherKeys":"358233:358234"}',
        @Status         = @Status OUTPUT,
        @Reason         = @Reason OUTPUT;
    SELECT @Status AS Status, @Reason AS Reason;
*/
CREATE PROCEDURE [dbo].[Update_VoucherApproval_V2]
(  
    @UserKey    INT = 952,
    @JSONString NVARCHAR(MAX),
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

        IF @UserKey IS NULL
        BEGIN
            SET @Status = 0;
            SET @Reason = N'UserKey is required in JSON input.';
            RETURN;
        END        

        -- Parse VoucherKeys from JSON array into temp table
        IF OBJECT_ID('tempdb..#VoucherKeys') IS NOT NULL DROP TABLE #VoucherKeys;
        
        CREATE TABLE #VoucherKeys ( VoucherKey INT PRIMARY KEY);
        
        DECLARE @VoucherKeys NVARCHAR(500) = '';

        SELECT @VoucherKeys = VoucherKeys
        FROM OPENJSON(@JSONString, '$')
         WITH (
            VoucherKeys     NVARCHAR(500)           '$.VoucherKeys'
        )

        INSERT INTO #VoucherKeys (VoucherKey)
        SELECT VALUE FROM dbo.Fn_SplitParam(@VoucherKeys)

        IF NOT EXISTS (SELECT 1 FROM #VoucherKeys)
        BEGIN
            SET @Status = 0;
            SET @Reason = N'No VoucherKeys provided in JSON input.';
            RETURN;
        END

        -- Get StatusKey for 'Approved'
        DECLARE @StatusKey SMALLINT;
        SELECT @StatusKey = StatusKey 
        FROM dbo.VoucherStatus 
        WHERE Description = 'Approved';

        IF @StatusKey IS NULL
        BEGIN
            SET @Status = 0;
            SET @Reason = N'Approved status not found in VoucherStatus.';
            RETURN;
        END

        -- Get UserName for audit
        DECLARE @UserName VARCHAR(50);
        SELECT @UserName = ISNULL(UserName, '')
        FROM dbo.[User]
        WHERE UserKey = @UserKey;

        BEGIN TRANSACTION;

        -- Update VoucherHeader
        UPDATE VH
        SET IsPaymentApproved = 1,
            PmtApprovedUser   = @UserKey,
            StatusKey         = @StatusKey,
            UpdateDate        = GETDATE(),
            UpdateuserKey     = @UserKey
        FROM dbo.VoucherHeader VH WITH(NOLOCK)
        INNER JOIN #VoucherKeys VK ON VH.VoucherKey = VK.VoucherKey;

        -- Insert audit records (optimized with GROUP BY instead of DISTINCT)
        INSERT INTO dbo.AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
        SELECT GETDATE(),
               @UserName,
               'Container',
               OD.ContainerNo,
               OD.OrderDetailKey,
               NULL,
               'Text',
               'Voucher ' + VH.VoucherNo + ' approved'
        FROM #VoucherKeys VK
        INNER JOIN dbo.VoucherHeader VH WITH(NOLOCK) ON VH.VoucherKey = VK.VoucherKey
        INNER JOIN dbo.VoucherDetail VD WITH(NOLOCK) ON VD.Voucherkey = VK.VoucherKey
        INNER JOIN dbo.Routes RT  WITH(NOLOCK)       ON RT.RouteKey = VD.RouteKey
        INNER JOIN dbo.OrderDetail OD WITH(NOLOCK)   ON OD.OrderDetailKey = RT.OrderDetailKey
        GROUP BY OD.ContainerNo, OD.OrderDetailKey, VH.VoucherNo;

        COMMIT TRANSACTION;

        SET @Status = 1;
        SET @Reason = N'Voucher(s) approved successfully.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @Status = 0;
        SET @Reason = N'Error: ' + ERROR_MESSAGE();
    END CATCH
END;