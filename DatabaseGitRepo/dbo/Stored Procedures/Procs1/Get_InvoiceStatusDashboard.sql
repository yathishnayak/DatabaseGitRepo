
CREATE PROCEDURE [dbo].[Get_InvoiceStatusDashboard] -- [Get_InvoiceStatusDashboard] 0
@StatusKey		INT= 0,
@CustomerKey	INT= 0,
@OrderKey		INT= 0,
@OrderDateFrom	DATE='01/01/2020',
@OrderDateTO	DATE='12/31/2099',
@DeliVeryDateFom DATE='01/01/2020',
@DelivaryDateTo	DATE='12/31/2099',
@OrderNo		VARCHAR(50)='',
@containerNo	VARCHAR(50)='',
@InvoiceNo		VARCHAR(50)='',
@InvoiceKey		INT=0,
@BOLNo  VARCHAR(30)=''
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT StatusKey, [Description] AS StatusName INTO #InvStatus
	FROM dbo.InvoiceStatus 
	UNION ALL 
	SELECT 9,'Pending to Invoice'

	SELECT OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,MAX(RT.ActualArrival) AS ActualArrival,CU.CustID,CU.CustName,
		ISNULL(IH.IsInvoiceApproved,0)AS IsInvoiceApproved, 
		ISNULL(INS.[StatusKey],9) AS StatusKey,
		IH.InvoiceAmount,AD.City,
		CASE WHEN  isnull(IH.StatusKey,0) > 0 THEN INS.Description ELSE ISNULL(INS.[Description],'Pending to Invoice') END AS [Status],--RT.RouteKey,
		OH.DestinationAddrKey,IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate INTO #Toinvoice		
	FROM dbo.[routes] RT 
		INNER JOIN dbo.OrderDetail OD		ON RT.OrderDetailKey = OD.OrderDetailkey
		INNER JOIN dbo.OrderDetailStatus ODS ON ODS.Status=OD.Status
		INNER JOIN dbo.OrderHeader OH		ON OH.OrderKey = OD.OrderKey
		INNER JOIN dbo.Customer CU		    ON CU.CustKey = OH.CustKey
		INNER JOIN dbo.Leg LG				ON LG.LegKey = RT.LegKey
		INNER JOIN dbo.LegType L			ON L.LegtypeKey = LG.LegTypeKey		
		INNER JOIN dbo.RouteStatus RTS		ON RTS.[Status]=RT.[Status]	
		LEFT JOIN dbo.RouteInvoice RI		ON RI.OrderdetailKey=OD.OrderDetailKey
		LEFT JOIN dbo.InvoiceHeader IH		ON IH.InvoiceKey=RI.InvoiceKey		
		LEFT JOIN dbo.InvoiceStatus INS		ON INS.[StatusKey]=IH.[StatusKey]
		LEFT JOIN dbo.[Address] AD		ON AD.AddrKey=OH.DestinationAddrKey
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
	FROM dbo.[Routes] RT 
		INNER JOIN dbo.RouteStatus RTS		ON RTS.[Status]=RT.[Status]	
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

	SELECT statusKey, StatusName, StatusCount, 'I' AS LEVEL FROM #temp
	UNION ALL
	SELECT 0, 'All', SUM(StatusCount) AS StatusCount, 'S' AS LEVEL FROM #temp 

END
