/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"FromDate":null, "ToDate":null}'
	EXEC [Get_IncomeReport_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
**/

/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"ToDate":"2025-06-18T18:30:00.000Z","FromDate":"2017-05-09T18:30:00.000Z"}'
	EXEC [Get_IncomeReport_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[Get_IncomeReport_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)

AS

BEGIN
SET NOCOUNT ON
	SET FMTONLY OFF


	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@FromDate		DATETIME,
		@ToDate			DATETIME
	SELECT 
		@FromDate  = FromDate,
		@ToDate	   = ToDate
	FROM OPENJSON(@JSONString)
	WITH(
		FromDate DATETIME '$.FromDate',
		ToDate   DATETIME '$.ToDate'
	)

	SET			@FromDate = CASE WHEN ISNULL(@FromDate,'') = '' THEN DATEADD(DAY,-180,CAST(GETDATE() AS DATE)) ELSE @FromDate END
	SET			@ToDate = CASE WHEN ISNULL(@ToDate,'') = '' THEN GETDATE() ELSE @ToDate END

	  select 'JCB' as Company, E.CustID, E.CustName, InvoiceNo, 'Order' as Type, D.InvoiceAmount, D.InvoiceDate, F.OrderNo,   ContainerNo,
      ItemId   as Item,  Sum(ExtAmt) as ExtAmt from  Invoicedetail  A WITH (NOLOCK)
      inner join OrderDetail B WITH (NOLOCK) on (A.OrderDetailKey = B.OrderDetailKey)
      inner join Item C WITH (NOLOCK) on (A.ItemKey = C.ItemKey)
      inner join InvoiceHeader D WITH (NOLOCK) on (A.InvoiceKey = D.InvoiceKey)
      inner join Customer E WITH (NOLOCK) on (D.CustKey = E.CustKey)
      inner join OrderHeader F WITH (NOLOCK) on (B.OrderKey = F.OrderKey)
	  WHERE D.CreateDate BETWEEN @FromDate AND @ToDate
      Group by E.CustID, E.CustName, InvoiceNo,D.InvoiceAmount,   F.OrderNo,  ContainerNo, ItemId , D.InvoiceDate
      
	  union all
      
	  select 'JCB' as Company, E.CustID, E.CustName, D.MInvoiceNo , 'Manual' as Type,  D.MInvoiceAmount, D.MInvoiceDate, '' as OrderNo,  
      isnull(ContainerNo,''),
      ItemId   as Item,  Sum(A.ExtCost) as ExtAmt from  ManualInvoiceDetail A WITH (NOLOCK)    
      inner join Item C WITH (NOLOCK) on (A.ItemKey = C.ItemKey)
      inner join ManualInvoiceHeader D WITH (NOLOCK) on (A.MInvoiceKey = D.MInvoiceKey)
      inner join Customer E WITH (NOLOCK) on (D.CustomerKey = E.CustKey)
	  WHERE D.CreatedDate BETWEEN @FromDate AND @ToDate
      Group by E.CustID, E.CustName, MInvoiceNo,D.MInvoiceAmount,   isnull(ContainerNo,''), ItemId , D.MInvoiceDate
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END