CREATE PROCEDURE [dbo].[PendingToInvoice_GetReport] -- PendingToInvoice_GetReport @StatusKey=2
(
	@StatusKey		INT= 9,
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
	@BOLNo			VARCHAR(30)='',
	@SearchText		varchar(50)='',
	@TermDateFrom	DATE='01/01/2020',
	@TermDateTO		DATE='12/31/2099'
)
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3= Payment Received, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	if  Left(@InvoiceNo, 1) = '0'   set @InvoiceNo=  right(@InvoiceNo, Len(@InvoiceNo)-1)

	SELECT OH.OrderKey, 
		case when IH.InvoiceKey is null then  od.OrderDetailKey else 0 end as OrderDetailKey ,
		oh.OrderNo,od.ContainerNo, MAX(isnull(RT.ActualArrival,getdate())) AS ActualArrival,
		CU.CustID,CU.CustName,isnull(IH.IsInvoiceApproved,0) as IsInvoiceApproved,
		ISNULL(INS.[StatusKey],9)  AS StatusKey,
		IH.InvoiceAmount,AD.City,
		ISNULL(INS.[Description],'Pending to Invoice')  AS [Status],--RT.RouteKey,
		OH.DestinationAddrKey,IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate,  
		--ISNULL(CDC.DocumentCount,0) AS DocumentCount  --- not requred since its duplicating invoice
		0 AS DocumentCount 
		,IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate,IsRevised, 
		RevisionDate,isnull(IH.BrokerRefNo, OH.BrokerRefNo) as BrokerRefNo, 
		CU.IsFactored, OD.VesselETA, isnull(VIB.BalanceAmount,IH.InvoiceAmount) as BalanceAmount
		, OH.CustKey , OH.OrderDate, OH.BillOfLading, OD.CompleteDate as TerminationDate
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
		Left JOIN vInvoiceBalanceAmount VIB  WITH (NOLOCK) on IH.InvoiceKey = VIB.InvoiceKey
	WHERE 	RTS.[Description]='Leg Completed' AND (ODS.status in (6,10,12,13))
		AND IH.InvoiceNo is null
		AND	(  @DeliVeryDateFom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliVeryDateFom )
		AND (  @DelivaryDateTo	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom<=@DelivaryDateTo )
	GROUP BY OH.OrderKey,oh.OrderNo,od.ContainerNo,CU.CustName,IH.IsInvoiceApproved,
		ISNULL(INS.[StatusKey],9),IH.InvoiceAmount,AD.City,OH.DestinationAddrKey,
		IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate,CU.CustID,INS.[Description] 
		,IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate,IsRevised, 
		RevisionDate, isnull(IH.BrokerRefNo, OH.BrokerRefNo), CU.IsFactored, OD.VesselETA, VIB.BalanceAmount,
		case when IH.InvoiceKey is null then  od.OrderDetailKey else 0 end
		, OH.CustKey, OH.OrderDate, OH.BillOfLading, OD.CompleteDate 

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
		MAX(ActualArrival) AS ActualArrival,CustID,CustName,A.City as DestinationCity,A.IsInvoiceApproved,
		A.StatusKey,[Status],A.InvoiceAmount,A.DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,
		Max(A.DocumentCount) as DocumentCount,
		H.CustomerNote, H.InternalNote , 
		CASE WHEN F.OrderDetailKey IS NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsRateVerified,M.ContCount
		,h.IsPrinted, h.PrintedUserKey, H.PaymentRecdUserKey, H.PaymentRecdDate, H.PrintedDate,H.IsRevised, 
		H.RevisionDate, 
		H.RevisionUserKey, U1.UserName AS ApprovedUserName, U2.UserName as PrintedUserName, 
		U3.UserName as PaymentRecdUserName, 
		U4.UserName as RevisedUserName, H.IsPaymentReceived,
		A.BrokerRefNo, IsFactored, isnull(A.VesselETA , '1/1/1900') as VesselETA, A.BalanceAmount
		, A.CustKey, A.OrderDate, BillOfLading, TerminationDate
	into #InvoiceListData_first
	FROM #Toinvoice A		
		LEFT JOIN InvoiceHeader H  WITH (NOLOCK) on A.InvoiceKey = H.InvoiceKey
		LEFT JOIN #PendingRateConfirm F ON F.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #MultContainer M ON M.InvoiceKey=A.InvoiceKey
		LEFT JOIN [User] U1 WITH (NOLOCK)  ON H.InvoiceApprovedUserKey = U1.UserKey
		LEFT JOIN [User] U2 WITH (NOLOCK) ON H.PrintedUserKey = U2.UserKey
		LEFT JOIN [User] U3 WITH (NOLOCK) ON H.PaymentRecdUserKey = U3.UserKey
		LEFT JOIN [User] U4 WITH (NOLOCK) ON H.RevisionUserKey = U4.UserKey
	GROUP BY A.OrderKey,OrderNo,CustID,CustName,A.City,A.IsInvoiceApproved,A.StatusKey,A.OrderDetailKey,
		[Status],A.InvoiceAmount,A.DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,H.CustomerNote,H.InternalNote,
		F.OrderDetailKey,M.ContCount
		,h.IsPrinted, h.PrintedUserKey, H.PaymentRecdUserKey, H.PaymentRecdDate, H.PrintedDate,H.IsRevised, H.RevisionDate,
		H.RevisionUserKey, U1.UserName, U2.UserName, U3.UserName, u4.UserName, H.IsPaymentReceived
		, A.BrokerRefNo, IsFactored, isnull(A.VesselETA , '1/1/1900'), A.BalanceAmount
		, A.CustKey, A.OrderDate,  BillOfLading, TerminationDate
	ORDER BY (case when @StatusKey = 9 then OrderNo else A.InvoiceNo end) desc
	
	select *
	from #InvoiceListData_first
	where 1 = 1 
		AND (  @OrderKey =0 OR @OrderKey IS NULL OR OrderKey=@OrderKey )	
		AND (  @CustomerKey =0 OR @CustomerKey IS NULL OR CustKey IS NULL OR CustKey=@CustomerKey )	
		AND	(  @OrderDateFrom	IS NULL OR OrderDate		IS NULL OR OrderDate>=@OrderDateFrom )
		AND (  @OrderDateTo		IS NULL OR OrderDate		IS NULL OR OrderDate<=@OrderDateTo )
		AND (  @OrderNo			= '' OR OrderNo		IS NULL OR OrderNo like '%' + @OrderNo + '%' )	
		AND (  @containerNo		= '' OR ContainerNo	IS NULL OR ContainerNo like '%' +  @containerNo + '%' )		
		AND (  @InvoiceNo		= '' OR InvoiceNo IS NULL OR ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
		AND (  ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
		AND (  @InvoiceKey		= 0 OR @InvoiceKey IS null OR InvoiceKey IS NULL OR InvoiceKey=@InvoiceKey )
		AND (  @BOLNo			= '' OR @BOLNo IS NULL OR BillOfLading like '%' +@BOLNo+ '%' )
		AND	(  @TermDateFrom	IS NULL OR TerminationDate	IS NULL OR TerminationDate>=@TermDateFrom )
		AND (  @TermDateTO		IS NULL OR TerminationDate	IS NULL OR TerminationDate<=@TermDateTO )
		AND	(isnull(@SearchText,'') =  '' OR (OrderNo like '%' + @SearchText + '%' OR ContainerNo  like '%' + @SearchText + '%'  OR 
						BrokerRefNo like '%' + @SearchText + '%' OR BillOfLading  like '%' + @SearchText + '%'  OR DestinationCity  like '%' + @SearchText + '%' 
						OR CustID  like '%' + @SearchText + '%'  OR CustName  like '%' + @SearchText + '%' OR InvoiceNo  like '%' + @SearchText + '%' ))

END
