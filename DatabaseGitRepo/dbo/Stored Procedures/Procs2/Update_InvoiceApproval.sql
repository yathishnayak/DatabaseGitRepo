


CREATE PROCEDURE [dbo].[Update_InvoiceApproval]
@InvoiceKey			INT,
@UserKey			INT,
@InvoiceCompanyKey	INT=0,
@Output				BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @STATUSKEY INT = 0,
			@isPaymentReceived  Bit = 0,
			@CustKey	INT=0

	SELECT @STATUSKEY = StatusKey FROM InvoiceStatus WHERE Description = 'Approved'
	SELECT @CustKey = CustKey FROM InvoiceHeader WHERE InvoiceKey = @InvoiceKey

	Select @isPaymentReceived = isnull(IsPaymentReceived,0) from dbo.InvoiceHeader where InvoiceKey = @InvoiceKey
	if(@isPaymentReceived = 1)
	begin
		SELECT @STATUSKEY = StatusKey FROM InvoiceStatus WHERE Description = 'Payment Received'
	end
	SET @Output=0;

	UPDATE dbo.InvoiceHeader
	SET IsInvoiceApproved= case when isnull(@isPaymentReceived,0) = 1 then 3 else 2 end ,
		InvoiceApprovedUserKey=@UserKey,InvoiceApprovedDate=GETDATE(),
		StatusKey = @STATUSKEY,InvoiceCompanyKey=@InvoiceCompanyKey
	WHERE InvoiceKey= @InvoiceKey;

	IF(@CustKey IN (1966,2423,2567,3170,3402,3146,3147,3166,3318,3396,3410,3165,1559,1716,1717,1718,1719,1720,1721,1723,1724,1725,1726
					,1727,1728,1729,1730,1739,2778,2851,2899,2979,3032,3033,3042,3201,3312,3374))
	BEGIN
		UPDATE dbo.InvoiceHeader
		SET AprovedReasonCodeKey=1
		WHERE InvoiceKey= @InvoiceKey;
	END

	UPDATE InvoicePayment
	SET StatusKey =1 where Invoicekey=@InvoiceKey

	--********************Order Header And Order Detail Status**************
	UPDATE OD
	SET OD.[Status]= ( SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description]='Approved for Invoice/Driver Pay' ),StatusDate=GETDATE()
	FROM DBO.Invoicedetail ID 		
		INNER JOIN dbo.OrderDetail OD ON OD.OrderDetailKey=ID.OrderDetailKey
		INNER JOIN dbo.OrderHeader OH ON Oh.OrderKey=OD.OrderKey
	WHERE ID.InvoiceKey = @InvoiceKey;


	SELECT DISTINCT OD.orderKey INTO #Orders
	FROM dbo.Invoicedetail ID 
		INNER JOIN dbo.OrderDetail OD ON OD.OrderDetailKey=ID.OrderDetailKey
	WHERE ID.InvoiceKey= @InvoiceKey;

	DELETE FROM #Orders
	WHERE OrderKey IN
	(
		SELECT A.OrderKey 
		FROM #Orders A 
			INNER JOIN dbo.OrderDetail OD ON OD.OrderKey=A.OrderKey
			INNER JOIN dbo.OrderDetailStatus ODS ON ODS.[Status]=OD.[Status]
		WHERE ODS.[Description]<>'Approved for Invoice/Driver Pay'
	);

	UPDATE dbo.OrderHeader
	SET [Status]= ( SELECT [Status] FROM dbo.OrderStatus WHERE [Description]='Invoice Generated' )
	WHERE OrderKey IN ( SELECT OrderKey FROM #Orders );
	--****************************************************************************
	SET @Output=1;
END
