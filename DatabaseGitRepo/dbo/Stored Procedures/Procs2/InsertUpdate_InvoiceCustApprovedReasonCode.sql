/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"CustApprovedCodeKey" : 1, "InvoiceKey" :38388 }',
	@Status	BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InsertUpdate_InvoiceCustApprovedReasonCode] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_InvoiceCustApprovedReasonCode]
(
	@UserKey		INT,
	@JSONString		NVARCHAR(MAX),
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF;
	CREATE TABLE #CodeData
	(
		CustApprovedCodeKey		INT,
		InvoiceKey				INT
	)

	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		RETURN
	END

	INSERT INTO #CodeData( CustApprovedCodeKey,InvoiceKey)
	SELECT CustApprovedCodeKey,InvoiceKey
	FROM OPENJSON(@JsonString, '$')
	WITH (
			CustApprovedCodeKey		int		'$.CustApprovedCodeKey',
			InvoiceKey				INT		'$.InvoiceKey'
		)

	BEGIN TRY
		BEGIN TRANSACTION
			UPDATE IH
			SET IH.AprovedReasonCodeKey=T.CustApprovedCodeKey
			FROM InvoiceHeader IH  WITH(NOLOCK)
			INNER JOIN #CodeData T ON IH.InvoiceKey=T.InvoiceKey

			UPDATE IH
			SET IH.IsInvoiceApproved=1
			FROM InvoiceHeader IH WITH(NOLOCK) 
			INNER JOIN #CodeData T ON IH.InvoiceKey=T.InvoiceKey
			WHERE T.CustApprovedCodeKey=1
		COMMIT TRANSACTION
		SET @Status = 1
		SET @Reason = 'SUCCESS'

		DECLARE @UserName VARCHAR(50)=''
		SELECT @UserName = ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey

		INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
		SELECT
		    GETDATE(),                                  
		    @UserName,                                  
		    'Container',                                
		    (SELECT TOP 1 ContainerNo FROM InvoiceContainers WITH(NOLOCK) WHERE InvoiceKey = C.InvoiceKey),          
		    (SELECT TOP 1 OrderDetailKey FROM InvoiceDetail WITH(NOLOCK) WHERE InvoiceKey = C.InvoiceKey),          
		    NULL,                                       
		    'Text',                                     
		    'Invoice ' + IH.InvoiceNo + ' marked as customer approved with reason code: ' + (SELECT ApprovedReasonCode FROM InvoiceCustApprovedReasonCode
																							 WHERE AprovedReasonCodeKey = C.CustApprovedCodeKey)
		FROM #CodeData C
		INNER JOIN InvoiceHeader IH WITH(NOLOCK) ON IH.InvoiceKey = C.InvoiceKey;

		SET @Status = 1
		SET @Reason = 'Success'

	END TRY
	BEGIN CATCH
		SET @Status = 0
		SET @Reason = 'Error in InsertUpdate_InvoiceCustApprovedReasonCode'
		PRINT ERROR_NUMBER()
		PRINT ERROR_MESSAGE()
		ROLLBACK TRANSACTION
	END CATCH
END