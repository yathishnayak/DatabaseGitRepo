


CREATE Procedure [dbo].[Get_InvoiceList_JSON_Temp20230222] -- Get_InvoiceList_JSON @StatusKey=0, @PageNo = 1
(
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
	@BOLNo			VARCHAR(30)='',
	@PageNo				INT = 1,
	@PageSize			INT	= 10,
	@SorField			varchar(50) = 'OrderNo',
	@IsAscending		bit = 1,
	@SearchText			varchar(50) ='',
	@marketLocationKey		INT = 0
)
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3= Payment Received, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	if  Left(@InvoiceNo, 1) = '0'   set @InvoiceNo=  right(@InvoiceNo, Len(@InvoiceNo)-1)

	SELECT StatusKey, [Description] AS StatusName INTO #InvStatus
	FROM dbo.InvoiceStatus 
	UNION ALL 
	SELECT 9,'Pending to Invoice'

	CREATE TABLE #ToInvoice
	(
		OrderKey				int,
		OrderNo					varchar(50),
		ContainerNo				varchar(500),
		ActualArrival			datetime,
		CustId					varchar(100),
		CustName				varchar(200),
		IsInvoiceApproved		bit,
		StatusKey				smallint,
		InvoiceAmount			numeric(18,2),
		City					varchar(50),
		[Status]				varchar(50),
		DestinationAddrKey		int,
		InvoiceKey				int,
		InvoiceNo				varchar(50),
		InvoiceDate				DateTime,
		DocumentCount			int,
		IsPrinted				bit, 
		PrintedUserKey			int, 
		PaymentRecdUserKey		int, 
		PaymentRecdDate			Datetime, 
		PrintedDate				DateTime, 
		IsRevised				Bit, 
		RevisionDate			Datetime,  
		BrokerRefNo				varchar(50), 
		IsFactored				Bit, 
		VesselETA				varchar(50), 
		BalanceAmount			numeric(18,2),
		CustKey					int, 
		OrderDate				DateTime, 
		BillOfLading			varchar(50), 
		OrderType				varchar(50),
		BookingNo				varchar(50), 
		TerminationDate			DateTime, 
		ContainerList			varchar(500), 
		AddrName				varchar(100),
		MarketLocationKey		int,
		MarketLocation			varchar(100),
		OrderDetailKey			int,
		IsPaymentReceived		Bit,
		RevisionUserKey			int,
		InvoiceApprovedUserKey	int,
		CustomerNote			varchar(max), 
		InternalNote			varchar(max)
	)

	--If(@StatusKey in (0,9))
	--Begin
		insert into #ToInvoice (OrderKey, OrderNo, ContainerNo, ActualArrival, CustId, CustName, OD.OrderDetailKey,
			IsInvoiceApproved, StatusKey, InvoiceAmount, City, [Status], DestinationAddrKey, InvoiceKey, InvoiceNo, InvoiceDate,
			DocumentCount, IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised,
			RevisionDate, BrokerRefNo, IsFactored, VesselETA, BalanceAmount, CustKey, OrderDate, BillOfLading, OrderType,
			BookingNo, TerminationDate,  AddrName, MarketLocationKey, MarketLocation)
		select OH.OrderKey,  OH.OrderNo, OD.ContainerNo as ContainerNo, MAX(RT.ActualArrival) AS ActualArrival, CU.CustId, CU.CustName,OD.OrderDetailKey,
			0 as IsInvoiceApproved, 9 AS StatusKey, 0 as  InvoiceAmount, 
			AD.City, 'Pending to Invoice' AS [Status],
			OH.DestinationAddrKey, 0 as InvoiceKey, '' as  InvoiceNo, '1/1/1900' as InvoiceDate,
			0 AS DocumentCount, 
			0 as IsPrinted, 
			0 as PrintedUserKey, 0 as PaymentRecdUserKey, '1/1/1900' as PaymentRecdDate, '1/1/1900' PrintedDate, 0 as IsRevised, 
			'1/1/1900' as RevisionDate,  OH.BrokerRefNo as BrokerRefNo, 
			CU.IsFactored, '' as VesselETA, 0  as BalanceAmount
			, OH.CustKey , OH.OrderDate, OH.BillOfLading, OT.OrderType,
			OH.BookingNo, '' as TerminationDate, 
			ad.AddrName, ML.MarketLocationKey,ML.MarketLocation
		from Routes   RT  (nolock) 
		inner  join OrderDetail  OD on (RT.OrderDetailKey = OD.OrderDetailKey)
		inner  join OrderHeader  OH on (OD.OrderKey = OH.OrderKey)
		inner join Customer  CU (nolock)on (OH.CustKey = CU.CustKey)
		left  join [RouteInvoice]  RI  (nolock) on (RT.OrderDetailKey = RI.OrderDetailKey)
		LEFT JOIN dbo.[Address] AD			WITH (NOLOCK) ON AD.AddrKey=OH.DestinationAddrKey
		LEFT JOIN DBO.ORDERTYPE		OT		WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
		where RT.[Status] =5 and RI.InvoiceKey is null
		GROUP BY OH.OrderKey,oh.OrderNo,od.ContainerNo,CU.CustName, AD.City,OH.DestinationAddrKey, OD.OrderDetailKey,
		CU.CustID,OH.BrokerRefNo, CU.IsFactored, OD.VesselETA, 
		OH.CustKey, OH.OrderDate, OH.BillOfLading, OrderType, BookingNo, OD.CompleteDate, ad.AddrName,ML.MarketLocationKey,ML.MarketLocation
	--End

	--if(@StatusKey in (1,2,3,0))
	--Begin
		insert into #ToInvoice (OrderKey, OrderNo, ContainerNo, ActualArrival, CustId, CustName, OrderDetailKey,
			IsInvoiceApproved, StatusKey, InvoiceAmount, City, [Status], DestinationAddrKey, InvoiceKey, InvoiceNo, InvoiceDate,
			DocumentCount, IsPrinted, PrintedUserKey,PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised,
			RevisionDate, BrokerRefNo, IsFactored, VesselETA, BalanceAmount, CustKey, OrderDate, BillOfLading, OrderType,
			BookingNo, TerminationDate,  AddrName, MarketLocationKey, MarketLocation,
			IsPaymentReceived, RevisionUserKey, InvoiceApprovedUserKey, CustomerNote, InternalNote)
		select  
			OH.OrderKey,  OH.OrderNo, '' as ContainerNo, '' as ActualArrival, CU.CustId, CU.CustName, 0 as OrderDetailsKey,
			isnull(IH.IsInvoiceApproved,0) as IsInvoiceApproved, ISNULL(IH.[StatusKey],9)  AS StatusKey, IH.InvoiceAmount,
			AD.City, INS.[Description]  AS [Status],
			OH.DestinationAddrKey,IH.InvoiceKey, IH.InvoiceNo,IH.InvoiceDate,
			0 AS DocumentCount , IH.IsPrinted, 
			IH.PrintedUserKey, IH.PaymentRecdUserKey, IH.PaymentRecdDate, IH.PrintedDate, IH.IsRevised, 
			IH.RevisionDate, isnull(IH.BrokerRefNo, OH.BrokerRefNo) as BrokerRefNo, 
			CU.IsFactored, '' as VesselETA, isnull(VIB.BalanceAmount,IH.InvoiceAmount) as BalanceAmount
			, OH.CustKey , OH.OrderDate, OH.BillOfLading, OT.OrderType,
			OH.BookingNo, '' as TerminationDate, 
			ad.AddrName,ML.MarketLocationKey,ML.MarketLocation	, IH.IsPaymentReceived, IH.RevisionUserKey, 
			IH.InvoiceApprovedUserKey, IH.CustomerNote, IH.InternalNote
		from InvoiceHeader  IH (nolock)
		inner join OrderHeader  OH (nolock) on (IH.OrderKey = OH.OrderKey)
		inner join Customer  CU (nolock)on (IH.CustKey = CU.CustKey)
		--inner join InvoiceContainers ID (nolock)on (IH.InvoiceKey = ID.InvoiceKey)
		LEFT JOIN dbo.[Address] AD			WITH (NOLOCK) ON AD.AddrKey=OH.DestinationAddrKey
		LEFT JOIN dbo.InvoiceStatus INS		WITH (NOLOCK) ON INS.[StatusKey]=IH.[StatusKey]
		Left JOIN vInvoiceBalanceAmount VIB  WITH (NOLOCK) on IH.InvoiceKey = VIB.InvoiceKey
		LEFT JOIN DBO.ORDERTYPE		OT		WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
	--End

	--update A set ContainerList = B.ContainerList 
	--from #Toinvoice  A
	--inner join 
	--(
	--	select distinct InvoiceKey, stuff((Select ',' + ContainerNo 
	--		from InvoiceContainers A WITH (NOLOCK) 
	--		where A.InvoiceKey = I.InvoiceKey
	--		FOR XML PATH ('')),1,1,'') as ContainerList
	--	from  InvoiceContainers I
	--) B  on (A.InvoiceKey = B.InvoiceKey)

	update A set ContainerList = B.ContainerList 
	from #Toinvoice  A
	inner join 
	(
	 SELECT DISTINCT ST2.InvoiceKey, 
            (
                SELECT ST1.ContainerNo + ',' AS [text()]
                FROM InvoiceContainers ST1
                WHERE ST1.InvoiceKey = ST2.InvoiceKey
                ORDER BY ST1.InvoiceKey
                FOR XML PATH (''), TYPE
            ).value('text()[1]','nvarchar(max)') ContainerList
        FROM InvoiceHeader ST2
	) B on a.InvoiceKey = b.InvoiceKey


	SELECT DISTINCT RT.OrderDetailKey INTO #PendingLegContainers
	FROM dbo.[Routes] RT WITH (NOLOCK)
		INNER JOIN dbo.RouteStatus RTS		WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
		INNER JOIN #Toinvoice G				WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE RTS.[Description] <>'Leg Completed' and G.Statuskey = 9

	SELECT DISTINCT RT.OrderDetailKey INTO #PendingRateConfirm
	FROM dbo.[Routes] RT  WITH (NOLOCK)
		INNER JOIN dbo.RouteStatus RTS		 WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
		INNER JOIN #Toinvoice G				 WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE RTS.[Description] ='Leg Completed' AND RT.IsRateVerified=0 and G.statuskey = 9

	DELETE 
	FROM #Toinvoice 
	WHERE OrderDetailKey IN ( SELECT OrderDetailKey FROM #PendingLegContainers )

	SELECT ContCount,InvoiceKey INTO #MultContainer 
	FROM		
	(
		SELECT COUNT(1) AS ContCount,T.InvoiceKey 
		FROM dbo.InvoiceContainers S  WITH (NOLOCK)
		INNER JOIN ( SELECT DISTINCT InvoiceKey FROM #Toinvoice ) T  ON T.InvoiceKey=S.InvoiceKey			
		GROUP BY T.InvoiceKey 
	) D

	SELECT  A.OrderKey,
	case when A.InvoiceKey is null then  A.OrderDetailKey else 0 end as OrderDetailKey ,
	OrderNo,	
		CASE WHEN isnull(M.ContCount,1)=1 THEN isnull(A.ContainerList, A.ContainerNo) ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo,
		A.ActualArrival,CustID,CustName,A.City as DestinationCity,A.IsInvoiceApproved,
		A.StatusKey,[Status],A.InvoiceAmount,A.DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,
		A.DocumentCount as DocumentCount,
		A.CustomerNote, A.InternalNote , 
		CASE WHEN F.OrderDetailKey IS NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsRateVerified,M.ContCount
		,A.IsPrinted, A.PrintedUserKey, A.PaymentRecdUserKey, A.PaymentRecdDate, A.PrintedDate,A.IsRevised, 
		A.RevisionDate, 
		A.RevisionUserKey, U1.UserName AS ApprovedUserName, U2.UserName as PrintedUserName, 
		U3.UserName as PaymentRecdUserName, 
		U4.UserName as RevisedUserName, A.IsPaymentReceived,
		A.BrokerRefNo, IsFactored, isnull(A.VesselETA , '1/1/1900') as VesselETA, A.BalanceAmount
		, A.CustKey, A.OrderDate, BillOfLading, OrderType, BookingNo, TerminationDate,
		--CASE WHEN isnull(M.ContCount,1)=1 THEN TerminationDate else null end as TerminationDate,
		isnull(ContainerList,A.ContainerNo) as ContainerList , AddrName,
		A.MarketLocationKey,A.MarketLocation
	into #InvoiceListData
	FROM #Toinvoice A		
		--LEFT JOIN InvoiceHeader H  WITH (NOLOCK) on A.InvoiceKey = H.InvoiceKey
		LEFT JOIN #PendingRateConfirm F ON F.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #MultContainer M ON M.InvoiceKey=A.InvoiceKey
		LEFT JOIN [User] U1 WITH (NOLOCK)  ON A.InvoiceApprovedUserKey = U1.UserKey
		LEFT JOIN [User] U2 WITH (NOLOCK) ON A.PrintedUserKey = U2.UserKey
		LEFT JOIN [User] U3 WITH (NOLOCK) ON A.PaymentRecdUserKey = U3.UserKey
		LEFT JOIN [User] U4 WITH (NOLOCK) ON A.RevisionUserKey = U4.UserKey
	where 1 = 1 
		AND (  @OrderKey =0 OR @OrderKey IS NULL OR OrderKey=@OrderKey )	
		AND (  @CustomerKey =0 OR @CustomerKey IS NULL OR CustKey IS NULL OR CustKey=@CustomerKey )	
		AND	(  @OrderDateFrom	IS NULL OR OrderDate		IS NULL OR OrderDate>=@OrderDateFrom )
		AND (  @OrderDateTo		IS NULL OR OrderDate		IS NULL OR OrderDate<=@OrderDateTo )
		AND (  @OrderNo			= '' OR OrderNo		IS NULL OR OrderNo like '%' + @OrderNo + '%' )	
		AND (  @containerNo		= '' OR ContainerNo	IS NULL OR Containerlist like '%' +  @containerNo + '%' )		
		AND (  @InvoiceNo		= '' OR InvoiceNo IS NULL OR ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
		AND (  ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
		AND (  @InvoiceKey		= 0 OR @InvoiceKey IS null OR A.InvoiceKey IS NULL OR A.InvoiceKey=@InvoiceKey )
		AND (  @BOLNo			= '' OR @BOLNo IS NULL OR BillOfLading like '%' +@BOLNo+ '%' )
		AND	(isnull(@SearchText,'') =  '' OR (OrderNo like '%' + @SearchText + '%' OR ContainerNo  like '%' + @SearchText + '%'  OR 
						BrokerRefNo like '%' + @SearchText + '%' OR BillOfLading  like '%' + @SearchText + '%'  OR A.City  like '%' + @SearchText + '%' 
						OR CustID  like '%' + @SearchText + '%'  OR CustName  like '%' + @SearchText + '%' OR InvoiceNo  like '%' + @SearchText + '%' ))
	--GROUP BY A.OrderKey,OrderNo,CustID,CustName,A.City,A.IsInvoiceApproved,A.StatusKey,A.OrderDetailKey,
	--	[Status],A.InvoiceAmount,A.DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,A.CustomerNote,A.InternalNote,
	--	F.OrderDetailKey,M.ContCount
	--	,A.IsPrinted, A.PrintedUserKey, A.PaymentRecdUserKey, A.PaymentRecdDate, A.PrintedDate,A.IsRevised, A.RevisionDate,
	--	A.RevisionUserKey, U1.UserName, U2.UserName, U3.UserName, u4.UserName, A.IsPaymentReceived
	--	, A.BrokerRefNo, IsFactored, isnull(A.VesselETA , '1/1/1900'), A.BalanceAmount
	--	, A.CustKey, A.OrderDate,  BillOfLading, OrderType, BookingNo, isnull(ContainerList,A.ContainerNo),AddrName,A.MarketLocationKey,A.MarketLocation,
	--	CASE WHEN isnull(M.ContCount,1)=1 THEN TerminationDate else null end, TerminationDate
	
	SELECT S.StatusKey, StatusName as Description , ISNULL(A.cnt,0) AS InvoiceCount
	INTO #Temp
	FROM #InvStatus S
	LEFT JOIN (
			SELECT Z.StatusKey, COUNT(1) cnt 
			FROM (
					SELECT  OrderKey,OrderDetailKey,OrderNo,ContainerNo,ActualArrival,CustID,CustName,DestinationCity ,IsInvoiceApproved,
						StatusKey,InvoiceAmount,DestinationAddrKey,InvoiceKey,InvoiceNo,InvoiceDate
					FROM #InvoiceListData			
					
				) Z
			GROUP BY StatusKey
			) A ON S.StatusKey = A.StatusKey

	--select *
	--into #InvoiceListData
	--from #InvoiceListData_first
	--where 1 = 1 
	--	AND (  @OrderKey =0 OR @OrderKey IS NULL OR OrderKey=@OrderKey )	
	--	AND (  @CustomerKey =0 OR @CustomerKey IS NULL OR CustKey IS NULL OR CustKey=@CustomerKey )	
	--	AND	(  @OrderDateFrom	IS NULL OR OrderDate		IS NULL OR OrderDate>=@OrderDateFrom )
	--	AND (  @OrderDateTo		IS NULL OR OrderDate		IS NULL OR OrderDate<=@OrderDateTo )
	--	AND (  @OrderNo			= '' OR OrderNo		IS NULL OR OrderNo like '%' + @OrderNo + '%' )	
	--	AND (  @containerNo		= '' OR ContainerNo	IS NULL OR Containerlist like '%' +  @containerNo + '%' )		
	--	AND (  @InvoiceNo		= '' OR InvoiceNo IS NULL OR ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
	--	AND (  ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
	--	AND (  @InvoiceKey		= 0 OR @InvoiceKey IS null OR InvoiceKey IS NULL OR InvoiceKey=@InvoiceKey )
	--	AND (  @BOLNo			= '' OR @BOLNo IS NULL OR BillOfLading like '%' +@BOLNo+ '%' )
	--	AND	(isnull(@SearchText,'') =  '' OR (OrderNo like '%' + @SearchText + '%' OR ContainerNo  like '%' + @SearchText + '%'  OR 
	--					BrokerRefNo like '%' + @SearchText + '%' OR BillOfLading  like '%' + @SearchText + '%'  OR DestinationCity  like '%' + @SearchText + '%' 
	--					OR CustID  like '%' + @SearchText + '%'  OR CustName  like '%' + @SearchText + '%' OR InvoiceNo  like '%' + @SearchText + '%' ))

	SELECT statusKey, Description, InvoiceCount, 'I' AS Level 
	into #StatusData
	FROM #temp
	UNION ALL
	SELECT 0, 'All', SUM(InvoiceCount) AS StatusCount, 'S' AS Level FROM #temp 


	--select * from #StatusData

	declare @cnt int
	select @cnt = count(1) from #InvoiceListData where (@StatusKey = 0 OR StatusKey = @StatusKey)
	--select * from #TempOutput
	DECLARE @STRSQL VARCHAR(MAX)
	--select *, 1 as RecCount  from #TempOutput

	
	--select * from InvoiceListData

	select *,0 as RowNum, 0 as RecCount into  #InvoiceListData_temp from #InvoiceListData WHERE 1 <> 1 

	SET @STRSQL = '
	SELECT *, ' + convert(Varchar,@cnt) + ' as RecCount  FROM (
		select top 1000000 *, ROW_NUMBER() Over(Order by ' + @SorField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ') RowNum
		from #InvoiceListData
		where (' + convert(varchar, isnull(@StatusKey,0)) + ' = 0 OR StatusKey = ' +  convert(varchar, isnull(@StatusKey,0)) + ')'+
		--ORDER BY ' + @SorField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' 
	+') a
	where ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
	+'Order BY ROWNUM'

	PRINT (@STRSQL)
	insert into #InvoiceListData_temp
	EXEC (@STRSQL)

	--SELECT * FROM #InvoiceListData_temp --where (@StatusKey = 0 OR StatusKey = @StatusKey)

	select 
	DashboardData = (
		select * from #StatusData
		FOR JSON PATH
	),
	InvoiceList = (
		select * from #InvoiceListData_temp A where (@StatusKey = 0 OR StatusKey = @StatusKey) 
		--ORDER BY TerminationDate ASC
		FOR JSON PATH
	)  FOR JSON PATH
	
END
