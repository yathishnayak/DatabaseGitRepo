
CREATE PROCEDURE [dbo].[Insert_Customer]
/*
dbo.fn_insert_customer
*/
	@CustID			VARCHAR(20),
	@CustName		VARCHAR(255),
	@AddrKey		INT	,
	@CustomerGroup  SMALLINT,
	@CreditLimit	DECIMAL(18,2),
	@Ach_Required	BIT,
	@PaymentTerms	SMALLINT,
	@CreditStatus SMALLINT,
	@CreditCheck  SMALLINT,
	@BillToAddrKey	int,
	@IsFactored		Bit = 0,
	@Notes			varchar(500),
	@CSRKey			int,
	@CSRManagerKey	int,
	@SalesPersonKey	int,
	@custKey		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO dbo.Customer( CustID, CustName, AddrKey, PaymentTermsKey,CreditCheck,StatusKey,
			StatusDate, CreditLimit,CreditStatus,CreateDate, BillToAddrKey, IsFactored, notes,
			CSRKey, CSRManagerKey, SalesPersonKey)
	VALUES (@CustID, @CustName, @AddrKey, @PaymentTerms,@CreditCheck,1,GETDATE(), @CreditLimit,
			@CreditStatus,GETDATE(), @BillToAddrKey, @IsFactored, @Notes, 
			@CSRKey, @CSRManagerKey, @SalesPersonKey)

	SET @custKey=0;
	SET @custKey = ( SELECT SCOPE_IDENTITY());		
END
