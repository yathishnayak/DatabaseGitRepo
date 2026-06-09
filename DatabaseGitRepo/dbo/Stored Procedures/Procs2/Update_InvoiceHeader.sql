
CREATE PROCEDURE [dbo].[Update_InvoiceHeader]
@Invoicekey			INT,
@InvoiceDate		DATETIME,
@DueDate			DATETIME,
@User				INT,
@CustomerNote		VARCHAR(3000),
@InternalNote		VARCHAR(3000),
@OutPut				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	UPDATE dbo.InvoiceHeader 
	SET  		
		DueDate = @DueDate,InvoiceDate = @InvoiceDate,UpdateUserKey=@User,UpdateDate=GETDATE(),
		CustomerNote= @CustomerNote,InternalNote= @InternalNote
	WHERE InvoiceKey = @Invoicekey;  

	Update A set DueDate =  DATEADD (d, C.Days,  A.InvoiceDate ) 
	from InvoiceHeader A
	inner join  Customer  B on (A.CustKey = B.CustKey)
	inner join  PaymentTerms C on (B.PaymentTermsKey = C.PaymentTermsKey)
	WHERE A.InvoiceKey = @InvoiceKey;
 

	SET @OutPut=1
END
