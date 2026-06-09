/*
DECLARE
    @Status BIT = 0,
    @Reason VARCHAR(1000) = ''

EXEC [ManualInvoice_UpdateStatus]
    @UserKey    = 1144,
    @JSONString = '{"InvoiceKey": 14, "StatusKey": 4}',
    @Status     = @Status OUTPUT,
    @Reason     = @Reason OUTPUT,
    @IsDebug    = 0

SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[ManualInvoice_UpdateStatus]
(
    @UserKey        INT             = 0,
    @JSONString     NVARCHAR(MAX)   = '',
    @Status         BIT             = 0 OUTPUT,
    @Reason         VARCHAR(1000)   = '' OUTPUT,
    @IsDebug        BIT             = 0
)
AS
BEGIN
    SET NOCOUNT ON
    SET FMTONLY OFF

    IF (ISNULL(LTRIM(RTRIM(@JSONString)), '') = '')
    BEGIN
        SET @Status = 0
        SET @Reason = 'Parameters not found'
        RETURN
    END

    DECLARE
        @InvoiceKey     INT = 0,
        @StatusKey      INT     -- 2 = Sent, 3 = Paid, 4 = Void

    SELECT
        @InvoiceKey = InvoiceKey,
        @StatusKey  = StatusKey
    FROM OPENJSON(@JSONString)
    WITH
    (
        InvoiceKey  INT '$.InvoiceKey',
        StatusKey   INT '$.StatusKey'
    )

    DECLARE
        @cnt                INT             = 0,
        @PreVoidStatusKey   INT             = 0,
        @PaidInvoice        SMALLINT        = 0,
        @UserName           NVARCHAR(MAX)   = ''

    SET @Status = 0

    SELECT @cnt = COUNT(1)
    FROM ManualInvoiceHeader WITH(NOLOCK)
    WHERE MInvoiceKey = @InvoiceKey

    SELECT @UserName = ISNULL(UserName, '')
    FROM [User] WITH(NOLOCK)
    WHERE UserKey = @UserKey

    IF (@cnt = 0)
    BEGIN
        SET @Status = 0
        SET @Reason = 'Invoice not found'
        RETURN
    END

    --------------------------------------------------
    -- STATUS = SENT (2)
    --------------------------------------------------
    IF (@StatusKey = 2)
    BEGIN
        UPDATE ManualInvoiceHeader
        SET MInvoiceSentDate    = GETDATE(),
            StatusKey           = @StatusKey
        WHERE MInvoiceKey = @InvoiceKey

        INSERT INTO ManualInvoiceComments (MInvoiceKey, CommentDate, CreateUserKey, Comment)
        VALUES
        (@InvoiceKey, GETDATE(), @UserKey,
         'Manual Invoice marked as Sent on ' + CONVERT(VARCHAR, GETDATE()))

        INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
        SELECT GETDATE(), @UserName, 'Order',
               ISNULL(IH.OrderNo, ''), IH.OrderKey, NULL, 'Text',
               'Manual Invoice ' + IH.MInvoiceNo + ' marked as Approved by ' + @UserName
        FROM ManualInvoiceHeader IH
        WHERE IH.MInvoiceKey = @InvoiceKey

        SET @Status = 1
        SET @Reason = 'Manual Invoice marked as Sent'
    END

    --------------------------------------------------
    -- STATUS = PAID (3)
    --------------------------------------------------
    ELSE IF (@StatusKey = 3)
    BEGIN
        UPDATE ManualInvoiceHeader
        SET MInvoiceSentDate    = GETDATE(),
            StatusKey           = @StatusKey
        WHERE MInvoiceKey = @InvoiceKey

        INSERT INTO ManualInvoiceComments (MInvoiceKey, CommentDate, CreateUserKey, Comment)
        VALUES
        (@InvoiceKey, GETDATE(), @UserKey,
         'Invoice marked as Paid on ' + CONVERT(VARCHAR, GETDATE()))

        INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
        SELECT GETDATE(), @UserName, 'Order',
               ISNULL(IH.OrderNo, ''), IH.OrderKey, NULL, 'Text',
               'Manual Invoice ' + IH.MInvoiceNo + ' marked as Paid by ' + @UserName
        FROM ManualInvoiceHeader IH
        WHERE IH.MInvoiceKey = @InvoiceKey

        SET @Status = 1
        SET @Reason = 'Invoice marked as Paid'
    END

    --------------------------------------------------
    -- STATUS = VOID (4)
    --------------------------------------------------
    ELSE IF (@StatusKey = 4)
    BEGIN
        SELECT @PreVoidStatusKey = StatusKey
        FROM ManualInvoiceHeader WITH(NOLOCK)
        WHERE MInvoiceKey = @InvoiceKey

        SELECT @PaidInvoice = COUNT(1)
        FROM InvoicePayment WITH(NOLOCK)
        WHERE InvoiceKey = @InvoiceKey
          AND InvoiceType = 'M'
        HAVING SUM(ISNULL(PaidAmount, 0)) <> 0

        IF (@CNT > 0 AND ISNULL(@PaidInvoice, 0) = 0)
        BEGIN
            UPDATE ManualInvoiceHeader
            SET VoidedDate          = GETDATE(),
                IsVoid              = 1,
                VoidedUserKey       = @UserKey,
                StatusKey           = @StatusKey,
                PreVoidStatusKey    =
                    CASE
                        WHEN @PreVoidStatusKey <> 4
                        THEN @PreVoidStatusKey
                        ELSE PreVoidStatusKey
                    END
            WHERE MInvoiceKey = @InvoiceKey

            INSERT INTO ManualInvoiceComments (MInvoiceKey, CommentDate, CreateUserKey, Comment)
            VALUES
            (@InvoiceKey, GETDATE(), @UserKey,
             'Invoice marked as Void on ' + CONVERT(VARCHAR, GETDATE()))

            INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
            SELECT GETDATE(), @UserName, 'Order',
                   ISNULL(IH.OrderNo, ''), IH.OrderKey, NULL, 'Text',
                   'Manual Invoice ' + IH.MInvoiceNo + ' marked as Void by ' + @UserName
            FROM ManualInvoiceHeader IH
            WHERE IH.MInvoiceKey = @InvoiceKey

            SET @Status = 1
            SET @Reason = 'Invoice marked as Void'
        END
        ELSE
        BEGIN
            SET @Status = 0
            SET @Reason = 'Invoice Payment Already Exists'
        END
    END
    ELSE
    BEGIN
        SET @Status = 0
        SET @Reason = 'Invalid StatusKey provided'
    END

END
