
CREATE PROCEDURE [dbo].[Update_Customer]
(
	@custkey		INT,
	@Custid			VARCHAR(20),
	@CustName		VARCHAR(255),
	@Status			INT,
	@CreditCheck	BIT,
	@CreditLimit	DECIMAL(18,2),
	@Ach_Required	BIT,
	@PaymentTerms	INT,
	@CreditStatus		INT,
	@AddrKey		int,
	@BillToAddrKey	int = null,
	@IsFactored		Bit = 0,
	@Notes			varchar(1000),
	@CSRKey			int,
	@CSRManagerKey	int,
	@SalesPersonKey	int,
	@OutPut			BIT OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	--DECLARE @StatusKey INT
	--DECLARE @PmtTermsKey INT

	--SET @StatusKey= ( SELECT StatusKey FROM [Status] WHERE StatusName= @Status AND [Type]='General'  )
	--SET @PmtTermsKey= ( SELECT PaymentTermsKey FROM PaymentTerms WHERE PaymentTermsID= @PaymentTerms)

	UPDATE dbo.Customer 
	SET 
		CustID =@Custid ,
		CustName =@CustName,
		[StatusKey] =@Status , 	
		CreditCheck =@CreditCheck,
		CreditLimit =@CreditLimit,
		PaymentTermsKey =@PaymentTerms,
		CreditStatus = @CreditStatus,
		AddrKey = @AddrKey,
		BillToAddrKey = @BillToAddrKey,
		IsFactored = @IsFactored,
		Ach_Required = @Ach_Required	,
		notes = @Notes,
		CSRKey = @CSRKey,
		CSRManagerKey = @CSRManagerKey,
		SalesPersonKey = @SalesPersonKey
	WHERE CustKey = @custkey;

	SET @OutPut=1
END
