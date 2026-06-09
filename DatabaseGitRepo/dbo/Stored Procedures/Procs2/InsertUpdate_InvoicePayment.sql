
CREATE Procedure [dbo].[InsertUpdate_InvoicePayment] -- execute [InsertUpdate_InvoicePayment]  0,2,'12-04-2022',100.00,1,'Pay'
(
  @PaymentKey			int OUTPUT,
  @InvoiceKey			int,
  --@DetailData			NVARCHAR(MAX)='',
  @PaymentDate			Datetime,
  @PaidAmount			Decimal(10,2),
  @UserKey				int,
  @PaymentType			Varchar(50),
  @PaymentReference		Varchar(250), 
  @Note					Varchar(250),
  @InvoiceType			varchar(2),
  @OutPut				BIT=0 OUTPUT  -- @Result 1 - sucess, 0 - failure
)AS


BEGIN
  SET NOCOUNT ON;
  SET FMTONLY OFF;

  	IF(@InvoiceKey = 0)
	BEGIN
		SET @output = 0
		RETURN;
	END;


		IF @PaymentKey = 0
		BEGIN 
			INSERT INTO [InvoicePayment]( InvoiceKey, PaymentDate, PaidAmount,
							UserKey, PaymentType, PaymentReference, Note, InvoiceType, CreatedDate)
			SELECT  @InvoiceKey, @PaymentDate, @PaidAmount, @UserKey, @PaymentType, @PaymentReference, @Note, @InvoiceType, GETDATE()

			Select @PaymentKey = SCOPE_IDENTITY()
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

		End
		
		SET @OutPut=1;
End
