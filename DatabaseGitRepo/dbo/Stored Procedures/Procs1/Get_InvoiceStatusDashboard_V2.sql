/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{}'
	EXEC [Get_InvoiceStatusDashboard_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
SELECT @Status AS Status, @Reason AS Reason 
**/
CREATE PROCEDURE [dbo].[Get_InvoiceStatusDashboard_V2] -- [Get_InvoiceStatusDashboard] 0
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	--IF ISNULL(@JSONString, '') = ''
	--	BEGIN
	--		SET		@Status = 0
	--		SET		@Reason = 'Parameters not found'
	--		RETURN
	--	END	

	DECLARE
	@StatusKey			INT= 0,
	@CustomerKey		INT= 0,
	@OrderKey			INT= 0,
	@OrderDateFrom		DATE='01/01/2020',
	@OrderDateTO		DATE='12/31/2099',
	@DeliVeryDateFom	 DATE='01/01/2020',
	@DelivaryDateTo		DATE='12/31/2099',
	@OrderNo			VARCHAR(50)='',
	@containerNo		VARCHAR(50)='',
	@InvoiceNo			VARCHAR(50)='',
	@InvoiceKey			INT=0,
	@BOLNo				VARCHAR(30)=''

	SELECT
	@StatusKey			= StatusKey			,
	@CustomerKey		= CustomerKey		,
	@OrderKey			= OrderKey			,
	@OrderDateFrom		= OrderDateFrom		,
	@OrderDateTO		= OrderDateTO		,
	@DeliVeryDateFom	= DeliVeryDateFom	,
	@DelivaryDateTo		= DelivaryDateTo	,
	@OrderNo			= OrderNo			,
	@containerNo		= containerNo		,
	@InvoiceNo			= InvoiceNo			,
	@InvoiceKey			= InvoiceKey		,
	@BOLNo				= BOLNo			
	FROM OPENJSON(@JSONString)
	WITH
	(
	StatusKey					INT				'$.StatusKey',			
	CustomerKey					INT				'$.CustKey',		
	OrderKey					INT				'$.OrderKey',			
	OrderDateFrom				DATE			'$.OrderDateFrom',		
	OrderDateTO					DATE			'$.OrderDateTO',		
	DeliVeryDateFom				DATE			'$.DeliVeryDateFom',	
	DelivaryDateTo				DATE			'$.DelivaryDateTo',	
	OrderNo						VARCHAR(50)		'$.OrderNo',			
	containerNo					VARCHAR(50)		'$.ContainerNo',	
	InvoiceNo					VARCHAR(50)		'$.InvoiceNo',			
	InvoiceKey					INT				'$.InvoiceKey',		
	BOLNo						VARCHAR(30)		'$.BOLNo'
	)


	SELECT StatusKey, [Description] AS StatusName INTO #InvStatus
	FROM dbo.InvoiceStatus WITH(NOLOCK)
	UNION ALL 
	SELECT 9,'Pending to Invoice'

	SELECT OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,MAX(RT.ActualArrival) AS ActualArrival,CU.CustID,CU.CustName,
		ISNULL(IH.IsInvoiceApproved,0)AS IsInvoiceApproved, 
		ISNULL(INS.[StatusKey],9) AS StatusKey,
		IH.InvoiceAmount,AD.City,
		CASE WHEN  isnull(IH.StatusKey,0) > 0 THEN INS.Description ELSE ISNULL(INS.[Description],'Pending to Invoice') END AS [Status],--RT.RouteKey,
		OH.DestinationAddrKey,IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate INTO #Toinvoice		
	FROM dbo.[routes] RT WITH (NOLOCK)
		INNER JOIN dbo.OrderDetail OD WITH (NOLOCK)			ON RT.OrderDetailKey = OD.OrderDetailkey
		INNER JOIN dbo.OrderDetailStatus ODS WITH (NOLOCK)	ON ODS.Status=OD.Status
		INNER JOIN dbo.OrderHeader OH WITH (NOLOCK)			ON OH.OrderKey = OD.OrderKey
		INNER JOIN dbo.Customer CU WITH (NOLOCK)			ON CU.CustKey = OH.CustKey
		INNER JOIN dbo.Leg LG WITH (NOLOCK)					ON LG.LegKey = RT.LegKey
		INNER JOIN dbo.LegType L WITH (NOLOCK)				ON L.LegtypeKey = LG.LegTypeKey		
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)		ON RTS.[Status]=RT.[Status]	
		LEFT JOIN dbo.RouteInvoice RI WITH (NOLOCK)			ON RI.OrderdetailKey=OD.OrderDetailKey
		LEFT JOIN dbo.InvoiceHeader IH WITH (NOLOCK)		ON IH.InvoiceKey=RI.InvoiceKey		
		LEFT JOIN dbo.InvoiceStatus INS WITH (NOLOCK)		ON INS.[StatusKey]=IH.[StatusKey]
		LEFT JOIN dbo.[Address] AD WITH (NOLOCK)			ON AD.AddrKey=OH.DestinationAddrKey
	WHERE 	RTS.[Description]='Leg Completed' AND   (ODS.status in (6,10,12,13))
		AND	(  @StatusKey = 0 OR  --ISNULL(INS.[StatusKey],9)= @StatusKey
			    ISNULL(INS.[StatusKey],9) = @StatusKey
		    )
		AND (  @OrderKey =0 OR @OrderKey IS NULL OR OH.OrderKey=@OrderKey )
		AND (  @CustomerKey =0 OR @CustomerKey IS NULL OR OH.CustKey IS NULL OR OH.CustKey=@CustomerKey )
		AND	(  @OrderDateFrom	IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate>=@OrderDateFrom)
		AND (  @OrderDateTo		IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate<=@OrderDateTo)
		AND	(  @DeliVeryDateFom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom)
		AND (  @DelivaryDateTo	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom<=@DelivaryDateTo)
		AND (  @OrderNo			= '' OR OH.OrderNo		IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
		AND (  @containerNo		= '' OR OD.ContainerNo	IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
		AND (  @InvoiceNo		= '' OR IH.InvoiceNo IS NULL OR ISNULL(IH.InvoiceNo,'NA') like '%' + @InvoiceNo + '%')
		AND (  @InvoiceKey		= 0 OR @InvoiceKey IS null OR IH.InvoiceKey IS NULL OR IH.InvoiceKey=@InvoiceKey )
		AND (  @BOLNo			= '' OR @BOLNo IS NULL OR OH.BillOfLading like '%' +@BOLNo+ '%' )
	GROUP BY OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,CU.CustName,IH.IsInvoiceApproved,
		ISNULL(INS.[StatusKey],9),IH.InvoiceAmount,AD.City,OH.DestinationAddrKey,
		IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate,CU.CustID,INS.[Description] , IH.StatusKey

	SELECT DISTINCT RT.OrderDetailKey INTO #PrndingLegContainers
	FROM dbo.[Routes] RT WITH (NOLOCK)  
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)		ON RTS.[Status]=RT.[Status]	
		INNER JOIN #Toinvoice G ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE RTS.[Description] <>'Leg Completed'

	DELETE 
	FROM #Toinvoice 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #PrndingLegContainers )

	SELECT S.StatusKey, StatusName , ISNULL(A.cnt,0) AS StatusCount
	INTO #Temp
	FROM #InvStatus S
	LEFT JOIN (
			SELECT Z.StatusKey, COUNT(1) cnt 
			FROM (
					SELECT DISTINCT OrderKey,OrderDetailKey,OrderNo,ContainerNo,ActualArrival,CustID,CustName,City,IsInvoiceApproved,
						StatusKey,InvoiceAmount,DestinationAddrKey,InvoiceKey,InvoiceNo,InvoiceDate
					FROM #Toinvoice			
					
				) Z
			GROUP BY StatusKey
			) A ON S.StatusKey = A.StatusKey

	SELECT StatusKey, StatusName, StatusCount, 'I' AS Level FROM #temp
	UNION ALL
	SELECT 0, 'All', SUM(StatusCount) AS StatusCount, 'S' AS Level FROM #temp 
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'

END