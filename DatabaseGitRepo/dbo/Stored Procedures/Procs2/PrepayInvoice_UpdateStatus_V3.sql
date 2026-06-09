/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 6, "StatusKey" : 2}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [PrepayInvoice_UpdateStatus_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[PrepayInvoice_UpdateStatus_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON
    SET FMTONLY OFF

    IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

    DECLARE
         @InvoiceKey     INT = 0,
         @StatusKey      INT   -- 2 = Sent, 3 = Paid

     SELECT 
         @InvoiceKey        =       InvoiceKey,
         @StatusKey         =       StatusKey 
     FROM OPENJSON(@JSONString)
     WITH
     (
         InvoiceKey         INT         '$.InvoiceKey',
         StatusKey          INT         '$.StatusKey'
     )


    DECLARE @cnt INT = 0
    SET @Status = 0

    SELECT @cnt = COUNT(1)
    FROM PrepayInvoiceHeader WITH (NOLOCK)
    WHERE PPInvoiceKey = @InvoiceKey

    IF (@cnt > 0)
    BEGIN
        -- Update based on status
        UPDATE PrepayInvoiceHeader
        SET 
            PPInvoiceSentDate = GETDATE(),
            StatusKey = @StatusKey
        WHERE PPInvoiceKey = @InvoiceKey

        DECLARE @Comment NVARCHAR(MAX)

        IF (@StatusKey = 2)
            SET @Comment = 'PrePay Invoice marked as Sent on ' + CONVERT(VARCHAR, GETDATE())
        ELSE IF (@StatusKey = 3)
            SET @Comment = 'Invoice marked as Paid on ' + CONVERT(VARCHAR, GETDATE())

        INSERT INTO PrePayInvoiceComments (PPInvoiceKey, CommentDate, CreateUserKey, Comment)
        VALUES (@InvoiceKey, GETDATE(), @UserKey, @Comment)

        SET @Status = 1

        DECLARE @UserName NVARCHAR(MAX) = ''
        SELECT @UserName = ISNULL(UserName, '')
        FROM [User] WITH (NOLOCK)
        WHERE UserKey = @UserKey

        DECLARE @AuditComment NVARCHAR(MAX)

        --IF (@StatusKey = 2)
        --    SET @AuditComment = 'PrePay Invoice ' 
        --                        + IH.PPInvoiceNo + ' marked as Approved'
        --ELSE IF (@StatusKey = 3)
        --    SET @AuditComment = 'PrePay Invoice ' 
        --                        + IH.PPInvoiceNo + ' marked as Paid'

        INSERT INTO AuditLogDetail
        (
            DateCreated, CreateUser, RefType, RefId, RefKey,
            Stage, CommentType, Comments
        )
        SELECT 
            GETDATE(),
            @UserName,
            'Order',
            IH.OrderNo,
            IH.OrderKey,
            NULL,
            'Text',
            CASE 
                WHEN @StatusKey = 2 THEN 'PrePay Invoice ' + IH.PPInvoiceNo + ' marked as Approved'
                WHEN @StatusKey = 3 THEN 'PrePay Invoice ' + IH.PPInvoiceNo + ' marked as Paid'
            END
        FROM PrepayInvoiceHeader IH WITH (NOLOCK)
        WHERE IH.PPInvoiceKey = @InvoiceKey
    END
    SET @Status = 1
    SET @Reason = 'Success'
END