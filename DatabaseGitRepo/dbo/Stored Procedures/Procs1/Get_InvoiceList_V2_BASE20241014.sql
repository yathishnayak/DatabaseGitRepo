

/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"Factored":2,"CustApproved":2,"PageNo":1,"PageSize":50,"Ascending":true,"IsAscending":true,"SearchText":"","CustomerKey":"","MarketLocationKey":"","InvoicerKey":"","CustCompanyKey":"","SortField":"TerminationDate","StatusKey":3}',
	@Status BIT=0,@IsDebug		BIT = 1,
	@Reason VARCHAR(100)=''
EXec Get_InvoiceList_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
**/


CREATE Procedure [dbo].[Get_InvoiceList_V2_BASE20241014] -- Get_InvoiceList_V2 @StatusKey=2, @PageNo = 1,@SearchText='WHSU5296890'
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3= Payment Received, 9 = PENDING TO CREATE VOUCHER
	INSERT INTO SqlExecutionTimeLog
	(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	VALUes (@UserKey,'Get_InvoiceList_V2','Procedure Entered','',GETDATE())
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @IsFactored		BIT 
	DECLARE @IsCustApproved BIT


	DECLARE 
	@StatusKey			INT= 0,
	@CustomerKey		VARCHAR(MAX),
	@OrderKey			INT= 0,
	@OrderDateFrom		DATE='01/01/2020',
	@OrderDateTO		DATE='12/31/2099',
	@DeliveryDateFrom	DATE='01/01/2020',
	@DeliveryDateTo		DATE='12/31/2099',
	@OrderNo			VARCHAR(50)='',
	@containerNo		VARCHAR(50)='',
	@InvoiceNo			VARCHAR(50)='',
	@InvoiceKey			INT=0,
	@BOL				VARCHAR(30)='',
	@PageNo				INT = 1,
	@PageSize			INT	= 10,
	@SortField			VARCHAR(50) = 'ORDERNO',
	@IsAscending		BIT = 1,
	@SearchText			VARCHAR(50) ='',
	@marketLocationKey	VARCHAR(MAX),
	@Factored           INT ,
	@CustApproved       INT ,
	@InvoicerKey        VARCHAR(MAX),
	@CustCompanyKey     VARCHAR(MAX),
	@outputType			VARCHAR(20),
	@ChargeConfirmed	int = 2


	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
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

	SELECT			@StatusKey			= StatusKey,			@CustomerKey		= CustomerKey,		@OrderKey			= OrderKey,			
					@OrderDateFrom		= OrderDateFrom	,		@OrderDateTO		= OrderDateTO,		@DeliveryDateFrom	= @DeliveryDateFrom,	
					@DeliveryDateTo		= DeliveryDateTo,		@OrderNo			= OrderNo,			
					@containerNo		= containerNo,			@InvoiceNo			= InvoiceNo,		@InvoiceKey			= InvoiceKey,			
					@BOL				= BOL	,				@PageNo				= PageNo,			
					@PageSize			= PageSize	,			@SortField			= SorField,			@IsAscending		= IsAscending,		
					@SearchText			= SearchText,			@marketLocationKey	= marketLocationKey,@Factored         	= Factored,          
					@CustApproved		= CustApproved  ,		@InvoicerKey		= InvoicerKey,       
					@CustCompanyKey		= CustCompanyKey,		@outputType			= outputType,		@ChargeConfirmed	= ChargeConfirmed
	FROM	OPENJSON(@JsonString, '$')
			WITH (
					StatusKey			INT				'$.StatusKey',
					CustomerKey			VARCHAR(MAX)	'$.CustomerKey',
					OrderKey			INT				'$.OrderKey',
					OrderDateFrom		DATE			'$.OrderDateFrom',
					OrderDateTO			DATE			'$.OrderDateTO',
					DeliVeryDateFrom	DATE			'$.DeliVeryDateFrom',
					DeliveryDateTo		DATE			'$.DeliveryDateTo',
					OrderNo				VARCHAR(50)		'$.OrderNo',
					containerNo			VARCHAR(50)		'$.containerNo',
					InvoiceNo			VARCHAR(50)		'$.InvoiceNo',
					InvoiceKey			INT				'$.InvoiceKey',
					BOL					VARCHAR(30)		'$.BOL',
					PageNo				INT				'$.PageNo',
					PageSize			INT				'$.PageSize',
					SorField			VARCHAR(50)		'$.SortField',
					IsAscending			BIT				'$.IsAscending',
					SearchText			VARCHAR(50)		'$.SearchText',
					MarketLocationKey	VARCHAR(MAX)	'$.MarketLocationKey',
					Factored			INT				'$.Factored',
					CustApproved		INT				'$.CustApproved',
					InvoicerKey			VARCHAR(MAX)	'$.InvoicerKey',
					CustCompanyKey		VARCHAR(MAX)	'$.CustCompanyKey' ,
					outputType			VARCHAR(20)		'$.outputType'	,
					ChargeConfirmed		INT				'$.ChargeConfirmed'
			)

	IF(@OrderDateFrom IS NULL)
		BEGIN
			SET @OrderDateFrom = '2020-01-01' -- Getdate() - 90
		END

	IF(@OrderDateTo IS NULL)
		BEGIN
			SET @OrderDateTo = Getdate()  + 30
		END

	IF(@DeliveryDateFrom IS NULL)
		BEGIN
			set @DeliveryDateFrom = '2020-01-01' -- Getdate() - 90
		END

	IF(@DeliveryDateTo IS NULL)
		BEGIN
			Set @DeliveryDateTo = Getdate() + 30
		END
	   	
	IF(@IsDebug = 1)
		BEGIN
			SELECT @StatusKey			AS  StatusKey,			@CustomerKey		AS  CustomerKey,	@OrderKey			AS  OrderKey,			
					@OrderDateFrom		AS  OrderDateFrom	,	@OrderDateTO		AS  OrderDateTO,	@DeliveryDateFrom	AS  DeliVeryDateFrom,	
					@DeliveryDateTo		AS  DeliveryDateTo,		@OrderNo			AS  OrderNo,			
					@containerNo		AS  containerNo,		@InvoiceNo			AS  InvoiceNo,		@InvoiceKey			AS  InvoiceKey,			
					@BOL				AS  BOL	,				@PageNo				AS  PageNo,			
					@PageSize			AS  PageSize	,		@SortField			AS  SorField,		@IsAscending		AS  IsAscending,		
					@SearchText			AS  SearchText,			@marketLocationKey	AS  marketLocationKey,@Factored         AS  Factored,          
					@CustApproved		AS  CustApproved  ,		@InvoicerKey		AS  InvoicerKey,       
					@CustCompanyKey		AS  CustCompanyKey,		@ChargeConfirmed    AS  ChargeConfirmed
		END

	IF (@Factored = 0)
		BEGIN
		   SET @IsFactored = 0
		END

	IF (@Factored = 1)
		BEGIN
			SET @IsFactored = 1
		END

	IF (@CustApproved = 0)
		BEGIN
			SET @IsCustApproved = 0
		END

	IF (@CustApproved = 1)
		BEGIN 
			SET @IsCustApproved = 1
		END

	IF  LEFT(@InvoiceNo, 1) = '0'   
		BEGIN
			SET @InvoiceNo=  right(@InvoiceNo, Len(@InvoiceNo)-1)
		END


	CREATE TABLE #CustomerKeys
	(
		CustomerKey	INT
	)

	CREATE TABLE #CustCompanyKeys
	(
		CustCompanyKey	INT
	)

	CREATE TABLE #MarketLocationKeys
	(
		MarketLocationKey	INT
	)

	CREATE TABLE #InvoicerKeys
	(
		InvoicerKey	INT
	)


	IF(ISNULL(@CustomerKey,'') <> '')
		BEGIN
			INSERT INTO	#CustomerKeys(CustomerKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@CustomerKey)
		END		
		
	IF(ISNULL(@CustCompanyKey,'') <> '')
		BEGIN
			INSERT INTO	#CustCompanyKeys(CustCompanyKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@CustCompanyKey)
		END	

	IF(ISNULL(@MarketLocationKey,'') <> '')
		BEGIN
			INSERT INTO	#MarketLocationKeys(MarketLocationKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@MarketLocationKey)
		END	

	IF(ISNULL(@InvoicerKey,'') <> '')
		BEGIN
			INSERT INTO	#InvoicerKeys(InvoicerKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@InvoicerKey)
		END	
	
	IF(@IsDebug = 1)
		BEGIN
			SELECT '#CustCompanyKeys', * FROM #CustCompanyKeys
			SELECT '#CustomerKeys',* FROM #CustomerKeys
			SELECT '#MarketLocationKeys',* FROM #MarketLocationKeys
		END

	SELECT		StatusKey, [Description] AS StatusName 
	INTO		#InvStatus
	FROM		dbo.InvoiceStatus WITH (NOLOCK)
	UNION ALL 
	SELECT		9,'Pending to Invoice'

	CREATE TABLE #ToInvoice
	(
		OrderKey				INT,
		OrderNo					VARCHAR(50),
		ContainerNo				VARCHAR(500),
		ActualArrival			DATETIME,
		CustId					VARCHAR(100),
		CustName				VARCHAR(200),
		IsInvoiceApproved		BIT,
		StatusKey				SMALLINT,
		InvoiceAmount			NUMERIC(18,2),
		City					VARCHAR(50),
		[Status]				VARCHAR(50),
		DestinationAddrKey		INT,
		InvoiceKey				INT,
		InvoiceNo				VARCHAR(50),
		InvoiceDate				DATETIME,
		DocumentCount			INT,
		IsPrinted				BIT, 
		PrintedUserKey			INT, 
		PaymentRecdUserKey		INT, 
		PaymentRecdDate			DATETIME, 
		PrintedDate				DATETIME, 
		IsRevised				BIT, 
		RevisionDate			DATETIME,  
		BrokerRefNo				VARCHAR(50), 
		IsFactored				BIT, 
		VesselETA				VARCHAR(50), 
		BalanceAmount			NUMERIC(18,2),
		CustKey					INT, 
		OrderDate				DATETIME, 
		BillOfLading			VARCHAR(50), 
		OrderType				VARCHAR(50),
		BookingNo				VARCHAR(50), 
		TerminationDate			DATETIME, 
		ContainerList			VARCHAR(MAX), 
		AddrName				VARCHAR(100),
		MarketLocationKey		INT,
		MarketLocation			VARCHAR(100),
		OrderDetailKey			INT,
		IsPaymentReceived		BIT,
		RevisionUserKey			INT,
		InvoiceApprovedUserKey	INT,
		CustomerNote			VARCHAR(MAX), 
		InternalNote			VARCHAR(MAX),
		CustApproved            BIT,
		InvoicerKey            VARCHAR(MAX),
		InvoicerName            VARCHAR(100),
		ReasonCodeKey           INT,
	    ReasonCodeName          VARCHAR(100),
		CustCompanyKey			INT ,
		AgingDays				INT,
		AprovedReasonCodeKey	INT,
		ApprovedReasonCode		VARCHAR(100),
		CustCompanyName			VARCHAR(500),
		RouteKey				INT,
		LegID					VARCHAR(100),
		IsDataSelected			BIT,
		IsSelectedStatusKey		BIT,
		CSR						VARCHAR(100),
		WarehouseStatus			VARCHAR(100),
		AllowInvoicing			BIT,
		IsCSChargesApproved		BIT,
		CSChargesApproveDate	Datetime,
		ExpCount				INT DEFAULT 0
	)

	select OrderDetailKey into #ContainersNotInvoiced 
	from orderdetail OD WITH (NOLOCK)
	where OD.status in (6,10,12,13,14) and OrderDetailKey not in 
		(select OrderDetailsKey from InvoiceContainers WITH (NOLOCK) where OrderDetailsKey is not null)

	--select * from #ContainersNotInvoiced

	--If(@StatusKey in (0,9))
		BEGIN
			INSERT INTO		#ToInvoice (OrderKey, OrderNo, ContainerNo, ActualArrival, CustId, CustName, OD.OrderDetailKey,
							IsInvoiceApproved, StatusKey, InvoiceAmount, City, [Status], DestinationAddrKey, InvoiceKey, InvoiceNo, InvoiceDate,
							DocumentCount, IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised,
							RevisionDate, BrokerRefNo, IsFactored, VesselETA, BalanceAmount, CustKey, OrderDate, BillOfLading, OrderType,
							BookingNo, TerminationDate,  AddrName, MarketLocationKey, MarketLocation,CustApproved ,ReasonCodeKey,ReasonCodeName,CustCompanyKey,
							AgingDays,InvoicerKey,AprovedReasonCodeKey,ApprovedReasonCode,CustCompanyName,RouteKey,
							LegID,IsDataSelected,IsSelectedStatusKey,CSR,WarehouseStatus, 
							AllowInvoicing, IsCSChargesApproved, CSChargesApproveDate, ExpCount)
			SELECT			OH.OrderKey,  OH.OrderNo, OD.ContainerNo AS ContainerNo, 
							''  AS ActualArrival, --MAX(RT.ActualArrival) AS ActualArrival, 
							CU.CustId, CU.CustName,OD.OrderDetailKey,
							0 AS IsInvoiceApproved, 9 AS StatusKey, 0 AS  InvoiceAmount, 
							AD.City, 'Pending to Invoice' AS [Status],
							OH.DestinationAddrKey, 0 AS InvoiceKey, '' AS  InvoiceNo, '1/1/1900' AS InvoiceDate,
							0 AS DocumentCount, 
							0 AS IsPrinted, 
							0 AS PrintedUserKey, 0 AS PaymentRecdUserKey, '1/1/1900' AS PaymentRecdDate,
							'1/1/1900' PrintedDate, 0 AS IsRevised, 
							'1/1/1900' AS RevisionDate,  OH.BrokerRefNo AS BrokerRefNo, 
							CU.IsFactored, '' AS VesselETA, 0  AS BalanceAmount
							, OH.CustKey , OH.OrderDate, OH.BillOfLading, OT.OrderType,
							OH.BookingNo, ISNULL(OD.CompleteDate,'') AS TerminationDate, 
							ad.AddrName, ML.MarketLocationKey,ML.MarketLocation, 0 AS CustApproved,0 AS ReasonCodeKey,
							'' AS ReasonCodeName,CU.CustomerCompanyKey AS CustCompanyKey,
							DATEDIFF(DAY,ISNULL(OD.CompleteDate,''),GETDATE()) AgingDays,
							0,0,'' ,CC.CompanyName AS CustCompanyName, OD.CurrentRouteKey as RouteKey, 
							'' LegID,0,0,CSR.CsrName,
							case when isnull(CT.OrderDetailKey ,0) = 0 then 'N/A' else isnull(WS.Description,'Open') end as WarehouseStatus,
							case when ISNULL(OD.CompleteDate,'') < Getdate() -1 then 1 else 0 end,
							OD.isChargesSharedWithCust, ChargeSharedWithCustDate, OE.ExpCount
			FROM			#ContainersNotInvoiced CNI
			inner join		OrderDetail  OD WITH (NOLOCK) on CNI.OrderDetailKey = OD.OrderDetailKey
			--INNER JOIN		Routes   RT   WITH (NOLOCK) ON (RT.OrderDetailKey = OD.OrderDetailKey)
			INNER JOIN		OrderHeader  OH WITH (NOLOCK) ON (OD.OrderKey = OH.OrderKey)
			INNER JOIN		Customer  CU WITH (NOLOCK)ON (OH.CustKey = CU.CustKey)
			--LEFT JOIN		Leg L WITH (NOLOCK) ON RT.LegKey = L.LegKey
			--LEFT JOIN		[RouteInvoice]  RI  WITH (NOLOCK) ON (OD.OrderDetailKey = RI.OrderDetailKey)
			LEFT JOIN		dbo.[Address] AD WITH (NOLOCK) ON AD.AddrKey=OH.DestinationAddrKey
			LEFT JOIN		DBO.ORDERTYPE OT WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
			LEFT JOIN		MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
			LEFT JOIN		CustomerCompany CC WITH (NOLOCK) ON ISNULL(CU.CustomerCompanyKey,0) = ISNULL(CC.CustomerCompanyKey,0)
			LEFT JOIN		CSR CSR WITH (NOLOCK) ON CSR.CsrKey=OH.CsrKey
			LEft join		vContainerType CT WITH (NOLOCK) on CT.OrderDetailKey = OD.OrderDetailKey and Ct.TypeID = 'Transload'
			LEFT join		Warehouse_ContainerDetails WCD WITH (NOLOCK) on Od.OrderDetailKey = WCD.OrderDetailKey
			LEFT join		WarehouseStatus WS WITH (NOLOCK) on WCD.StatusKey = WS.StatusKey
			LEFT JOIN		vorderExpencesCount  OE WITH (NOLOCK) on OE.Orderdetailkey = OD.OrderDetailKey
			WHERE			--RT.[Status] =5 AND 
							OD.status in (6,10,12,13,14) --AND RI.InvoiceKey is null
			GROUP BY		OH.OrderKey,oh.OrderNo,od.ContainerNo,CU.CustName, AD.City,OH.DestinationAddrKey, OD.OrderDetailKey,
							CU.CustID,OH.BrokerRefNo, CU.IsFactored, OD.VesselETA, 
							OH.CustKey, OH.OrderDate, OH.BillOfLading, OrderType, BookingNo, OD.CompleteDate, 
							ad.AddrName,ML.MarketLocationKey,ML.MarketLocation,CU.CustomerCompanyKey,CC.CompanyName,
							OD.CurrentRouteKey,
							--RT.RouteKey, L.LegID,
							CSR.CsrName,WS.Description,CT.OrderDetailKey, OD.isChargesSharedWithCust, ChargeSharedWithCustDate,
							OE.ExpCount
		END
							
	--IF(@StatusKey in (1,2,3,0))
		BEGIN
			INSERT INTO		#ToInvoice (OrderKey, OrderNo, ContainerNo, ActualArrival, CustId, CustName, OrderDetailKey,
							IsInvoiceApproved, StatusKey, InvoiceAmount, City, [Status], DestinationAddrKey, InvoiceKey, InvoiceNo, InvoiceDate,
							DocumentCount, IsPrinted, PrintedUserKey,PaymentRecdUserKey, PaymentRecdDate, PrintedDate, IsRevised,
							RevisionDate, BrokerRefNo, IsFactored, VesselETA, BalanceAmount, CustKey, OrderDate, BillOfLading, OrderType,
							BookingNo, TerminationDate,  AddrName, MarketLocationKey, MarketLocation,
							IsPaymentReceived, RevisionUserKey, InvoiceApprovedUserKey, CustomerNote, InternalNote,CustApproved,ReasoncodeKey,ReasonCodeName,CustCompanyKey,
							AgingDays,InvoicerKey,AprovedReasonCodeKey,ApprovedReasonCode,CustCompanyName,RouteKey,
							LegID,IsDataSelected,IsSelectedStatusKey,CSR,WarehouseStatus, AllowInvoicing,ExpCount)
			SELECT			OH.OrderKey,  OH.OrderNo, '' AS ContainerNo, '' AS ActualArrival, CU.CustId, CU.CustName, 0 OrderDetailsKey,
							ISNULL(IH.IsInvoiceApproved,0) AS IsInvoiceApproved, ISNULL(IH.[StatusKey],9)  AS StatusKey, IH.InvoiceAmount,
							AD.City, INS.[Description]  AS [Status],
							OH.DestinationAddrKey,IH.InvoiceKey, IH.InvoiceNo,IH.InvoiceDate,
							0 AS DocumentCount , IH.IsPrinted, 
							IH.PrintedUserKey, IH.PaymentRecdUserKey, IH.PaymentRecdDate, IH.PrintedDate, IH.IsRevised, 
							IH.RevisionDate, ISNULL(IH.BrokerRefNo, OH.BrokerRefNo) AS BrokerRefNo, 
							CU.IsFactored, '' AS VesselETA, ISNULL(VIB.BalanceAmount,IH.InvoiceAmount) AS BalanceAmount
							, OH.CustKey , OH.OrderDate, OH.BillOfLading, OT.OrderType,
							OH.BookingNo, IC.TerminationDate AS TerminationDate, 
							ad.AddrName,ML.MarketLocationKey,ML.MarketLocation	, IH.IsPaymentReceived, IH.RevisionUserKey, 
							IH.InvoiceApprovedUserKey, IH.CustomerNote, IH.InternalNote,ISNULL(IH.CustApproved,0) ,ISNULL(IH.ReasoncodeKey,0),IR.ReasonCode AS ReasonCodeName,
							CU.CustomerCompanyKey AS CustCompanyKey,DATEDIFF(DAY,IH.InvoiceDate,GETDATE()) AgingDays, IH.CreateUserKey,IH.AprovedReasonCodeKey,ApprovedReasonCode
							,CC.CompanyName AS CustCompanyName, 0, '',0,0,CSR.CsrName,'', 0, 0
			FROM			InvoiceHeader  IH WITH (NOLOCK)
			INNER JOIN		OrderHeader  OH WITH (NOLOCK) ON (IH.OrderKey = OH.OrderKey)
			INNER JOIN		Customer  CU WITH (NOLOCK)ON (IH.CustKey = CU.CustKey)
			--INNER JOIN	InvoiceContainers ID WITH (NOLOCK)ON (IH.InvoiceKey = ID.InvoiceKey)
			LEFT JOIN		(SELECT DISTINCT InvoiceKey, TerminationDate FROM InvoiceContainers WITH (NOLOCK)) IC ON IH.invoicekey = IC.InvoiceKey
			LEFT JOIN		dbo.[Address] AD WITH (NOLOCK) ON AD.AddrKey=OH.DestinationAddrKey
			LEFT JOIN		dbo.InvoiceStatus INS WITH (NOLOCK) ON INS.[StatusKey]=IH.[StatusKey]
			LEFT JOIN		vInvoiceBalanceAmount VIB  WITH (NOLOCK) ON IH.InvoiceKey = VIB.InvoiceKey
			LEFT JOIN		DBO.ORDERTYPE OT WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
			LEFT JOIN		MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
			LEFT JOIN		InvoiceReasonCode IR WITH(NOLOCK) ON IR.ReasoncodeKey = IH.ReasoncodeKey
			LEFT JOIN		ArchivedInvoiceHistory AIH WITH (NOLOCK) ON AIH.InvoiceKey=IH.InvoiceKey
			LEFT JOIN		InvoiceCustApprovedReasonCode	IARC WITH (NOLOCK) ON IARC.AprovedReasonCodeKey=IH.AprovedReasonCodeKey
			LEFT JOIN		CustomerCompany CC WITH (NOLOCK) ON ISNULL(CU.CustomerCompanyKey,0) = ISNULL(CC.CustomerCompanyKey,0)
			LEFT JOIN		CSR CSR WITH (NOLOCK) ON CSR.CsrKey=OH.CsrKey
			
			WHERE			AIH.InvoiceKey IS NULL AND NOT(IH.StatusKey = 3 and IH.CreateDate <= Getdate() - 60)
							
		END
		
	IF(@IsDebug = 1)
		BEGIN
			SELECT '#ToInvoice', COUNT(1) FROM #ToInvoice
		END

	UPDATE			A SET ContainerList = B.ContainerList 
	FROM			#Toinvoice   A WITH (NOLOCK)
	INNER JOIN		( SELECT DISTINCT ST2.InvoiceKey, 
							(
								SELECT ST1.ContainerNo + ',' AS [text()]
								FROM InvoiceContainers ST1 WITH (NOLOCK)
								WHERE ST1.InvoiceKey = ST2.InvoiceKey
								ORDER BY ST1.InvoiceKey
								FOR XML PATH (''), TYPE
							).value('text()[1]','nvarchar(max)') ContainerList
						FROM InvoiceHeader  ST2 WITH (NOLOCK)
					) B ON a.InvoiceKey = b.InvoiceKey


	SELECT DISTINCT RT.OrderDetailKey 
	INTO			#PendingLegContainers
	FROM			dbo.[Routes] RT WITH (NOLOCK)
	INNER JOIN		dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
	INNER JOIN		#Toinvoice G WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE			RTS.[Description] <>'Leg Completed'-- AND G.Statuskey = 9

	/*
	SELECT DISTINCT RT.OrderDetailKey , Rt.RouteKey
	INTO			#PendingRateConfirm
	FROM			dbo.[Routes] RT  WITH (NOLOCK)
	INNER JOIN		dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
	INNER JOIN		#Toinvoice G WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE			RTS.[Description] ='Leg Completed' --AND isnull(RT.IsRateVerified,0)=0 
	

	DELETE 
	FROM			#Toinvoice 
	WHERE			OrderDetailKey IN ( SELECT OrderDetailKey FROM #PendingLegContainers WITH (NOLOCK) )
	*/

	SELECT			ContCount,InvoiceKey INTO #MultContainer 
	FROM			(SELECT COUNT(1) AS ContCount,T.InvoiceKey 
					FROM dbo.InvoiceContainers  S   WITH (NOLOCK)
					INNER JOIN ( SELECT DISTINCT InvoiceKey FROM #Toinvoice WITH (NOLOCK) ) T  ON T.InvoiceKey=S.InvoiceKey			
					GROUP BY T.InvoiceKey ) D

	
	UPDATE			#Toinvoice
	SET				IsDataSelected = 1
	WHERE				(  ISNULL(@OrderKey,0) =0  OR OrderKey=@OrderKey )	
					AND (  ISNULL(@CustomerKey,'') = ''  OR CustKey IN (SELECT CustomerKey FROM #CustomerKeys))	
					AND ( ISNULL(@marketLocationKey, '') = '' OR MarketLocationKey  IN (SELECT MarketLocationKey FROM #MarketLocationKeys))
					AND ( ISNULL(@InvoicerKey,'') = '' OR InvoicerKey IN (SELECT InvoicerKey FROM #InvoicerKeys))
					AND (ISNULL(@CustApproved,2) = 2  OR ISNULL(CustApproved,0) = @IsCustApproved)
					AND (ISNULL(@Factored,2)= 2 OR ISNULL(IsFactored,0) = @IsFactored)
					AND (ISNULL(@CustCompanyKey,'' ) = '' OR ISNULL(CustCompanyKey,0) IN (SELECT CustCompanyKey FROM #CustCompanyKeys))
					AND	( OrderDate BETWEEN @OrderDateFrom and @OrderdateTo )
					AND (  ISNULL(@OrderNo,'') = '' OR OrderNo like '%' + @OrderNo + '%' )	
					AND (  ISNULL(@containerNo,'')	= '' OR Containerlist like '%' +  @containerNo + '%' )		
					AND (  ISNULL(@InvoiceNo,'')= '' OR ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
					AND (  ISNULL(@InvoiceKey,0)= 0 OR InvoiceKey=@InvoiceKey )
					AND (  ISNULL(@BOL,'') = '' OR BillOfLading like '%' +@BOL+ '%' )
					AND	(ISNULL(@SearchText,'') =  '' OR  
							(OrderNo like '%' + @SearchText + '%' OR ContainerNo  like '%' + @SearchText + '%'  OR 
							ContainerList  like '%' + @SearchText + '%'  OR 
							BrokerRefNo like '%' + @SearchText + '%' OR BillOfLading  like '%' + @SearchText + '%'  
							OR City  like '%' + @SearchText + '%' 
							OR CustID  like '%' + @SearchText + '%'  OR CustName  like '%' + @SearchText + '%' 
							OR InvoiceNo  like '%' + @SearchText + '%' ) )
	If(@IsDebug = 1)
	Begin
		select '#Toinvoice-2', count(1) from #ToInvoice
	End

	SELECT			A.OrderKey,
					A.OrderDetailKey,--case when A.InvoiceKey is null then  A.OrderDetailKey else 0 end AS OrderDetailKey ,
					OrderNo,	
					CASE WHEN ISNULL(M.ContCount,1)=1 THEN ISNULL(A.ContainerList, A.ContainerNo) ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo,
					A.ActualArrival,CustID,CustName,A.City AS DestinationCity,A.IsInvoiceApproved,
					A.StatusKey,[Status],A.InvoiceAmount,A.DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,
					A.DocumentCount AS DocumentCount,
					A.CustomerNote, A.InternalNote , 
					CASE WHEN isnull(ExpCount,0) > 0 THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsRateVerified,M.ContCount
					,A.IsPrinted, A.PrintedUserKey, A.PaymentRecdUserKey, A.PaymentRecdDate, A.PrintedDate,A.IsRevised, 
					A.RevisionDate, 
					A.RevisionUserKey, U1.UserName AS ApprovedUserName, U2.UserName AS PrintedUserName, 
					U3.UserName AS PaymentRecdUserName, 
					U4.UserName AS RevisedUserName, A.IsPaymentReceived,
					A.BrokerRefNo, IsFactored, ISNULL(A.VesselETA , '1/1/1900') AS VesselETA, A.BalanceAmount
					, A.CustKey, A.OrderDate, BillOfLading, OrderType, BookingNo, TerminationDate,
					--CASE WHEN ISNULL(M.ContCount,1)=1 THEN TerminationDate else null end AS TerminationDate,
					ISNULL(ContainerList,A.ContainerNo) AS ContainerList , AddrName,
					A.MarketLocationKey,A.MarketLocation,A.CustApproved,A.ReasoncodeKey,A.ReasonCodeName,
					A.CustCompanyKey,AgingDays,InvoicerKey,AprovedReasonCodeKey,
					ApprovedReasonCode,CustCompanyName, U5.UserName InvoicerName, 
					A.RouteKey,LegID,IsDataSelected,IsSelectedStatusKey,CSR,WarehouseStatus, 
					AllowInvoicing, 1 IsCSChargesApproved, CSChargesApproveDate,
					isnull(ExpCount,0) as ExpCount
	INTO			#InvoiceListData
	FROM			#Toinvoice A WITH (NOLOCK)		
		--LEFT JOIN InvoiceHeader H  WITH (NOLOCK) ON A.InvoiceKey = H.InvoiceKey
	--LEFT JOIN		#PendingRateConfirm  F WITH (NOLOCK) ON F.OrderDetailKey=A.OrderDetailKey and A.routekey = F.routekey
	LEFT JOIN		#MultContainer M WITH (NOLOCK) ON M.InvoiceKey=A.InvoiceKey
	LEFT JOIN		[User] U1 WITH (NOLOCK) ON A.InvoiceApprovedUserKey = U1.UserKey
	LEFT JOIN		[User] U2 WITH (NOLOCK) ON A.PrintedUserKey = U2.UserKey
	LEFT JOIN		[User] U3 WITH (NOLOCK) ON A.PaymentRecdUserKey = U3.UserKey
	LEFT JOIN		[User] U4 WITH (NOLOCK) ON A.RevisionUserKey = U4.UserKey
	LEFT JOIN		[User] U5 WITH (NOLOCK) ON A.InvoicerKey = U5.UserKey
	WHERE			1 = 1  AND IsDataSelected = 1
					--AND  ( @ChargeConfirmed = Case when @StatusKey <> 9 then @ChargeConfirmed
					--								WHEN @ChargeConfirmed = 2 then @ChargeConfirmed
					--								WHEN @StatusKey  = 9 then  isnull(IsCSChargesApproved,0) else 0 end )
													 
				
	
	IF(@IsDebug = 1)
		BEGIN
			SELECT TOP 1 '#InvoiceListData',*  FROM #InvoiceListData 
		END

	SELECT			S.StatusKey, StatusName AS Description , ISNULL(A.cnt,0) AS InvoiceCount
	INTO			#Temp
	FROM			#InvStatus S WITH (NOLOCK)
	LEFT JOIN		(SELECT Z.StatusKey, COUNT(1) cnt 
					FROM (
							SELECT  OrderKey,OrderDetailKey,OrderNo,ContainerNo,ActualArrival,CustID,CustName,DestinationCity ,IsInvoiceApproved,
								StatusKey,InvoiceAmount,DestinationAddrKey,InvoiceKey,InvoiceNo,InvoiceDate
							FROM #InvoiceListData WITH (NOLOCK)			
					
						) Z
					GROUP BY StatusKey
					) A ON S.StatusKey = A.StatusKey
	
	IF(@IsDebug = 1)
		BEGIN
			SELECT '#Temp',* FROM #Temp
		END

	UPDATE			A	
	SET				LastCount = B.InvoiceCount 
	FROM			InvoiceCounts  A WITH (NOLOCK)
	INNER JOIN		#Temp B WITH (NOLOCK) ON a.StatusKey = B.StatusKey

	
	SELECT			A.statusKey, Description, 
					case when InvoiceCount > 0 then InvoiceCount else LastCount end InvoiceCount, 'I' AS Level 
	INTO			#Dashboard 
	FROM			InvoiceCounts A WITH (NOLOCK)
	LEFT JOIN		#temp  B WITH (NOLOCK) ON a.StatusKey = B.StatusKey
	
	INSERT INTO		#Dashboard (StatusKey, Description, InvoiceCount, Level)
	SELECT			0, 'All', SUM(InvoiceCount) AS StatusCount, 'S' AS Level FROM #Dashboard

	if(@IsDebug = 1)
		BEGIN
			SELECT '#Dashboard', * FROM #Dashboard
		END
	
	UPDATE			#InvoiceListData 
	SET				IsSelectedStatusKey = 1
	WHERE			IsDataSelected = 1 and ((ISNULL(@SearchText,'') <>''  And StatusKey = @StatusKey) OR 
					(StatusKey in (1,2,3,9) AND (ISNULL(@statusKey,0) = 0 OR  StatusKey =  @statusKey )))

	DECLARE			@cnt INT
	SELECT			@cnt = COUNT(1) FROM #InvoiceListData WITH (NOLOCK) WHERE IsSelectedStatusKey = 1

	DECLARE			@STRSQL VARCHAR(MAX)


	
	SELECT *,0 as RecCount, 0 AS RowNum  INTO  #FinalData_Temp FROM #InvoiceListData WITH (NOLOCK) WHERE 1 <> 1 

	IF(@IsDebug = 1)
		BEGIN
			SELECT '@outputType', @outputType
			SELECT TOP 30 '#InvoiceListData', * FROM #InvoiceListData WITH (NOLOCK)  WHERE IsSelectedStatusKey = 1
		END

	IF(ISNULL(@outputType,'') IN ('Excel','PDF'))
		BEGIN
			SET		@PageNo = 1
			SET		@PageSize = (SELECT COUNT(*) FROM  #InvoiceListData WITH (NOLOCK) WHERE IsSelectedStatusKey = 1)
		END
	
	IF(@IsDebug = 1)
		BEGIN
			SELECT 'Pagination', @PageNo,@PageSize
			SELECT DISTINCT StatusKey FROM #InvoiceListData WITH (NOLOCK) WHERE IsSelectedStatusKey = 1 
		END

	SET				@STRSQL = '
					SELECT *   FROM (
					SELECT top 1000000 *,' + convert(varchar, @cnt) + ' as RecCount
					,ROW_NUMBER() Over(Order by ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ', ContainerNo ' + ') RowNum
					FROM #InvoiceListData
					WHERE IsSelectedStatusKey = 1) a
					WHERE ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
					+' Order BY ROWNUM'

	PRINT			(@STRSQL)

	INSERT INTO		#FinalData_Temp
	EXEC			(@STRSQL)


	IF(@IsDebug = 1)
	BEGIN
		SELECT '#FinalData_Temp', * FROM #FinalData_Temp
	END

	update A set OrderDetailKey = IC.OrderDetailsKey
	from #FinalData_Temp A
	inner join InvoiceContainers IC WITH (NOLOCK) on A.InvoiceKey = IC.InvoiceKey
	where A.StatusKey in (1,2,3)
	
	update A SEt ExpCount = isnull(OE.ExpCount ,0)
	from #FinalData_Temp A
	LEFT JOIN		vorderExpencesCount  OE WITH (NOLOCK) on OE.Orderdetailkey = A.OrderDetailKey
	where A.StatusKey in (1,2,3)

	SELECT	InvoiceList = (
			SELECT * FROM #FinalData_Temp WITH (NOLOCK)
			WHERE IsSelectedStatusKey = 1 
			FOR JSON PATH
		), 
		DropDowns = ( SELECT
			CustomerList =		(SELECT DISTINCT	CustKey, CustName FROM  #InvoiceListData  WITH (NOLOCK)
								WHERE				IsSelectedStatusKey = 1 AND ISNULL(CustName,'')<>''			ORDER BY CustName FOR JSON PATH),
			CustCompanyList =	(SELECT DISTINCT	CustCompanyKey,CustCompanyName FROM #InvoiceListData  WITH (NOLOCK)
								WHERE				IsSelectedStatusKey = 1 AND ISNULL(CustCompanyName,'')<>''	ORDER BY CustCompanyName FOR JSON PATH ),
			MarketLocList =		(SELECT DISTINCT	MarketLocationKey,MarketLocation FROM #InvoiceListData WITH (NOLOCK) 
								WHERE				IsSelectedStatusKey = 1 AND ISNULL(MarketLocation,'')<>''	ORDER BY MarketLocation FOR JSON PATH ),
			InvoicerList =		(SELECT DISTINCT	InvoicerKey,InvoicerName FROM #InvoiceListData  WITH (NOLOCK)
								WHERE				IsSelectedStatusKey = 1 AND ISNULL(InvoicerName,'')<>''		ORDER BY InvoicerName FOR JSON PATH )
			FOR JSON PATH
		),
		Dashboard = (
			SELECT * FROM #DashBoard WITH (NOLOCK)
			For JSON PATH
		)
		FOR JSON PATH
		INSERT INTO SqlExecutionTimeLog
	(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	VALUes (@UserKey,'Get_InvoiceList_V2','Procedure Execution end','',GETDATE())
		SET @Status = 1
		SET @Reason = 'Success'

	
END
