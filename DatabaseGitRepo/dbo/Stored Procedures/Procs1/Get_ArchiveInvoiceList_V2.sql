-- EXEC Get_ArchiveInvoiceList_V2 @IsDebug = 1
CREATE Procedure [dbo].[Get_ArchiveInvoiceList_V2] 
-- [Get_ArchiveInvoiceList_JSON] @StatusKey=15, @PageNo = 1, @Pagesize=2
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '{"Factored":2,"CustApproved":2,"PageNo":1,"PageSize":50,"Ascending":true,"IsAscending":true,"CustomerKey":"","MarketLocationKey":"","CustCompanyKey":"","SortField":"TerminationDate","StatusKey":15}',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3= Payment Received, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON;
	SET FMTONLY OFF;	
		
	DECLARE @IsFactored		BIT 
	DECLARE @IsCustApproved BIT	
	DECLARE
	@StatusKey				INT,
	@CustomerKey			VARCHAR(MAX),
	@OrderKey				INT,
	@OrderDateFrom			DATE,
	@OrderDateTO			DATE,
	@DeliveryDateFrom		DATE,
	@DeliveryDateTo			DATE,
	@OrderNo				VARCHAR(50),
	@containerNo			VARCHAR(50),
	@InvoiceNo				VARCHAR(50),
	@InvoiceKey				INT,
	@BOL					VARCHAR(30),
	@PageNo					INT,
	@PageSize				INT,
	@SortField				VARCHAR(50),
	@IsAscending			BIT,
	@SearchText				VARCHAR(50),
	@marketLocationKey		VARCHAR(MAX),
	@Factored				INT ,
	@CustApproved			INT ,
	@InvoicerKey			INT = 0,
	@CustCompanyKey			VARCHAR(MAX),
	@outputType				VARCHAR(20)


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
					@OrderDateFrom		= OrderDateFrom	,		@OrderDateTO		= OrderDateTO,		@DeliveryDateFrom	= DeliveryDateFrom,	
					@DeliveryDateTo		= DeliveryDateTo,		@OrderNo			= OrderNo,			
					@containerNo		= containerNo,			@InvoiceNo			= InvoiceNo,		@InvoiceKey			= InvoiceKey,			
					@BOL				= BOL	,				@PageNo				= PageNo,			
					@PageSize			= PageSize	,			@SortField			= SorField,			@IsAscending		= IsAscending,		
					@SearchText			= SearchText,			@marketLocationKey	= marketLocationKey,@Factored         	= Factored,
					@CustApproved		= CustApproved  ,		@InvoicerKey		= InvoicerKey,       
					@CustCompanyKey		= CustCompanyKey,		@outputType			= outputType

	FROM			OPENJSON(@JsonString, '$')
					WITH (
					StatusKey				INT				'$.StatusKey',
					CustomerKey				VARCHAR(MAX)	'$.CustomerKey',
					OrderKey				INT				'$.OrderKey',
					OrderDateFrom			DATE			'$.OrderDateFrom',
					OrderDateTO				DATE			'$.OrderDateTO',
					DeliveryDateFrom		DATE			'$.DeliVeryDateFom',
					DeliveryDateTo			DATE			'$.DelivaryDateTo',
					OrderNo					VARCHAR(50)		'$.OrderNo',
					containerNo				VARCHAR(50)		'$.containerNo',
					InvoiceNo				VARCHAR(50)		'$.InvoiceNo',
					InvoiceKey				INT				'$.InvoiceKey',
					BOL						VARCHAR(30)		'$.BOLNo',
					PageNo					INT				'$.PageNo',
					PageSize				INT				'$.PageSize',
					SorField				VARCHAR(50)		'$.SortField',
					IsAscending				BIT				'$.IsAscending',
					SearchText				VARCHAR(50)		'$.SearchText',
					MarketLocationKey		VARCHAR(MAX)	'$.MarketLocationKey',
					Factored				INT				'$.Factored',
					CustApproved			INT				'$.CustApproved',
					InvoicerKey				INT				'$.InvoicerKey',
					CustCompanyKey			VARCHAR(MAX)	'$.CustCompanyKey' ,
					outputType				VARCHAR(20)		'$.outputType'	
	
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

	IF(@ISDebug = 1)
		BEGIN
			SELECT			@StatusKey			AS StatusKey,			@CustomerKey		AS CustomerKey,		@OrderKey			AS OrderKey,			
							@OrderDateFrom		AS OrderDateFrom	,	@OrderDateTO		AS OrderDateTO,		@DeliveryDateFrom	AS DeliveryDateFrom,	
							@DeliveryDateTo		AS DeliveryDateTo,		@OrderNo			AS OrderNo,			
							@containerNo		AS containerNo,			@InvoiceNo			AS InvoiceNo,		@InvoiceKey			AS InvoiceKey,			
							@BOL				AS BOL	,				@PageNo				AS PageNo,			
							@PageSize			AS PageSize	,			@SortField			AS SorField,		@IsAscending		AS IsAscending,		
							@SearchText			AS SearchText,			@marketLocationKey	AS marketLocationKey,@Factored         AS  Factored,
							@CustApproved		AS  CustApproved  ,		@InvoicerKey		AS  InvoicerKey,       
							@CustCompanyKey		AS  CustCompanyKey
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
	
	CREATE TABLE #CustCompanyKeys
	(
		CustCompanyKey	INT
	)

	IF(@marketLocationKey = '0')
		BEGIN
			SET @marketLocationKey = ''
		END

	IF(@CustomerKey = '0')
		BEGIN
			SET @CustomerKey = ''
		END

	CREATE TABLE #CustomerKeys
	(
		CustomerKey	INT
	)

	CREATE TABLE #MarketLocationKeys
	(
		MarketLocationKey	INT
	)

	IF(ISNULL(@CustCompanyKey,'') <> '')
		BEGIN
			INSERT INTO	#CustCompanyKeys(CustCompanyKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@CustCompanyKey)
		END	
	
	IF(ISNULL(@CustomerKey,'') <> '')
		BEGIN
			INSERT INTO	#CustomerKeys(CustomerKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@CustomerKey)
		END		
		
	IF(ISNULL(@MarketLocationKey,'') <> '')
		BEGIN
			INSERT INTO	#MarketLocationKeys(MarketLocationKey)
			SELECT VALUE FROM dbo.Fn_SplitParamCol(@MarketLocationKey)
		END	

	IF(@IsDebug = 1)
		BEGIN
			SELECT '#CustomerKeys',* FROM #CustomerKeys
			SELECT '#MarketLocationKeys',* FROM #MarketLocationKeys
		END

	IF LEFT(@InvoiceNo, 1) = '0'   SET @InvoiceNo =  RIGHT(@InvoiceNo, LEN(@InvoiceNo)-1)

	SELECT		StatusKey, [Description] AS StatusName INTO #InvStatus
	FROM		dbo.InvoiceStatus with(nolock)
	UNION ALL 
	SELECT		9,'Pending to Invoice'
	--UNION ALL
	--SELECT 4,'Archived'

	IF(@ISDebug = 1)
		BEGIN
			SELECT '@marketLocationKey', @marketLocationKey
		END

	SELECT			OH.OrderKey, 
					CASE WHEN IH.InvoiceKey is null THEN  od.OrderDetailKey ELSE 0 END AS OrderDetailKey ,
					oh.OrderNo,od.ContainerNo, MAX(RT.ActualArrival) AS ActualArrival,
					CU.CustID,CU.CustName,ISNULL(IH.IsInvoiceApproved,0) AS IsInvoiceApproved,
					15 as StatusKey, --ISNULL(INS.[StatusKey],15)  AS StatusKey,
					IH.InvoiceAmount,AD.City,
					ISNULL(INS.[Description],'Archive')  AS [Status],--RT.RouteKey,
					OH.DestinationAddrKey,IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate,  
					--ISNULL(CDC.DocumentCount,0) AS DocumentCount  --- not requred since its duplicating invoice
					0 AS DocumentCount 
					,IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate,IsRevised, 
					RevisionDate,ISNULL(IH.BrokerRefNo, OH.BrokerRefNo) AS BrokerRefNo, 
					CU.IsFactored, OD.VesselETA, ISNULL(VIB.BalanceAmount,IH.InvoiceAmount) AS BalanceAmount
					, OH.CustKey , OH.OrderDate, OH.BillOfLading, OT.OrderType,
					OH.BookingNo, OD.CompleteDate AS TerminationDate,
					CONVERT(VARCHAR(MAX), '') AS ContainerList, ad.AddrName,
					ML.MarketLocationKey,ML.MarketLocation, CU.CustomerCompanyKey AS CustCompanyKey, CC.CompanyName AS CustCompanyName, IH.CreateUserKey AS InvoicerKey,
					CONVERT(BIT, 0) AS IsDataSelected,
					CONVERT(BIT,0)	AS IsSelectedStatusKey
	INTO			#Toinvoice		
	FROM			dbo.[routes] RT WITH (NOLOCK)
					INNER JOIN dbo.OrderDetail OD		WITH (NOLOCK) ON RT.OrderDetailKey = OD.OrderDetailKey
					INNER JOIN dbo.OrderDetailStatus ODS WITH (NOLOCK) ON ODS.[Status]=OD.[Status]
					INNER JOIN dbo.OrderHeader OH		WITH (NOLOCK) ON OH.OrderKey = OD.OrderKey
					INNER JOIN dbo.Customer CU		    WITH (NOLOCK) ON CU.CustKey = OH.CustKey
					INNER JOIN dbo.Leg LG				WITH (NOLOCK) ON LG.LegKey = RT.LegKey
					INNER JOIN dbo.LegType L			WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey		
					INNER JOIN dbo.RouteStatus RTS		WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
					INNER JOIN dbo.RouteInvoice RI		WITH (NOLOCK) ON RI.OrderDetailKey=OD.OrderDetailKey
					INNEr JOIN dbo.InvoiceHeader IH		WITH (NOLOCK) ON IH.InvoiceKey=RI.InvoiceKey		
					LEFT JOIN dbo.InvoiceStatus INS		WITH (NOLOCK) ON INS.[StatusKey]=IH.[StatusKey]
					LEFT JOIN dbo.[Address] AD			WITH (NOLOCK) ON AD.AddrKey=OH.DestinationAddrKey
					LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
					LEFT JOIN vInvoiceBalanceAmount VIB  WITH (NOLOCK) on IH.InvoiceKey = VIB.InvoiceKey
					LEFT JOIN DBO.ORDERTYPE		OT		WITH (NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey
					LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
					LEFT JOIN CustomerCompany CC WITH(NOLOCK) ON CU.CustomerCompanyKey = CC.CustomerCompanyKey
	WHERE 			RTS.[Description]='Leg Completed' AND (ODS.status in (15))
					AND	(  @DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom>=@DeliveryDateFrom )
					AND (  @DeliveryDateTo	IS NULL OR RT.DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom<=@DeliveryDateTo )
					AND (  ISNULL(@marketLocationKey,'') = '' OR ISNULL(OH.MarketLocationKey,0) In  (SELECT MarketLocationKey FROM #MarketLocationKeys) )
	GROUP BY		OH.OrderKey,oh.OrderNo,od.ContainerNo,CU.CustName,IH.IsInvoiceApproved,
					ISNULL(INS.[StatusKey],15),IH.InvoiceAmount,AD.City,OH.DestinationAddrKey,
					IH.InvoiceKey,IH.InvoiceNo,IH.InvoiceDate,CU.CustID,INS.[Description] 
					,IsPrinted, PrintedUserKey, PaymentRecdUserKey, PaymentRecdDate, PrintedDate,IsRevised, 
					RevisionDate, ISNULL(IH.BrokerRefNo, OH.BrokerRefNo), CU.IsFactored, OD.VesselETA, VIB.BalanceAmount,
					CASE WHEN IH.InvoiceKey is null THEN  od.OrderDetailKey ELSE 0 END
					, OH.CustKey, OH.OrderDate, OH.BillOfLading, OrderType, OH.BookingNo, OD.CompleteDate, ad.AddrName,
					ML.MarketLocationKey,ML.MarketLocation, CU.CustomerCompanyKey, CC.CompanyName, IH.CreateUserKey
	
	IF(@IsDebug = 1)
		BEGIN
			SELECT '#Toinvoice',  COUNT(1) FROm #Toinvoice
		END

	UPDATE			TI SET ContainerList = x.ContainerList
	--SELECT *,		ContainerList
	FROM			#Toinvoice TI
	CROSS APPLY		(SELECT		stuff((SELECT DISTINCT ',' + ContainerNo 
					FROM		Invoicedetail A
					INNER JOIN	OrderDetail B on A.OrderDetailKey = B.OrderDetailKey
					WHERE		A.InvoiceKey = TI.InvoiceKey
					FOR XML PATH ('')),1,1,'') AS ContainerList
					) AS X

	SELECT DISTINCT RT.OrderDetailKey INTO #PendingLegContainers
	FROM			dbo.[Routes] RT WITH (NOLOCK)
	INNER JOIN		dbo.RouteStatus RTS		WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
	INNER JOIN		#Toinvoice G				WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE			RTS.[Description] <>'Leg Completed'

	SELECT DISTINCT RT.OrderDetailKey INTO #PendingRateConfirm
	FROM			dbo.[Routes] RT  WITH (NOLOCK)
	INNER JOIN		dbo.RouteStatus RTS		 WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
	INNER JOIN		#Toinvoice G				 WITH (NOLOCK) ON G.OrderDetailKey=RT.OrderDetailKey
	WHERE			RTS.[Description] ='Leg Completed' AND RT.IsRateVerified=0

	DELETE 
	FROM			#Toinvoice 
	WHERE			OrderDetailKey IN ( SELECT OrderDetailKey FROM #PendingLegContainers )

	SELECT			ContCount,InvoiceKey INTO #MultContainer 
	FROM			(SELECT		COUNT(1) AS ContCount,T.InvoiceKey 
					FROM dbo.	RouteInvoice S  WITH (NOLOCK)
					INNER JOIN	(SELECT DISTINCT InvoiceKey FROM #Toinvoice ) T  ON T.InvoiceKey=S.InvoiceKey			
					GROUP BY	T.InvoiceKey ) D

	SELECT			A.OrderKey,
					CASE WHEN A.InvoiceKey is null THEN  A.OrderDetailKey ELSE 0 END AS OrderDetailKey ,
					OrderNo,	
					CASE WHEN ISNULL(M.ContCount,1)=1 THEN MAX(A.ContainerNo) ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo,--A.ContainerNo,
					MAX(ActualArrival) AS ActualArrival,CustID,CustName,A.City AS DestinationCity,A.IsInvoiceApproved,
					A.StatusKey,[Status],A.InvoiceAmount,A.DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,
					Max(A.DocumentCount) AS DocumentCount,
					H.CustomerNote, H.InternalNote , 
					CASE WHEN F.OrderDetailKey IS NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END AS IsRateVerified,M.ContCount
					,h.IsPrinted, h.PrintedUserKey, H.PaymentRecdUserKey, H.PaymentRecdDate, H.PrintedDate,H.IsRevised, 
					H.RevisionDate, 
					H.RevisionUserKey, U1.UserName AS ApprovedUserName, U2.UserName AS PrintedUserName, 
					U3.UserName AS PaymentRecdUserName, 
					U4.UserName AS RevisedUserName, H.IsPaymentReceived,
					A.BrokerRefNo, IsFactored, ISNULL(A.VesselETA , '1/1/1900') AS VesselETA, A.BalanceAmount
					, A.CustKey, A.OrderDate, BillOfLading, OrderType, A.BookingNo, CASE WHEN ISNULL(M.ContCount,1)=1 THEN TerminationDate ELSE null END AS TerminationDate,
					ISNULL(ContainerList,A.ContainerNo) AS ContainerList , AddrName,
					A.MarketLocationKey,A.MarketLocation,CustCompanyKey, CustCompanyName, ISNULL(H.CustApproved,0) CustApproved, U5.UserName AS InvoicerName, InvoicerKey,
					IsDataSelected,IsSelectedStatusKey
	INTO			#InvoiceListData
	FROM			#Toinvoice A		
	LEFT JOIN		InvoiceHeader H  WITH (NOLOCK) on A.InvoiceKey = H.InvoiceKey
	LEFT JOIN		#PendingRateConfirm F ON F.OrderDetailKey=A.OrderDetailKey
	LEFT JOIN		#MultContainer M ON M.InvoiceKey=A.InvoiceKey
	LEFT JOIN		[User] U1 WITH (NOLOCK)  ON H.InvoiceApprovedUserKey = U1.UserKey
	LEFT JOIN		[User] U2 WITH (NOLOCK) ON H.PrintedUserKey = U2.UserKey
	LEFT JOIN		[User] U3 WITH (NOLOCK) ON H.PaymentRecdUserKey = U3.UserKey
	LEFT JOIN		[User] U4 WITH (NOLOCK) ON H.RevisionUserKey = U4.UserKey
	LEFT JOIN		[User] U5 WITH (NOLOCK) ON A.InvoicerKey = U5.UserKey
	WHERE			A.StatusKey = 15
	GROUP BY		A.OrderKey,OrderNo,CustID,CustName,A.City,A.IsInvoiceApproved,A.StatusKey,A.OrderDetailKey,
					[Status],A.InvoiceAmount,A.DestinationAddrKey,A.InvoiceKey,A.InvoiceNo,A.InvoiceDate,H.CustomerNote,H.InternalNote,
					F.OrderDetailKey,M.ContCount
					,h.IsPrinted, h.PrintedUserKey, H.PaymentRecdUserKey, H.PaymentRecdDate, H.PrintedDate,H.IsRevised, H.RevisionDate,
					H.RevisionUserKey, U1.UserName, U2.UserName, U3.UserName, u4.UserName, H.IsPaymentReceived
					, A.BrokerRefNo, IsFactored, ISNULL(A.VesselETA , '1/1/1900'), A.BalanceAmount
					, A.CustKey, A.OrderDate,  BillOfLading, OrderType, A.BookingNo, ISNULL(ContainerList,A.ContainerNo),AddrName,A.MarketLocationKey,A.MarketLocation,
					CASE WHEN ISNULL(M.ContCount,1)=1 THEN TerminationDate ELSE null END ,CustCompanyKey, CustCompanyName, ISNULL(H.CustApproved,0),  U5.UserName, InvoicerKey,
					IsDataSelected,IsSelectedStatusKey
	ORDER BY		(CASE WHEN @StatusKey = 15 THEN OrderNo ELSE A.InvoiceNo END) DESC
	
	UPDATE			#InvoiceListData
	SET				IsDataSelected = 1
	WHERE			1 = 1 
					AND (ISNULL(@OrderKey,0) =0 OR OrderKey=@OrderKey )	
					AND (ISNULL(@CustomerKey,'') = '' OR CustKey IN (SELECT CustomerKey FROM #CustomerKeys) )	
					AND	(@OrderDateFrom	IS NULL OR OrderDate		IS NULL OR OrderDate>=@OrderDateFrom )
					AND (@OrderDateTo		IS NULL OR OrderDate		IS NULL OR OrderDate<=@OrderDateTo )
					AND (ISNULL(@OrderNo,'') = '' OR OrderNo like '%' + @OrderNo + '%' )	
					AND (ISNULL(@containerNo,'') = '' OR Containerlist like '%' +  @containerNo + '%' )		
					AND (ISNULL(@InvoiceNo,'')	= '' OR ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
					AND (ISNULL(@CustApproved,2) = 2  OR ISNULL(CustApproved,0) = @IsCustApproved)
					AND (ISNULL(@Factored,2)= 2 OR ISNULL(IsFactored,0) = @IsFactored)
					AND (ISNULL(@CustCompanyKey,'' ) = '' OR ISNULL(CustCompanyKey,0) IN (SELECT CustCompanyKey FROM #CustCompanyKeys))
					--AND (ISNULL(InvoiceNo,'NA') like   @InvoiceNo + '%')
					AND (ISNULL(@InvoiceKey,0) = 0 OR InvoiceKey=@InvoiceKey )
					AND (ISNULL(@BOL,'') = '' OR BillOfLading like '%' +@BOL+ '%' )
					AND	(ISNULL(@SearchText,'') =  '' OR (OrderNo like '%' + @SearchText + '%' OR ContainerNo  like '%' + @SearchText + '%'  OR 
									BrokerRefNo like '%' + @SearchText + '%' OR BillOfLading  like '%' + @SearchText + '%'  OR DestinationCity  like '%' + @SearchText + '%' 
									OR CustID  like '%' + @SearchText + '%'  OR CustName  like '%' + @SearchText + '%' OR InvoiceNo  like '%' + @SearchText + '%' ))

						--SELECT * FROM #InvoiceListData



	IF(@IsDebug = 1)
		BEGIN
			SELECT '#Toinvoice',COUNT(1) FROM #Toinvoice WHERE StatusKey = 15
			SELECT '#PendingRateConfirm',COUNT(1) FROM #PendingRateConfirm
			SELECT '#MultContainer',COUNT(1) FROM #MultContainer
			SELECT '#InvoiceListData_first',COUNT(1) FROM #InvoiceListData  WHERE StatusKey = 15
		END

	SELECT			S.StatusKey, StatusName AS Description , ISNULL(A.cnt,0) AS InvoiceCount
	INTO			#Temp
	FROM			#InvStatus S
	LEFT JOIN		(SELECT		Z.StatusKey, COUNT(1) cnt 
					FROM		(SELECT  OrderKey,OrderDetailKey,OrderNo,ContainerNo,ActualArrival,CustID,CustName,DestinationCity ,IsInvoiceApproved,
										StatusKey,InvoiceAmount,DestinationAddrKey,InvoiceKey,InvoiceNo,InvoiceDate
								FROM	#InvoiceListData WHERE IsDataSelected = 1
					) Z
					GROUP BY	StatusKey
					) A ON S.StatusKey = A.StatusKey
	
	If(@IsDebug = 1)
		BEGIN
			SELECT '@CustomerKey',  @CustomerKey
			SELECT '@CustCompanyKey',  @CustCompanyKey
			SELECT '@CustApproved',  @CustApproved
			SELECT '@Factored',  @Factored
		END
	
	
	IF(@IsDebug = 1)
		BEGIN
			SELECT '#InvoiceListData - Status - 15',COUNT(1) FROM #InvoiceListData WHERE StatusKey=15 AND IsDataSelected = 1
		END

	DECLARE			@ArchiveCount INT=0
	SELECT			@ArchiveCount= COUNT(1) FROM #InvoiceListData OD
	WHERE			[StatusKey]=15 AND IsDataSelected = 1

	SELECT			IST.statusKey, ISNULL(Description,'Open') AS Description, IC.LastCount AS InvoiceCount
	INTO			#temp1
	FROM			InvoiceCounts IC
	LEft JOIN		InvoiceStatus IST on IC.StatusKey = IST.StatusKey

	--SELECT			statusKey, Description, InvoiceCount, 'I' AS Level 
	--INTO			#Dashboard
	--FROM			#temp1
	--UNION ALL
	--SELECT			15,'Archived',@ArchiveCount, 'I'
	--UNION ALL
	--SELECT			0, 'All', SUM(InvoiceCount) AS StatusCount, 'S' AS Level FROM #temp1


	SELECT			*
	INTO			#Dashboard
	FROM			(SELECT	 15 statusKey, 'Archived' Description,  @ArchiveCount InvoiceCount, 'I' AS Level ) A


	--SELECT * FROM #StatusData

	DECLARE			@cnt INT
	SELECT			@cnt = count(1) FROM #InvoiceListData WHERE (@StatusKey = 0 OR StatusKey = @StatusKey) AND IsDataSelected = 1
	DECLARE			@STRSQL VARCHAR(MAX)
	
	SELECT			*,0 AS RowNum, 0 AS RecCount INTO  #FinalData_Temp 
	FROM			#InvoiceListData WHERE 1 <> 1 


	IF(@IsDebug = 1)
		BEGIN
			SELECT '@outputType', @outputType
		END

	IF(ISNULL(@outputType,'') IN ('Excel','PDF'))
		BEGIN
			SET		@PageNo = 1
			SET		@PageSize = (SELECT COUNT(*) FROM  #InvoiceListData WHERE IsDataSelected = 1)
		END
	
	IF(@IsDebug = 1)
		BEGIN
			SELECT 'Pagination', @PageNo,@PageSize
			SELECT '#InvoiceListData',COUNT(1) FROM #InvoiceListData WHERE IsDataSelected = 1
		END

	SET @STRSQL = '
	SELECT *, ' + CONVERT(Varchar,@cnt) + ' AS RecCount  FROM (
		SELECT top 1000000 *, ROW_NUMBER() Over(ORDER BY OrderNo) RowNum
		FROM #InvoiceListData WHERE IsDataSelected = 1
		ORDER BY ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' 
	) a
	WHERE ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))

	PRINT (@STRSQL)
	INSERT INTO #FinalData_Temp
	EXEC (@STRSQL)

	--SELECT * FROM #FinalData_Temp --WHERE (@StatusKey = 0 OR StatusKey = @StatusKey)

	SELECT 
	InvoiceList = (
		SELECT * FROM #FinalData_Temp A --WHERE (@StatusKey = 0 OR StatusKey = @StatusKey) 
		FOR JSON PATH
	),
	Dashboard = (
		SELECT * FROM #Dashboard
		FOR JSON PATH
	),
	DropDowns = ( SELECT
			CustomerList =		(SELECT DISTINCT	CustKey, CustName FROM  #InvoiceListData 
								WHERE				isnull(CustName,'')<>'' AND IsDataSelected = 1 ORDER BY  CustName FOR JSON PATH),
			CustCompanyList =	(SELECT DISTINCT	CustCompanyKey,CustCompanyName FROM #InvoiceListData 
								WHERE				isnull(CustCompanyName,'')<>''  AND IsDataSelected = 1  ORDER BY CustCompanyName FOR JSON PATH ),
			MarketLocList =		(SELECT DISTINCT	MarketLocationKey,MarketLocation FROM #InvoiceListData  
								WHERE				isnull(MarketLocation,'')<>''  AND IsDataSelected = 1 ORDER BY MarketLocation FOR JSON PATH ),
			InvoicerList =		(SELECT DISTINCT	InvoicerKey ,InvoicerName FROM #InvoiceListData  
								WHERE				isnull(InvoicerName,'')<>''  AND IsDataSelected = 1 ORDER BY InvoicerName FOR JSON PATH )
			FOR JSON PATH
	)
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
	
END