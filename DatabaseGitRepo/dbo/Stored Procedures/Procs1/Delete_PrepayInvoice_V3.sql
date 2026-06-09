/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceKey" : 39}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Delete_PrepayInvoice_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Delete_PrepayInvoice_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@PPInvoiceKey			INT

	SELECT 
		@PPInvoiceKey		=		PPInvoiceKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		PPInvoiceKey		INT		'$.InvoiceKey'
	)

	SET @Status=0;

	BEGIN TRY

		BEGIN TRAN

			INSERT INTO PrepayInvoiceDetail_Delete
				(PPInvoiceKey, PPInvoiceLineKey, ItemKey, UnitPrice, Quantity, ExtCost, CreatedDate, CreatedUserKey,
				UpdateDate, UpdatedUserKey, ContainerNo, DeletedBy, DeletedOn)
			SELECT PPInvoiceKey, PPInvoiceLineKey, ItemKey, UnitPrice, Quantity, ExtCost, CreatedDate, CreatedUserKey,
				UpdateDate, UpdatedUserKey, ContainerNo, @UserKey,GETDATE() FROM PrepayInvoiceDetail
				WHERE PPInvoiceKey=@PPInvoicekey

			INSERT INTO PrepayInvoiceHeader_Delete
				(PPInvoiceKey,PPInvoiceNo,PPInvoiceDate,PPInvoiceAmount,OrderKey,CustomerKey,BillToAddressKey,PPInvoiceSentDate,
				PPInvoiceConfirmDate,CreatedDate,CreatedUserKey,UpdateDate,UpdatedUserKey,OrderNo,
				StatusKey,InternalNotes,CustomerNotes,RevisionDate,RevisionUserKey,InternalNote,DeletedBy,DeletedDate)
			SELECT PPInvoiceKey,PPInvoiceNo,PPInvoiceDate,PPInvoiceAmount,OrderKey,CustomerKey,BillToAddressKey,PPInvoiceSentDate,
				PPInvoiceConfirmDate,CreatedDate,CreatedUserKey,UpdateDate,UpdatedUserKey,OrderNo,
				StatusKey,InternalNotes,CustomerNotes,RevisionDate,RevisionUserKey,InternalNote,@UserKey,GETDATE() FROM PrepayInvoiceHeader
				WHERE PPInvoiceKey=@PPInvoicekey

			DECLARE @UserName NVARCHAR(MAX)='', @InvoiceNo VARCHAR(20)='', @OrderNo VARCHAR(20)='', @OrderKey INT=0
			SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
			SELECT @InvoiceNo=ISNULL(PPInvoiceNo, '') FROM PrepayInvoiceHeader WITH(NOLOCK) WHERE PPInvoicekey=@PPInvoicekey
			SELECT @OrderNo = ISNULL(OrderNo, '') FROM PrepayInvoiceHeader WITH(NOLOCK) WHERE PPInvoicekey=@PPInvoicekey
			SELECT @OrderKey=OrderKey FROM PrepayInvoiceHeader WITH(NOLOCK) WHERE PPInvoicekey=@PPInvoicekey

			DELETE FROM dbo.PrepayInvoiceDetail
			WHERE PPInvoicekey =@PPInvoicekey;

			DELETE FROM dbo.PrepayInvoiceHeader
			WHERE PPInvoiceKey=@PPInvoicekey;

			IF @@ROWCOUNT>0
			BEGIN
				SET @Status=1
				SET @Reason = 'Success'

				INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
				SELECT GETDATE(),@UserName,'Order',@OrderNo,@OrderKey,null,'Text','PrePay Invoice ' + @InvoiceNo + ' deleted by ' + @UserName
			END	;

		COMMIT TRAN

	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		SET @Status=0
	END CATCH
END