/** 
DECLARE 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{
    "OrderNo": "ACER25121430",
    "CustId": "3165",
    "NewCustId": "3232",
    "UserKey": 953
}'
		EXEC [UTIL_OrderCustomerRemap_V3] @Userkey, @JSONSTRING, @IsDebug, @Status OUTPUT, @Reason OUTPUT 
SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[UTIL_OrderCustomerRemap_V3]
(
	@UserKey		INT=953,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 0,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)

--ALTER Procedure [dbo].[UTIL_OrderCustomerRemap_Ruthu_20260205]
--(
--	@OrderNo	VARCHAR(20),
--	@CustId		VARCHAR(20),
--	@NewCustId	VARCHAR(20),
--	@UserKey	INT,
--	@Status		bit = 0 OUTPUT,
--	@Reason		VARCHAR(100) = '' OUTPUT,
--	@NewOrderno	VARCHAR(20) = '' OUTPUT
--)
as
Begin

SET NOCOUNT ON;
	SET FMTONLY OFF
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	
	DECLARE 
	@OrderNo			VARCHAR(50),
	@CustId				VARCHAR(100),
	@NewCustId			VARCHAR(100),
	@NewOrderno			VARCHAR(50)
	-- @CustKey			VARCHAR(50),
	-- @NewCustKey		     VARCHAR(50),

	SELECT @OrderNo = OrderNo,@CustId=CustId,@NewCustId=NewCustId
	--, @NewOrderno = NewOrderno
	-- ,@CustKey=CustKey,@NewCustKey=NewCustKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			OrderNo			VARCHAR(50)				'$.OrderNo',
			CustId			VARCHAR(50)				'$.CustId',
			NewCustId		VARCHAR(100)			'$.NewCustId'
			--NewOrderno		VARCHAR(20)				'$.NewOrderno'
		)


	DECLARE @Cur as Cursor
	DECLARE @OldAddrKey as INT 
	DECLARE @OldCustKey as INT 
	DECLARE @NewCustKey as INT 
	DECLARE @NewAddrKey as INT 
	DECLARE @UserName	VARCHAR(50)
	DECLARE @TranStarted BIT = 0;


	SELECT @UserName = UserName FROM [User] WITH (NOLOCK) WHERE userkey = @UserKey

	DECLARE @OrderKey INT 
	DECLARE @OrderDetailKey INT
	DECLARE @RoutKey INT 
	DECLARE @InvoiceKey INT
	
	DECLARE @CNT INT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader WITH (NOLOCK) WHERE OrderNo = @OrderNo
	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Order not exists'
		return
	END

	SET @CNT = 0
	SELECT @CNT = COUNT(1) FROM OrderHeader OH WITH (NOLOCK)
	INNER JOIN Customer C WITH (NOLOCK) on OH.CustKey = C.CustKey
	WHERE OrderNo = @OrderNo and C.CustKey = @CustId

	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid FROM Customer'
		return
	END

	SET @CNT = 0
	SELECT @CNT = COUNT(1) FROM Customer WITH (NOLOCK)
	WHERE CustKey = @NewCustId

	IF(ISNULL(@CNT,0) = 0)
	BEGIN
		SET @Status = 0
		SET @Reason = 'Invalid To Customer'
		return
	END

	DECLARE @tmp TABLE
(
    OrderKey INT,
    CustKey INT,
    OrderBillTo INT,
    OrderSource INT,
    OrderDest INT,
    OrderReturn INT,
    OrderDetailKey INT,
    DetaiLSource INT,
    DetailDest INT,
    RouteKey INT,
    RoutSource INT,
    RoutDest INT,
    InvoiceKey INT,
    InvBillTo INT
);
	INSERT INTO @tmp
	SELECT A.OrderKey,  A.CustKey,  A.BillToAddrKey AS OrderBillTo, A.SourceAddrKey AS OrderSource, A.DestinationAddrKey AS OrderDest, A.ReturnAddrKey AS OrderReturn, 
	B.OrderDetailKey,  B.SourceAddrKey AS DetaiLSource, B.DestinationAddrKey AS DetailDest, 
	C.RouteKey,  
	CASE WHEN L.FROMLocation IN ('Customer','Consignee')  THEN C.SourceAddrKey  ELSE 0 END AS RoutSource,
	CASE WHEN L.ToLocation IN ('Customer','Consignee')  THEN C.DestinationAddrKey  ELSE 0 END AS RoutDest, 
	D.InvoiceKey,  D.BillToAddrKey AS InvBillTo 
	FROM Orderheader A WITH (NOLOCK)
	INNER JOIN  OrderDetail B WITH (NOLOCK) ON (A.OrderKey = B.OrderKey)
	LEFT OUTER JOIN Routes  C WITH (NOLOCK) ON (B.OrderDetailKey = C.OrderDetailKey)
	LEFT OUTER JOIN LEG L WITH (NOLOCK) ON C.legkey = L.LegKey
	LEFT OUTER JOIN InvoiceHeader  D WITH (NOLOCK) ON (A.OrderKey = D.OrderKey)
	LEFT OUTER JOIN Customer E WITH (NOLOCK) ON (A.CustKey = E.CustKey)
	WHERE A.OrderNo = @OrderNo AND E.CustKey = @CustId

	SELECT DISTINCT  @OldCustKey = CustKey FROM @tmp
	SELECT @NewCustKey =   CustKey FROM Customer WITH (NOLOCK) WHERE CustKey =@NewCustId		
	SET @NewCustId=(SELECT CustId FROM Customer WITH (NOLOCK) WHERE CustKey=@NewCustKey)
	IF  ISNULL(@OldCustKey,0) = 0 OR ISNULL(@NewCustKey,0) =0 RETURN 

	BEGIN TRY
    IF @@TRANCOUNT = 0
    BEGIN
        BEGIN TRAN;
        SET @TranStarted = 1;
    END
		SET @Cur = CURSOR FOR 
			SELECT OrderKey,  OrderDetailKey, RouteKey, InvoiceKey  FROM @tmp
		OPEN @Cur
		WHILE (0=0)
		BEGIN
	  
		   FETCH NEXT FROM @Cur INTO  @OrderKey, @OrderDetailKey,@RoutKey,  @InvoiceKey
		   IF @@FETCH_STATUS <> 0 BREAK

		   --Order header UPDATEs
		   UPDATE OrderHeader SET CustKey = @NewCustKey WHERE orderKey = @OrderKey
		  
		   --SELECT @OldAddrKey= OrderBillTo  FROM @tmp WHERE orderkey = @OrderKey
		   --EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   SELECT @NewAddrKey = BillToAddrKey FROM Customer WITH (NOLOCK)  WHERE CustKey=@NewCustKey
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderHeader SET BillToAddrKey = @NewAddrKey WHERE orderKey = @OrderKey

		   SELECT @OldAddrKey= OrderSource  FROM @tmp WHERE orderkey = @OrderKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderHeader SET SourceAddrKey = @NewAddrKey WHERE orderKey = @OrderKey

		   SELECT @OldAddrKey= OrderDest  FROM @tmp WHERE orderkey = @OrderKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderHeader SET DestinationAddrKey = @NewAddrKey WHERE orderKey = @OrderKey

			SELECT @OldAddrKey= OrderReturn  FROM @tmp WHERE orderkey = @OrderKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderHeader SET ReturnAddrKey = @NewAddrKey WHERE orderKey = @OrderKey


		   --Order Deail UPDATEs
		   SELECT @OldAddrKey= DetaiLSource  FROM @tmp WHERE OrderDetailKey = @OrderDetailKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderDetail SET SourceAddrKey = @NewAddrKey WHERE OrderDetailKey = @OrderDetailKey

		   SELECT @OldAddrKey= DetailDest  FROM @tmp WHERE OrderDetailKey = @OrderDetailKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE OrderDetail SET DestinationAddrKey = @NewAddrKey WHERE OrderDetailKey = @OrderDetailKey

		   --Route detail UPDATEs
		   SELECT @OldAddrKey= RoutSource  FROM @tmp WHERE RouteKey = @RoutKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE Routes SET SourceAddrKey = @NewAddrKey WHERE RouteKey = @RoutKey

		   SELECT @OldAddrKey= RoutDest  FROM @tmp WHERE RouteKey = @RoutKey
		   EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   IF ISNULL(@NewAddrKey,0) <>0  UPDATE Routes SET DestinationAddrKey = @NewAddrKey WHERE RouteKey = @RoutKey

		   --Invoice  UPDATEs
		   --SELECT @OldAddrKey= InvBillTo  FROM @tmp WHERE InvoiceKey = @InvoiceKey
		   --EXEC UTIL_CopyCustAddress  @OldAddrKey, @OldCustKey, @NewCustKey, @NewAddrKey OUTPUT 
		   --IF ISNULL(@NewAddrKey,0) <>0  
			SELECT @NewAddrKey = BillToAddrKey FROM Customer WITH (NOLOCK) WHERE CustKey=@NewCustKey
		    UPDATE InvoiceHeader SET BillToAddrKey = @NewAddrKey WHERE InvoiceKey = @InvoiceKey

			
		END
		CLOSE @Cur
		DEALLOCATE @cur

		DECLARE  @OrdCount INT = 0,  @OrderDate DATETIME
		SELECT @OrderDate = OrderDate FROM OrderHeader WITH (NOLOCK) WHERE orderkey = @OrderKey
		SELECT @OrdCount = COUNT(1) FROM orderheader WITH (NOLOCK) WHERE orderno LIKE @NewCustId + CONVERT(VARCHAR,RIGHT(YEAR(@OrderDate),2))
			+ RIGHT(CONVERT(VARCHAR, 100 + MONTH(@OrderDate)),2) + '%'
		SELECT @OrdCount = ISNULL(@OrdCount,0) + 1
		SELECT @NewOrderNo = @NewCustId+CONVERT(VARCHAR,RIGHT(year(@OrderDate),2)) + RIGHT(CONVERT(VARCHAR, 100 + MONTH(@OrderDate)),2) 
				+ RIGHT( CONVERT(VARCHAR,1000 + @OrdCount),3)
		--SELECT @OrderDate, @OrdCount, @NewOrderno
		UPDATE Orderheader SET Orderno = @NewOrderNo WHERE OrderKey = @OrderKey

		UPDATE IH SET CustKey = OH.CustKey
		FROM invoiceHeader IH
		INNER JOIN Invoicedetail ID WITH (NOLOCK) ON IH.InvoiceKey = ID.InvoiceKey
		INNER JOIN OrderDetail OD WITH (NOLOCK) ON ID.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
		WHERE OH.OrderKey = @OrderKey

		INSERT INTO OrderHeader_AuditLog(OrderKey, LogDate, LogText, ActionUserKey, MainAuditLogKey)
		SELECT @OrderKey, GETDATE(), 'Order: ' +  @OrderNo + ' - Customer changed FROM ' + @CustId + ' to ' + @NewCustId,
			@UserKey, 1

		INSERT INTO Invoice_Log(InvoiceKey, LogDate, LogText, ActionUserKey)
		SELECT DISTINCT IH.InvoiceKey, GETDATE(), 'Order: ' +  @OrderNo + ' - Customer changed FROM ' + @CustId + ' to ' + @NewCustId,
			@UserKey
		FROM invoiceHeader IH WITH (NOLOCK)
		INNER JOIN Invoicedetail ID WITH (NOLOCK) ON IH.InvoiceKey = ID.InvoiceKey
		INNER JOIN OrderDetail OD WITH (NOLOCK) ON ID.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
		WHERE OH.OrderKey = @OrderKey

		IF @TranStarted = 1 AND XACT_STATE() = 1
    COMMIT TRAN;

		SET @Status = 1
		SET @Reason = 'Updated Successfully'

		SELECT @Status Status,  @Reason Reason, @NewOrderNo NewOrderNo For JSON PATH, WITHOUT_ARRAY_WRAPPER

	END Try
	Begin Catch
		IF @TranStarted = 1 AND XACT_STATE() <> 0
			ROLLBACK TRAN;

		SET @Status = 0;
		SET @Reason = ERROR_MESSAGE();
	END Catch
END