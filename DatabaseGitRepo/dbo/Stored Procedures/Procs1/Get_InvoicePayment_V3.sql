/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"InvoiceType" : "I", "InvoiceKey" : 183364}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Get_InvoicePayment_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_InvoicePayment_V3]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
As

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	

	DECLARE
		@InvoiceType	char(1) = 'I',
		@InvoiceKey		INT = 0

	SELECT 
		@InvoiceType		=		InvoiceType,
		@InvoiceKey			=		InvoiceKey	
	FROM OPENJSON(@JSONString)
	WITH
	(
		InvoiceType			CHAR(1)		'$.InvoiceType',
		InvoiceKey			INT			'$.InvoiceKey'
	)

	SELECT 
	IP.PaymentKey,
	IP.InvoiceKey, 
	IP.PaymentDate, 
	IP.PaidAmount,
	IP.UserKey, 
	IP.PaymentType, 
	IP.PaymentReference, 
	IP.Note, U.UserName , 
	IP.CreatedDate, 
	IP.InvoiceType
	from InvoicePayment IP WITH (NOLOCK)
	Left Join InvoiceHeader IH  WITH (NOLOCK) on IP.InvoiceKey=IH.InvoiceKey and IP.InvoiceType =  @InvoiceType 
	Left Join PrepayInvoiceHeader PH  WITH (NOLOCK) on IP.InvoiceKey = PH.PPInvoiceKey and IP.InvoiceType =  @InvoiceType 
	Left join ManualInvoiceHeader MH  WITH (NOLOCK) on IP.InvoiceKey = MH.MInvoiceKey and IP.InvoiceType =  @InvoiceType 
	Left Join [User] U on IP.UserKey = U.UserKey
	where IP.InvoiceKey= @InvoiceKey and ( IH.InvoiceKey is not null OR PH.PPInvoiceKey is not null OR MH.MInvoiceKey is not null)
	FOR JSON PATH

	SET @Status=1
	SET @Reason = 'Success'