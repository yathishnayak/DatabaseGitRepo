/**
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"CustKey": 3}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Delete_Customer_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Delete_Customer_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"CustKey": 0}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
 BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @CustKey INT = 0;
    
    -- Parse JSON input
    SELECT @CustKey = ISNULL(CustKey, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        CustKey INT '$.CustKey'
    );

	DECLARE @cntCust     int = 0,
	        @cntConsignee int = 0,
	      --  @cntCustrAddrint INT= 0,
			@cntCustrItemRate int = 0,
	        @cntInvoiceHeader INT= 0,
			@cntItemForAcc int = 0,
	        @cntOrderHeader INT= 0,
			@UserName varchar(30),
			@CustName varchar(50),
			@CustId varchar(20)
			

   SET @cntCust = (SELECT COUNT(CustName) FROM Customer WITH (NOLOCK) WHERE CustKey = @CustKey)
   SET @cntConsignee = (SELECT COUNT(1) FROM Consignee WITH (NOLOCK) WHERE CustKey = @CustKey)
  -- SET @cntCustrAddrint = (SELECT COUNT(1) FROM CustomerAddress WHERE CustKey = @CustKey)
   SET @cntCustrItemRate = (SELECT COUNT(1) FROM CustomerItemRate WITH (NOLOCK) WHERE CustomerKey = @CustKey)
   SET @cntInvoiceHeader = (SELECT COUNT(1) FROM InvoiceHeader WITH (NOLOCK) WHERE CustKey = @CustKey)
   SET @cntItemForAcc = (SELECT COUNT(1) FROM ItemsForAccounting WITH (NOLOCK) WHERE CustomerKey = @CustKey)
   SET @cntOrderHeader = (SELECT COUNT(1) FROM OrderHeader WITH (NOLOCK) WHERE CustKey = @CustKey)
   SELECT @UserName=ISNULL(UserName, '') FROM [User] WITH(NOLOCK) WHERE UserKey=@UserKey
   SELECT @CustName=ISNULL(CustName, '') FROM Customer WITH(NOLOCK) WHERE CustKey = @CustKey
   SELECT @CustId=ISNULL(CustID, '') FROM Customer WITH(NOLOCK) WHERE CustKey = @CustKey

   IF iSNULL(@cntCust,0) = 0
		BEGIN
			SET @Status  = CONVERT(BIT,0);
			SET @Reason  = 'No record  found for the given Customer';
			RETURN;
		END 
   ELSE IF  ISNULL(@cntConsignee,0) > 0
   BEGIN
		SET @Status  = CONVERT(BIT,0);
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
		SET @Status = CONVERT(BIT,0)
		SET @Reason = 'Customer linked to Item Rate, can not be deleted';
        RETURN;
	END
	ELSE IF ISNULL(@cntInvoiceHeader,0) > 0
	BEGIN
		SET @Status = CONVERT(BIT,0)
		SET @Reason = 'Customer linked to Invoice, can not be deleted';
		RETURN;
	END		
	ELSE IF ISNULL(@cntItemForAcc,0) > 0
	BEGIN
		SET @Status = CONVERT(BIT,0)
		SET @Reason = 'Customer linked to Items, can not be deleted';
		RETURN;
	END	
	ELSE IF ISNULL(@cntOrderHeader,0) > 0
	BEGIN
		SET @Status = CONVERT(BIT,0)
		SET @Reason = 'Customer  linked to Order, can not be deleted';
		RETURN;
	END
    ELSE 
		BEGIN
			update Customer
			set IsActive = 0 , IsDelete = 1
			WHERE CustKey = @CustKey
			SET @Status = 1;
			SET @Reason = 'Customer Deleted Successfully';
			INSERT INTO AuditLogDetail(DateCreated,CreateUser,RefType,RefId,RefKey,Stage,CommentType,Comments)
			SELECT GETDATE(),@UserName,'Customer',@CustId,@CustKey,null,'Text','Customer ' + @CustName + ' deleted by ' + @UserName
			RETURN;
		END
 END