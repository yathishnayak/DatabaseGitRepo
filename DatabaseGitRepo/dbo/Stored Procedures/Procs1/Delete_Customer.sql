

CREATE PROCEDURE [dbo].[Delete_Customer]
(
	@CustKey	INT,
	@UserKey    INT,
	@output		Bit = 0 OUTPUT,
	@Reason		varchar(100) = '' OUTPUT
)
AS
 BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @cntCust     int = 0,
	        @cntConsignee int = 0,
	      --  @cntCustrAddrint INT= 0,
			@cntCustrItemRate int = 0,
	        @cntInvoiceHeader INT= 0,
			@cntItemForAcc int = 0,
	        @cntOrderHeader INT= 0
			

   SET @cntCust = (SELECT COUNT(CustName) FROM Customer WHERE CustKey = @CustKey)
   SET @cntConsignee = (SELECT COUNT(1) FROM Consignee WHERE CustKey = @CustKey)
  -- SET @cntCustrAddrint = (SELECT COUNT(1) FROM CustomerAddress WHERE CustKey = @CustKey)
   SET @cntCustrItemRate = (SELECT COUNT(1) FROM CustomerItemRate WHERE CustomerKey = @CustKey)
   SET @cntInvoiceHeader = (SELECT COUNT(1) FROM InvoiceHeader WHERE CustKey = @CustKey)
   SET @cntItemForAcc = (SELECT COUNT(1) FROM ItemsForAccounting WHERE CustomerKey = @CustKey)
   SET @cntOrderHeader = (SELECT COUNT(1) FROM OrderHeader WHERE CustKey = @CustKey)

   IF iSNULL(@cntCust,0) = 0
		BEGIN
			SET @output  = CONVERT(BIT,0);
			SET @Reason  = 'No record  found for the given Customer';
			RETURN;
		END 
   ELSE IF  ISNULL(@cntConsignee,0) > 0
   BEGIN
		SET @output  = CONVERT(BIT,0);
		SET @Reason  = 'Customer linked to Consignee, can not be deleted';
		RETURN;
	END		
 --   ELSE IF  ISNULL(@cntCustrAddrint,0) > 0
	--BEGIN
	--	SET @output = CONVERT(BIT,0);
	--	SET @Reason = 'Customer linked to Address, can not be deleted';
 --       RETURN;
	--END	
	ELSE IF ISNULL(@cntCustrItemRate,0) > 0
	BEGIN
		SET @output = CONVERT(BIT,0)
		SET @Reason = 'Customer linked to Item Rate, can not be deleted';
        RETURN;
	END
	ELSE IF ISNULL(@cntInvoiceHeader,0) > 0
	BEGIN
		SET @output = CONVERT(BIT,0)
		SET @Reason = 'Customer linked to Invoice, can not be deleted';
		RETURN;
	END		
	ELSE IF ISNULL(@cntItemForAcc,0) > 0
	BEGIN
		SET @output = CONVERT(BIT,0)
		SET @Reason = 'Customer linked to Items, can not be deleted';
		RETURN;
	END	
	ELSE IF ISNULL(@cntOrderHeader,0) > 0
	BEGIN
		SET @output = CONVERT(BIT,0)
		SET @Reason = 'Customer  linked to Order, can not be deleted';
		RETURN;
	END
    ELSE 
		BEGIN
			update Customer
			set IsActive = 0 , IsDelete = 1
			WHERE CustKey = @CustKey
			SET @output = 1;
			SET @Reason = 'Customer Deleted Successfully';
			RETURN;
		END
 END










--select *from customer
