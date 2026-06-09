

CREATE PROCEDURE [dbo].[Get_ContainerDispatchList_shiv] -- [Get_ContainerDispatchList_shiv] @StatusKey=9, @InvoiceNo = '193'
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
@BOLNo			VARCHAR(30)=''
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3= Payment Received, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT OH.OrderKey, 
		case when IH.InvoiceKey is null then  od.OrderDetailKey else 0 end as OrderDetailKey ,
		oh.OrderNo,od.ContainerNo, MAX(RT.ActualArrival) AS ActualArrival,
		CU.CustID,CU.CustName,isnull(IH.IsInvoiceApproved,0) as IsInvoiceApproved,
		ISNULL(INS.[StatusKey],9)  AS StatusKey,
		IH.InvoiceAmount,AD.City,
		ISNULL(INS.[Description],'Pending to Invoice')  AS [Status],--RT.RouteKey,
		OH.DestinationAddrKey,IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate,  
		--ISNULL(CDC.DocumentCount,0) AS DocumentCount  --- not requred since its duplicating invoice
		0 AS DocumentCount 
		,IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate,IsRevised, 
		RevisionDate,OH.BrokerRefNo, CU.IsFactored, '' VesselETA
	INTO #Toinvoice		
	FROM dbo.[routes] RT WITH (NOLOCK)
		INNER JOIN dbo.OrderDetail OD		WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN dbo.OrderDetailStatus ODS WITH (NOLOCK) ON ODS.[Status]=OD.[Status]
		INNER JOIN dbo.OrderHeader OH		WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
		INNER JOIN dbo.Customer CU		    WITH (NOLOCK) ON CU.CustKey = OH.CustKey
		INNER JOIN dbo.Leg LG				WITH (NOLOCK) ON LG.LegKey = RT.LegKey
		INNER JOIN dbo.LegType L			WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey		
		INNER JOIN dbo.RouteStatus RTS		WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
		LEFT JOIN dbo.RouteInvoice RI		WITH (NOLOCK) ON RI.OrderDetailKey=OD.OrderDetailKey
		LEFT JOIN dbo.InvoiceHeader IH		WITH (NOLOCK) ON IH.InvoiceKey=RI.InvoiceKey		
		LEFT JOIN dbo.InvoiceStatus INS		WITH (NOLOCK) ON INS.[StatusKey]=IH.[StatusKey]
		LEFT JOIN dbo.[Address] AD			WITH (NOLOCK) ON AD.AddrKey=OH.DestinationAddrKey
		LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
	WHERE 	RTS.[Description]='Leg Completed' AND (ODS.status in (6,10,12,13))
		AND	(  @StatusKey = 0 OR ISNULL(INS.[StatusKey],9) = @StatusKey )
		AND (  @OrderKey =0 OR @OrderKey IS NULL OR OH.OrderKey=@OrderKey )	
		AND (  @CustomerKey =0 OR @CustomerKey IS NULL OR OH.CustKey IS NULL OR OH.CustKey=@CustomerKey )	
		AND	(  @OrderDateFrom	IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate>=@OrderDateFrom )
		AND (  @OrderDateTo		IS NULL OR OH.OrderDate		IS NULL OR OH.OrderDate<=@OrderDateTo )
		AND	(  @DeliVeryDateFom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom )
		AND (  @DelivaryDateTo	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom<=@DelivaryDateTo )
		AND (  @OrderNo			= '' OR OH.OrderNo		IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )	
		AND (  @containerNo		= '' OR OD.ContainerNo	IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )		
		AND (  @InvoiceNo		= '' OR IH.InvoiceNo IS NULL OR ISNULL(IH.InvoiceNo,'NA') like '%' + @InvoiceNo + '%')
		AND (  ISNULL(IH.InvoiceNo,'NA') like '%' + @InvoiceNo + '%')
		AND (  @InvoiceKey		= 0 OR @InvoiceKey IS null OR IH.InvoiceKey IS NULL OR IH.InvoiceKey=@InvoiceKey )
		AND (  @BOLNo			= '' OR @BOLNo IS NULL OR OH.BillOfLading like '%' +@BOLNo+ '%' )
	GROUP BY OH.OrderKey,oh.OrderNo,od.ContainerNo,CU.CustName,IH.IsInvoiceApproved,
		ISNULL(INS.[StatusKey],9),IH.InvoiceAmount,AD.City,OH.DestinationAddrKey,
		IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate,CU.CustID,INS.[Description] 
		,IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate,IsRevised, 
		RevisionDate, BrokerRefNo, CU.IsFactored, -- OD.VesselETA,
		case when IH.InvoiceKey is null then  od.OrderDetailKey else 0 end

	SELECT DISTINCT RT.OrderDetailKey INTO #PendingLegContainers
	FROM dbo.[Routes] RT WITH (NOLOCK)
		INNER JOIN dbo.RouteStatus RTS		WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
		INNER JOIN #Toinvoice G				WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE RTS.[Description] <>'Leg Completed'

	SELECT DISTINCT RT.OrderDetailKey INTO #PendingRateConfirm
	FROM dbo.[Routes] RT  WITH (NOLOCK)
		INNER JOIN dbo.RouteStatus RTS		 WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
		INNER JOIN #Toinvoice G				 WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE RTS.[Description] ='Leg Completed' AND RT.IsRateVerified=0

	DELETE 
	FROM #Toinvoice 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #PendingLegContainers )

	SELECT ContCount,InvoiceKey INTO #MultContainer 
	FROM		
	(
		SELECT COUNT(1) AS ContCount,T.InvoiceKey 
		FROM dbo. RouteInvoice S  WITH (NOLOCK)
		INNER JOIN ( SELECT DISTINCT InvoiceKey FROM #Toinvoice ) T  ON T.InvoiceKey=S.InvoiceKey			
	GROUP BY T.InvoiceKey 
	) D

	SELECT  A.OrderKey,
	case when A.InvoiceKey is null then  A.OrderDetailKey else 0 end as OrderDetailKey ,
	OrderNo,	
		CASE WHEN isnull(M.ContCount,1)=1 THEN MAX(A.ContainerNo) ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo,--A.ContainerNo,
		MAX(ActualArrival) AS ActualArrival,CustID,CustName,A.City,A.IsInvoiceApproved,
		A.StatusKey,[Status],A.InvoiceAmount,DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,
		A.ContainerNo,
		Max(A.DocumentCount) as DocumentCount,
		H.CustomerNote, H.InternalNote , 
		CASE WHEN F.OrderDetailKey IS NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsRateVerified,M.ContCount
		,h.IsPrinted, h.PrintedUserKey, H.PaymentRecdUserKey, H.PaymentRecdDate, H.PrintedDate,H.IsRevised, 
		H.RevisionDate, 
		H.RevisionUserKey, U1.UserName AS ApprovedUserName, U2.UserName as PrintedUserName, 
		U3.UserName as PaymentRecdUserName, 
		U4.UserName as RevisedUserName, H.IsPaymentReceived,
		A.BrokerRefNo, IsFactored, A.VesselETA
	FROM #Toinvoice A		
		LEFT JOIN InvoiceHeader H  WITH (NOLOCK) on A.InvoiceKey = H.InvoiceKey
		LEFT JOIN #PendingRateConfirm F ON F.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #MultContainer M ON M.InvoiceKey=A.InvoiceKey
		LEFT JOIN [User] U1 WITH (NOLOCK)  ON H.InvoiceApprovedUserKey = U1.UserKey
		LEFT JOIN [User] U2 WITH (NOLOCK) ON H.PrintedUserKey = U2.UserKey
		LEFT JOIN [User] U3 WITH (NOLOCK) ON H.PaymentRecdUserKey = U3.UserKey
		LEFT JOIN [User] U4 WITH (NOLOCK) ON H.RevisionUserKey = U4.UserKey
	GROUP BY A.OrderKey,OrderNo,CustID,CustName,A.City,A.IsInvoiceApproved,A.StatusKey,A.OrderDetailKey,
		[Status],A.InvoiceAmount,DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,H.CustomerNote,H.InternalNote,
		F.OrderDetailKey,M.ContCount, A.ContainerNo,
		h.IsPrinted, h.PrintedUserKey, H.PaymentRecdUserKey, H.PaymentRecdDate, H.PrintedDate,H.IsRevised, H.RevisionDate,
		H.RevisionUserKey, U1.UserName, U2.UserName, U3.UserName, u4.UserName, H.IsPaymentReceived
		, BrokerRefNo, IsFactored, VesselETA
	--ORDER BY (case when @StatusKey = 9 then OrderNo else A.InvoiceNo end) desc
	order by A.ContainerNo
	
END
