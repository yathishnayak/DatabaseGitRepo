/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 192244}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Delete_InvoiceFull_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Delete_InvoiceFull_V2] -- exec delete_invoicefull 192314, 951
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
As
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
		@InvoiceKey		INT

	SELECT 
		@InvoiceKey		=		InvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceKey			INT				'$.InvoiceKey'
	)
	DECLARE @TRAN VARCHAR(50) = 'INVOICE_TRAN'
	BEGIN TRANSACTION @TRAN;
	BEGIN TRY 
		DECLARE @CNT INT = 0
		DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @ContainerNo VARCHAR(20)='', @OrderDetailKey INT=0

		SET @Status = 0
		
		SELECT @CNT = COUNT(1) FROM InvoiceHeader with(nolock) WHERE InvoiceKey = @InvoiceKey AND StatusKey = 1	

		IF(@CNT > 0)
		BEGIN
			PRINT '1'
			

			INSERT INTO InvoiceHeader_Deleted (InvoiceKey, InvoiceNo, InvoiceDate, CustKey, BillToAddrKey, InvoiceAmount, 
				DueDate, InvoiceType, CompanyKey, StatusKey, CreateUserKey, IsInvoiceApproved, IsPaymentReceived, CreateDate,
				UpdateUserKey, UpdateDate, InvoiceApprovedUserKey, InvoiceApprovedDate, OrderKey, CustomerNote, InternalNote, 
				IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, IsRevised, RevisionDate, PrintedDate, 
				RevisionUserKey, BrokerRefNo, DeleteUserKey, DeletedDate)
			select InvoiceKey, InvoiceNo, InvoiceDate, CustKey, BillToAddrKey, InvoiceAmount, 
				DueDate, InvoiceType, CompanyKey, StatusKey, CreateUserKey, IsInvoiceApproved, IsPaymentReceived, CreateDate,
				UpdateUserKey, UpdateDate, InvoiceApprovedUserKey, InvoiceApprovedDate, OrderKey, CustomerNote, InternalNote, 
				IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, IsRevised, RevisionDate, PrintedDate, 
				RevisionUserKey, BrokerRefNo, @UserKey, GETDATE()
			from InvoiceHeader WITH(NOLOCK)
			where InvoiceKey = @InvoiceKey

			PRINT '2'
			INSERT INTO Invoicedetail_Deleted (InvoicelineKey, InvoiceKey, ItemKey, Description, UnitPrice, Qty, ExtAmt, Container, 
				OrderDetailKey, CreateUserKey, CreateDate, UpdateUserKey, UpdateDate, DeleteUserKey, DeletedDate)
			SELECT InvoicelineKey, InvoiceKey, ItemKey, Description, UnitPrice, Qty, ExtAmt, Container, 
				OrderDetailKey, CreateUserKey, CreateDate, UpdateUserKey, UpdateDate, @UserKey, GETDATE()
			FROM Invoicedetail WITH(NOLOCK)
			WHERE InvoiceKey = @InvoiceKey

			PRINT '3'
			insert into InvoiceContainers_Deleted (InvoiceKey, OrderDetailsKey, ContainerNo, TerminationDate,DeleteUserKey, DeletedDate )
			select InvoiceKey, OrderDetailsKey, ContainerNo, TerminationDate, @UserKey, Getdate() 
			from InvoiceContainers WITH(NOLOCK) WHERE InvoiceKey = @InvoiceKey 

		    SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
			SELECT @InvoiceNo=ISNULL(InvoiceNo, '') FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey
			SELECT @ContainerNo = ISNULL(ContainerNo, '') FROM InvoiceContainers WITH (NOLOCK) WHERE InvoiceKey = @InvoiceKey;
			SELECT @OrderDetailKey=OrderDetailKey FROM Invoicedetail WITH(NOLOCK) WHERE InvoiceKey=@InvoiceKey

			PRINT '4'
			DELETE FROM Invoicedetail WHERE InvoiceKey = @InvoiceKey

			PRINT '5'
			DELETE FROM InvoiceContainers WHERE InvoiceKey = @InvoiceKey

			PRINT '6'
			DELETE FROM RouteInvoice WHERE InvoiceKey = @InvoiceKey

			PRINT '7'
			DELETE FROM InvoiceHeader WHERE InvoiceKey = @InvoiceKey

			SET @Status = 1
			SET @Reason = 'Success'

			INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Container',@ContainerNo,@OrderDetailKey,null,'Text','Invoice ' + @InvoiceNo + ' deleted by ' + @UserName
			 END
        ELSE
        BEGIN
            SET @Status = 0
            SET @Reason = 'Invoice not found or not in Pending status'
        END
			COMMIT TRANSACTION @TRAN;

	   END TRY
    BEGIN CATCH
        PRINT 'ERROR'
        ROLLBACK TRANSACTION @TRAN
        SET @Status = 0
        SET @Reason = ERROR_MESSAGE()
    END CATCH
END