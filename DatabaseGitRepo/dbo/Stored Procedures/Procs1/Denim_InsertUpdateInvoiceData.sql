CREATE PROCEDURE [dbo].[Denim_InsertUpdateInvoiceData]
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

	DECLARE @Invoicekey						INT,
			@Invoiceno						VARCHAR(20),			
			@Approvedtimestamp				DATETIME,
			@PaymentReceivedtimestamp		DATETIME,
			@IsComplete						BIT,
			@DenimRefno						VARCHAR(50),
			@DenimInvoiceKey                INT

			SELECT @Invoicekey = Invoicekey, @Invoiceno = Invoiceno,
			 @Approvedtimestamp= Approvedtimestamp, @PaymentReceivedtimestamp= PaymentReceivedtimestamp,
			 @DenimRefno = DenimRefno,@DenimInvoiceKey = DenimInvoiceKey
	        FROM OPENJSON		(@JSONString, '$')
						WITH (  
								Invoicekey						INT		            '$.Invoicekey',				                                  
								Invoiceno						VARCHAR(20)			'$.Invoiceno',	
								Approvedtimestamp				DATETIME			'$.Approvedtimestamp',
								PaymentReceivedtimestamp		DATETIME			'$.PaymentReceivedtimestamp',
								DenimRefno						VARCHAR(50)         '$.DenimRefno',
								DenimInvoiceKey				    INT					'$.DenimInvoiceKey'
	)
	
	
	IF(ISNULL(@DenimInvoiceKey, 0) = 0)							
		BEGIN
			INSERT INTO Denim_SentInvoiceDetails(Invoicekey,Invoiceno,Approvedtimestamp,PaymentReceivedtimestamp,IsComplete,DenimRefno,Createddate)
			values (@Invoicekey,@Invoiceno,@Approvedtimestamp,@PaymentReceivedtimestamp,@IsComplete,@DenimRefno,getdate())
		END
	ELSE
		BEGIN
			UPDATE Denim_SentInvoiceDetails
			set Invoicekey= @Invoicekey,						
			Invoiceno=@Invoiceno,                							
			Updatedate=getdate(),						
			--ApprovedUserkey=@ApprovedUserkey,				
			Approvedtimestamp=@Approvedtimestamp,				
			PaymentReceivedtimestamp=@PaymentReceivedtimestamp,		
			IsComplete=@IsComplete,						
			DenimRefno=@DenimRefno
			where DenimInvoiceKey = @DenimInvoiceKey
		END
END
