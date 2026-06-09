/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{
	"IsEditMode": false,
	"IsDataEditable": false,
	"PaymentReference": "Test",
	"StrPaymentDate": "2026-03-17",
	"PaymentDate": "2026-03-17T00:00:00.000Z",
	"PaidAmount": "20",
	"Note": "Note",
	"InvoiceKey": 38513,
	"PaymentType": "Check",
	"InvoiceType": "I"
}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InsertUpdate_InvoicePayment_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_InvoicePayment_V3] -- execute [InsertUpdate_InvoicePayment]  0,2,'12-04-2022',100.00,1,'Pay'
(
	@UserKey		INT = 0,
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
		@PaymentKey			int,
		@InvoiceKey			int,
		@PaymentDate		Datetime,
		@PaidAmount			Decimal(10,2),
		@PaymentType		Varchar(50),
		@PaymentReference	Varchar(250), 
		@Note				Varchar(250),
		@InvoiceType		varchar(2)

	SELECT
		@PaymentKey			=		PaymentKey			,
		@InvoiceKey			=		InvoiceKey			,
		@PaymentDate		=		PaymentDate			,
		@PaidAmount			=		PaidAmount			,
		@PaymentType		=		PaymentType			,
		@PaymentReference	=		PaymentReference	,
		@Note				=		Note				,
		@InvoiceType		=		InvoiceType		
	FROM OPENJSON(@JSONString)
	WITH
	(
		PaymentKey				INT							'$.PaymentKey',		
		InvoiceKey				INT							'$.InvoiceKey',		
		PaymentDate				DATETIME					'$.PaymentDate',		
		PaidAmount				DECIMAL(10,2)				'$.PaidAmount',		
		PaymentType				VARCHAR(50)					'$.PaymentType',		
		PaymentReference		VARCHAR(250)				'$.PaymentReference',
		Note					VARCHAR(250)				'$.Note',			
		InvoiceType				VARCHAR(2)					'$.InvoiceType'
	)

  	IF(@InvoiceKey = 0)
	BEGIN
		SET @Status = 0
		RETURN;
	END;

		DECLARE @UserName	VARCHAR(50), @OrderNo VARCHAR(50)='', @InvoiceNo VARCHAR(50)='', @OrderKey INT

		SELECT TOP 1 @UserName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey

		IF @InvoiceType = 'I'
		BEGIN
			SELECT @InvoiceNo = ISNULL(InvoiceNo, '') FROM InvoiceHeader  WITH(NOLOCK) WHERE InvoiceKey = @InvoiceKey
			SELECT @OrderKey = OrderKey FROM InvoiceHeader WITH(NOLOCK) WHERE InvoiceKey = @InvoiceKey
			SELECT @OrderNo = ISNULL(OrderNo, '') FROM OrderHeader WITH(NOLOCK) WHERE OrderKey = @OrderKey
		END
		ELSE IF @InvoiceType = 'M'
		BEGIN
			SELECT @InvoiceNo = ISNULL(MInvoiceNo, '') FROM ManualInvoiceHeader WITH(NOLOCK) WHERE MInvoiceKey = @InvoiceKey
			SELECT @OrderKey = OrderKey FROM ManualInvoiceHeader WITH(NOLOCK) WHERE MInvoiceKey = @InvoiceKey
			SELECT @OrderNo = ISNULL(OrderNo, '') FROM ManualInvoiceHeader WITH(NOLOCK) WHERE MInvoiceKey = @InvoiceKey
		END
		ELSE
		BEGIN
			SELECT @InvoiceNo = ISNULL(PPInvoiceNo, '') FROM PrepayInvoiceHeader WITH(NOLOCK) WHERE PPInvoiceKey = @InvoiceKey
			SELECT @OrderKey = OrderKey FROM PrepayInvoiceHeader WITH(NOLOCK) WHERE PPInvoiceKey = @InvoiceKey
			SELECT @OrderNo = ISNULL(OrderNo, '') FROM PrepayInvoiceHeader WITH(NOLOCK) WHERE PPInvoiceKey = @InvoiceKey
		END

		IF (ISNULL(@PaymentKey,0) = 0)
		BEGIN 
			INSERT INTO [InvoicePayment]( InvoiceKey, PaymentDate, PaidAmount,
							UserKey, PaymentType, PaymentReference, Note, InvoiceType, CreatedDate)
			SELECT  @InvoiceKey, @PaymentDate, @PaidAmount, @UserKey, @PaymentType, @PaymentReference, @Note, @InvoiceType, GETDATE()

			Select @PaymentKey = SCOPE_IDENTITY()

			update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised as sent by ' + ISNULL(@UserName, '') + ' on ' 
				+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; '
				where InvoiceKey = @InvoiceKey

			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT GETDATE(), @UserName, 'Order', @OrderNo, @OrderKey, NULL, 'Text' , 'Invoice Payment added for Invoice ' + @InvoiceNo + ' by ' + @UserName
		End
		else
		Begin
			Update [InvoicePayment]
			set InvoiceKey = @InvoiceKey, 
				PaymentDate = @PaymentDate, 
				PaidAmount = @PaidAmount , 
				UserKey = @UserKey, 
				PaymentType = @PaymentType,
				PaymentReference = @PaymentReference, 
				Note = @Note,
				CreatedDate = GETDATE()
			where PaymentKey = @PaymentKey

			update InvoiceHeader set InternalNote = isnull(InternalNote,'') + 'Invoice Revised as sent by ' + ISNULL(@UserName, '') + ' on ' 
				+ convert(varchar, getdate(),101) + ' ' + convert(varchar, getdate(),108) + '; '
				where InvoiceKey = @InvoiceKey
			
			INSERT INTO AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, Stage, CommentType, Comments)
			SELECT GETDATE(), @UserName, 'Order', @OrderNo, @OrderKey, NULL, 'Text' , 'Invoice Payment updated for Invoice ' + @InvoiceNo + ' by ' + @UserName
		End

		SELECT @PaymentKey AS PaymentKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
		
		SET @Status=1
		SET @Reason = 'Success'
End