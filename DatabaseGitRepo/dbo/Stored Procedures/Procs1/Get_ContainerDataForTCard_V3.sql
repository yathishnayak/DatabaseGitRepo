/**
DECLARE 
	@userKey INT=951 ,
	@JSONString NVARCHAR(MAX)='{"PickupDateFrom":"2002-01-01","PickupDateTo":"2050-01-01","DeleveryDateFrom":"2002-01-01","DeleveryDateTo":"2050-01-01","CsrKey":0,"StatusKey":0,"OrderNoFrom":"ACER25111404","OrderNoTo":"ACER25111404","CreatedDateFrom":"2002-01-01","CreatedDateTo":"2050-01-01","MarketLocationKey":0}',
	@Status BIT=0,@Reason VARCHAR(100)='',@IsDebug	BIT = 0,@JSONOutput NVARCHAR(MAX)=''
EXec [Get_ContainerDataForTCard_V3]  @userKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug,@JSONOutput OUTPUT
Select @Status, @Reason
**/

CREATE Procedure [dbo].[Get_ContainerDataForTCard_V3]
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0,
   @JSONOutput		NVARCHAR(MAX)='' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
 
   Declare
	@PickupDateFrom				DATE='01/01/2020',
	@PickupDateTo				DATE='01/12/2099',
	@DeleveryDateFrom			DATE='01/01/2020',
	@DeleveryDateTo				DATE='01/12/2099',
	@CSRKey						INT=0,
	@StatusKey					INT=0,
	@CustomerKey				INT=0,
	@OrderNoFrom				varchar(50) ='',
	@OrderNoTo					varchar(50) ='',
	@CreatedDateFrom			DATE='01/12/2020',
	@CreatedDateTo				DATE='01/12/2099',
	@MarketLocationKey			INT = 0

		IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	--IF (@IsDebug = 1)
	--	BEGIN
	--		SET		@Status = 0
	--		SET		@Reason = 'In Debug Mode'
	--	END	

		SELECT
		@PickupDateFrom		=	PickupDateFrom,	
		@PickupDateTo		=   PickupDateTo,	
		@DeleveryDateFrom	=   DeleveryDateFrom,	
		@DeleveryDateTo		= 	DeleveryDateTo,
		@CSRKey				= 	CSRKey,
		@StatusKey			= 	StatusKey,				
		@OrderNoFrom		= 	OrderNoFrom,		
		@OrderNoTo			= 	OrderNoTo,		
		@CreatedDateFrom	=	CreatedDateFrom,		
		@CreatedDateTo		=   CreatedDateTo,	
		@MarketLocationKey	= 	MarketLocationKey
	FROM OPENJSON(@JSONString, '$')
	WITH(
		PickupDateFrom				DATE				'$.PickupDateFrom',
		PickupDateTo				DATE				'$.PickupDateTo',
		DeleveryDateFrom			DATE				'$.DeliveryDateFrom',
		DeleveryDateTo				DATE				'$.DeliveryDateTo',
		CSRKey						INT					'$.CsrKey',
		StatusKey					INT					'$.StatusKey',
		OrderNoFrom				VARCHAR(50)				'$.OrderNoFrom'	,
		OrderNoTo				VARCHAR(50)				'$.OrderNoTo',
		CreatedDateFrom				DATE				'$.CreatedDateFrom',
		CreatedDateTo				DATE				'$.CreatedDateTo',
		MarketLocationKey			INT 				'$.MarketLocationKey'
	)

	if(@PickupDateFrom = '2002-01-01 00:00:00')
	Begin
		set @PickupDateFrom = null;
		set @PickupDateTo =null 
	end

	if(@PickupDateFrom = '2020-01-01 00:00:00')
	Begin
		set @PickupDateFrom = null;
		set @PickupDateTo = null
	end

	if(@PickupDateFrom = @PickupDateTo)
	begin
		set @PickupDateTo = Dateadd(dd,1, @PickupDateFrom)
	end
	if(@DeleveryDateFrom = @DeleveryDateTo)
	begin
		set @DeleveryDateTo = Dateadd(dd,1, @DeleveryDateFrom) 
	end

	--if(@PickupDateFrom = null and @PickupDateTo = null )
	--begin
	--	set @PickupDateFrom = convert(Date, GetDate() -30)
	--	set @PickupDateTo = CONVERT(Date, getdate() + 1)
	--end

	--if(@DeleveryDateFrom = null and @DeleveryDateTo = null )
	--begin
	--	set @DeleveryDateFrom = convert(Date, GetDate() -30)
	--	set @DeleveryDateTo = CONVERT(Date, getdate() + 1)
	--end
	
	CREATE TABLE #ContCurlocation
	(
		OrderDetailKey INT,
		ContCurrLocation VARCHAR(200),
		RouteKey INT,
		LocationType INT
	)

	
	print @PickupDateFrom
	print @PickupDateTo
	print @DeleveryDateFrom
	print @DeleveryDateTo

	PRINT 'OrderNoFrom: ' + ISNULL(@OrderNoFrom, 'NULL');
	PRINT 'OrderNoTo  : ' + ISNULL(@OrderNoTo, 'NULL');

	Declare @FromOrderKey	int = 0
	Declare @ToOrderKey		int = 0
	select @FromOrderKey = OrderKey from OrderHeader where OrderNo = @OrderNoFrom
	select @ToOrderKey = OrderKey from OrderHeader where OrderNo = @OrderNoTo
	if(@ToOrderKey = 0) 
	begin
		set @ToOrderKey = 999999
	End
	print @FromOrderKey
	print @ToOrderKey

	if(@FromOrderKey > 0)
	Begin
		select @CustomerKey = CustKey from OrderHeader where OrderNo = @OrderNoFrom
		print @CustomerKey
	end

	declare @OpenStatusKey smallint =0;

	select @OpenStatusKey = Status from OrderDetailStatus where Description  = 'Open'
	   
	SELECT
		isnull(OH.OrderKey,0) OrderKey,
		isnull(OH.OrderDate,'1900-01-01') as OrderDate,
		isnull(OD.OrderDetailkey,0) as OrderDetailkey,
		isnull(OT.OrderTypeKey,0) as OrderTypeKey,
		isnull(OH.OrderNo,'') as OrderNo,
		isnull(CR.CsrName,'') as CsrName,
		isnull(OD.ContainerNo,'') as ContainerNo,
		isnull(OD.ContainerID, '') as ContainerID,
		isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,
		isnull(OD.LastFreeDay,'') as LastFreeDay,
		RT.PickupDate AS PickupDate ,
		RT.PickupDateTo AS PickupDateTo ,
		CONVERT(VARCHAR(10), CAST(RT.PickupDate AS TIME), 0) PickupTime,		
		RT.DeliveryDate AS DropOffDate,
		RT.DeliveryDateTo AS DropOffDateTo,
		--OD.DropOffTime,
		CONVERT(VARCHAR(10), CAST(RT.DeliveryDate AS TIME), 0) DropOffTime,	
		isnull(OSD.[Description],'') AS [Status],
		isnull(OT.OrderType,'') AS OrderType,
		isnull(OH.BillOfLading,'') AS BillOfLading,
		isnull(OH.BookingNo,'') AS BookingNo,
		isnull(OH.BrokerRefNo,'') as BrokerRefNo,
		isnull(CS.[Description],'') AS ContainerSize,
		isnull(PT.[Description],'')  AS [Priority],
		isnull(SR.AddrName,'') AS Source_AddrName,
		isnull(SR.Address1,'') AS Source_Address1,
		isnull(SR.City,'')  AS Source_City,
		isnull(SR.[State],'')  AS Source_State,
		isnull(SR.ZipCode,'')  AS Source_ZipCode,
		isnull(SR.Country,'')  AS Source_Country,
		isnull(DT.AddrName,'')  AS Destination_AddrName,
		isnull(DT.Address1,'')  AS Destination_Address1,
		isnull(DT.City,'')  AS Destination_City,
		isnull(DT.[State],'')  AS Destination_State,
		isnull(DT.ZipCode,'')  AS Destination_ZipCode,
		isnull(DT.Country,'')  AS Destination_Country,
		isnull(BT.AddrName,'')  AS Customer_AddrName,
		isnull(BT.Address1,'')  AS Customer_Address1,
		isnull(BT.City,'')  AS Customer_City,
		isnull(BT.[State],'')  AS Customer_State,
		isnull(BT.ZipCode,'')  AS Customer_ZipCode,
		isnull(BT.Country,'')  AS Customer_Country,
		isnull(RET.AddrName,'') AS Return_AddrName,
		isnull(RET.Address1,'') AS Return_Address1,
		isnull(RET.City,'') AS Return_City,
		isnull(RET.[State],'') AS Return_State,
		isnull(RET.ZipCode,'') AS Return_ZipCode,
		isnull(RET.Country,'') AS Return_Country,	
		isnull(OD.VesselETA,'') AS VesselETA,	
		CASE 
			WHEN OD.status = 1
			THEN 'Proceed to Schedule' 
			WHEN OD.status = 3 
			THEN 'Complete Schedule'           
			WHEN OD.status = 4
			THEN 'Confirm/Complete Schedule' 
			WHEN OD.status = 5
			THEN 'Process Dispatch' 
			WHEN OD.status = 7 
			THEN 'Complete Dispatch'   
			WHEN OD.status = 8 
			THEN 'Confirm/Complete Dispatch'  
			WHEN OD.status = 9 
			THEN 'Approve Invoice/Driver Pay'  
			WHEN OD.status = 10 
			THEN 'Closed' 
			WHEN OD.status = 6
			THEN 'Approve for Invoice/Driver Pay' 
			WHEN OD.status = 2
			THEN 'Proceed to Dispatch'
			END AS NextAction,OH.custKey,BR.BrokerName,OD.[Weight],OH.VesselName,OD.SealNo,OD.CutOffDate 
		, isnull(OD.IsEmpty,0) as IsEmpty
		, OD.DriverNotes
		, OD.SchedulerNotes
		, isnull(OD.IsTMF,0) as IsTMF
		, 0 as isTransLoad 
		, isnull(CU.CustName,'') as  CustName
		, isnull(CU.CustID,'') as CustID
		, WeightUnit
		, ISNULL(SP.SalesPersonName,'') AS SalesPersonName,
		ML.MarketLocationKey,ML.MarketLocation
		INTO #ContainerListData
	FROM  dbo.OrderDetail OD WITH (NOLOCK)			
		INNER JOIN dbo.OrderHeader OH WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
		INNER JOIN dbo.OrderStatus OS WITH (NOLOCK)	ON OS.[Status]=OH.[Status]
		LEFT JOIN dbo.[Broker]  BR	WITH (NOLOCK)	ON BR.BrokerKey=OH.BrokerKey
		INNER JOIN  dbo.OrderDetailStatus OSD	WITH (NOLOCK)	ON OSD.[Status] = OD.[Status]
		LEFT JOIN dbo.ContainerSize CS			WITH (NOLOCK)	ON CS.ContainerSizeKey = OD.ContainerSizeKey		
		LEFT JOIN dbo.CSR CR					WITH (NOLOCK)	ON CR.CsrKey=OH.CsrKey		
		LEFT JOIN  dbo.OrderType OT				WITH (NOLOCK)	ON OT.OrderTypeKey = OH.OrdertypeKey 
		LEFT JOIN OrderDetailStops	ODSP		WITH (NOLOCK)   ON ODSP.OrderDetailKey=OD.OrderDetailKey
												AND ODSP.StopTypeKey=1 AND ISNULL(ODSP.IsDryRunPort,0)=0
		LEFT JOIN OrderDetailStops	ODSD		WITH (NOLOCK)   ON ODSD.OrderDetailKey=OD.OrderDetailKey
												AND ODSD.StopTypeKey=3 AND ISNULL(ODSD.IsDryRunCustomer,0)=0
		LEFT JOIN OrderDetailStops	ODSRT		WITH (NOLOCK)   ON ODSRT.OrderDetailKey=OD.OrderDetailKey
												AND ODSRT.StopTypeKey=5 AND ISNULL(ODSRT.IsDryRunPort,0)=0
		--LEFT JOIN [Address] SR					WITH (NOLOCK)	ON	SR.AddrKey=OD.SourceAddrKey
		--LEFT JOIN [Address] DT					WITH (NOLOCK)	ON	DT.AddrKey=OD.DestinationAddrKey
		LEFT JOIN [Address] SR					WITH (NOLOCK)	ON	SR.AddrKey=ISNULL(ODSP.StopAddrKey,OD.SourceAddrKey)
		LEFT JOIN [Address] DT					WITH (NOLOCK)	ON	DT.AddrKey=ISNULL(ODSD.StopAddrKey,OD.DestinationAddrKey)
		LEFT JOIN [Address] BT					WITH (NOLOCK)	ON	BT.AddrKey=OH.BillToAddrKey
		--LEFT JOIN [Address] RET					WITH (NOLOCK)	ON	RET.AddrKey=OH.ReturnAddrKey
		LEFT JOIN [Address] RET					WITH (NOLOCK)	ON	RET.AddrKey=ODSRT.StopAddrKey
		LEFT JOIN  dbo.[Priority] PT			WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
		LEFT JOIN DBO.Customer CU				WITH (NOLOCK)	ON OH.CustKey = CU.CustKey
		LEFT JOIN DBO.SalesPerson SP			WITH (NOLOCK)	ON OH.SalesPersonKey = SP.SalesPersonKey
		LEFT JOIN  (SELECT MIN(PickupDateFrom) AS PickupDate , MAX(PickupDateTo) AS PickupDateTo  ,
		MIN(DeliveryDateFrom) AS DeliveryDate ,MAX(DeliveryDateTo) AS DeliveryDateTo,OrderDetailKey
					 FROM dbo.Routes WITH (NOLOCK)
					 GROUP BY OrderDetailKey
				   ) RT ON RT.OrderDetailKey=OD.OrderDetailKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
	WHERE 
		(ISNULL(@PickupDateFrom,'2002-01-01') ='2002-01-01' OR ISNULL(@PickupDateTo,'2050-01-02')='2050-01-02'
			OR RT.PickupDate  between @PickupDateFrom and @PickupDateTo 
			--OR isnull(RT.PickupDateTo, RT.PickupDate) between @PickupDateFrom and @PickupDateTo
			)
		AND (ISNULL(@DeleveryDateFrom,'2002-01-01') ='2002-01-01' OR ISNULL(@DeleveryDateTo,'2050-01-02')='2050-01-02' 
			OR RT.DeliveryDate  between @DeleveryDateFrom and @DeleveryDateTo 
			--OR isnull(RT.DeliveryDateTo, RT.DeliveryDate ) between @DeleveryDateFrom and @DeleveryDateTo
			)
		AND ( @CSRKey			IS NULL OR @CSRKey= 0 OR CR.CsrKey= @CSRKey)	
		AND ( @StatusKey		IS NULL OR @StatusKey = 0 OR OD.[Status] = @StatusKey)
		AND ( @FromOrderKey= 0 OR OH.OrderKey between @FromOrderKey and @ToOrderKey )
		AND ( isnull(@CustomerKey,0) = 0 OR @CustomerKey =OH.CustKey)
		AND (@CreatedDateFrom is null OR @CreatedDateTo is null 
			OR OH.OrderDate  between @CreatedDateFrom and @CreatedDateTo)
		AND (  ISNULL(@MarketLocationKey,0) = 0 OR  OH.MarketLocationKey = @MarketLocationKey )


		PRINT  @StatusKey;
	-- select * from #ContainerListData

	select OCT.* into #tmp1 from #ContainerListData CT
	inner join vOrderContainerTypes OCT on CT.OrderDetailkey = OCT.OrderDetailKey

	UPDATE CT SET IsTransLoad = 1
	from #ContainerListData CT
	inner join #tmp1 OCT on CT.OrderDetailkey = OCT.OrderDetailKey
	where OCT.Description like '%Transload%'

	SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,
	A.OrderDetailKey,W.RouteKey INTO #RouteLegNo
	FROM #ContainerListData A 
		INNER JOIN dbo.Routes W WITH (NOLOCK) ON W.OrderDetailKey=A.OrderDetailKey

	SELECT DISTINCT OrderDetailkey INTO #OrderDetl FROM #ContainerListData

	SELECT A.OrderDetailKey,COUNT(DISTINCT RT.RouteKey) AS LegCount INTO #LegCount
	FROM #OrderDetl A 
		LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CompletedRoutekey INTO #CompletedLeg
	FROM #OrderDetl A 
		INNER JOIN dbo.Routes RT WITH (NOLOCK)		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description]='Leg Completed'
	GROUP BY A.OrderDetailKey



	SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey INTO #CurrLeg
	FROM #OrderDetl A 
		INNER JOIN dbo.Routes RT WITH (NOLOCK)		ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK)	ON RTS.[Status]=RT.[Status]
	WHERE RTS.[Description] <> 'Leg Completed'
	GROUP BY A.OrderDetailKey

	SELECT DISTINCT A.OrderDetailKey,ISNULL(O.CurrOPenRoutekey,D.CompletedRoutekey) AS RouteKey,
			A.LegNo INTO #ContainerRoute
	FROM #RouteLegNo A 
		LEFT JOIN #CompletedLeg D ON D.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #CurrLeg O ON O.OrderDetailKey=A.OrderDetailKey

	SELECT DISTINCT A.OrderDetailKey,A.RouteKey,D.ToLocation INTO #ContainerRoute2
	FROM #ContainerRoute A 
	INNER JOIN dbo.Routes D WITH (NOLOCK) ON D.RouteKey=A.RouteKey

	SELECT A.CompletedRoutekey,K.ToLocation,A.OrderDetailKey INTO #ComplLegLocation 
	FROM #CompletedLeg A 
	INNER JOIN dbo.Routes K WITH (NOLOCK) ON K.RouteKey=A.CompletedRoutekey

	SELECT A.OrderDetailKey,R.AddrName INTO #Sourceloc
	FROM #OrderDetl A 
		INNER JOIN  dbo.OrderDetail J WITH (NOLOCK) on j.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.[Address] R WITH (NOLOCK) ON R.AddrKey=J.SourceAddrKey

	SELECT A.OrderDetailKey,'Dispatch Complete' AS CompleteStatus INTO #CompletedCont
	FROM #OrderDetl A 
		INNER JOIN dbo.OrderDetail D WITH (NOLOCK) ON D.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.OrderDetailStatus W WITH (NOLOCK) ON W.Status=D.Status
		INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
	WHERE W.[Description]='Dispatch Confirmed' AND RTS.Description='Leg Completed'
	GROUP BY A.OrderDetailKey
	--*********************Curr Location***********************
	--All Comp Leg
	SELECT OrderDetailKey INTO #AllcompLeg 
	FROM #OrderDetl 
	WHERE OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CurrLeg)

	SELECT MAX(RouteKey) AS RouteKey, A.OrderDetailKey INTO #AllComplLegdestloc 
	FROM dbo.Routes A WITH (NOLOCK)
		INNER JOIN #AllcompLeg D ON D.OrderDetailKey=A.OrderDetailKey
	GROUP BY A.OrderDetailKey

	SELECT A.OrderDetailKey,DT.AddrName AS ContCurrLocation,A.RouteKey,2 AS LocType INTO #CurrntLoc1
	FROM #AllComplLegdestloc A 
	INNER JOIN dbo.Routes RT WITH (NOLOCK)	ON RT.RouteKey=A.RouteKey
	INNER JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.AddrKey=RT.DestinationAddrKey

	--All Open
	SELECT MIN(CurrOPenRoutekey) AS RouteKey,OrderDetailKey  INTO #AllOPenLegSourLoc
	FROM #CurrLeg WHERE OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CompletedLeg)
	GROUP BY OrderDetailKey
	
	SELECT A.OrderDetailKey,DT.AddrName AS ContCurrLocation,A.RouteKey,1 AS LocType INTO #CurrntLoc2
	FROM #AllOPenLegSourLoc A 
	INNER JOIN dbo.Routes RT WITH (NOLOCK)	ON RT.RouteKey=A.RouteKey
	INNER JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.AddrKey=RT.SourceAddrKey

	-- Open/Closed leg

	SELECT A.OrderDetailKey, MAX(RT.RouteKey) AS RouteKey INTO #mixedLeg
	FROM #OrderDetl A 
		INNER JOIN dbo.Routes RT WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.RouteStatus RTS WITH (NOLOCK) ON RT.[Status]=RTS.[Status]
	WHERE A.OrderDetailKey IN ( SELECT OrderDetailKey FROM #CompletedLeg ) 
		AND A.OrderDetailKey IN ( SELECT OrderDetailKey FROM #CurrLeg )
		AND RTS.[Description]='Leg Completed'
	GROUP by A.OrderDetailKey

	SELECT A.OrderDetailKey,DT.AddrName AS ContCurrLocation,A.RouteKey,2 AS LocType INTO #CurrntLoc3
	FROM #mixedLeg A 
	INNER JOIN dbo.Routes RT WITH (NOLOCK)	ON RT.RouteKey=A.RouteKey
	INNER JOIN dbo.[Address] DT WITH (NOLOCK) ON DT.AddrKey=RT.DestinationAddrKey		

	INSERT INTO #ContCurlocation (OrderDetailKey,ContCurrLocation,RouteKey,LocationType)
	SELECT OrderDetailKey,ContCurrLocation,RouteKey,LocType FROM #CurrntLoc1
	UNION ALL
	SELECT OrderDetailKey,ContCurrLocation,RouteKey,LocType FROM #CurrntLoc2
	UNION ALL
	SELECT OrderDetailKey,ContCurrLocation,RouteKey,LocType FROM #CurrntLoc3

	--*********Open conatiner location - Source Addrname************
	SELECT A.OrderDetailKey INTO #OpenCont
	FROM #OrderDetl A  
		LEFT JOIN #ContCurlocation G ON G.OrderDetailKey=A.OrderDetailKey
	WHERE G.OrderDetailKey IS NULL

	IF ( SELECT COUNT(1) FROM #OpenCont)>0
	BEGIN
		INSERT INTO #ContCurlocation (OrderDetailKey,ContCurrLocation,RouteKey,LocationType)
		SELECT OD.OrderDetailKey,AD.AddrName AS  ContCurrLocation,MAX(R.RouteKey) ,-1
		FROM OrderDetail  OD WITH (NOLOCK)
		INNER JOIN dbo.[Address] AD WITH (NOLOCK) ON AD.AddrKey=OD.SourceAddrKey
		Left join Routes R WITH (NOLOCK) on OD.OrderDetailKey = R.OrderDetailKey
		WHERE OD.OrderDetailKey IN ( SELECT OrderDetailKey FROM #OpenCont)
		group by  OD.OrderDetailKey,AD.AddrName
	END
	--************************************************************
	SELECT A.OrderDetailKey,OH.OrderTypeKey,A.LocationType AS test1,
		CASE WHEN A.LocationType=2 THEN L.ToLocation 
			 WHEN A.LocationType=1 THEN L.FromLocation 
			 WHEN A.LocationType=-1 AND OH.OrderTypeKey=1 THEN 'Port' 
			 WHEN A.LocationType=-1 AND OH.OrderTypeKey=2 THEN 'Customer'				 
			 WHEN A.LocationType=-1 AND OH.OrderTypeKey=3 THEN 'Other'
			 END AS LocationType INTO #LocationType
	FROM #ContCurlocation A 
		INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON OD.OrderDetailKey=A.OrderDetailKey
		INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey
		LEFT JOIN dbo.Routes RT WITH (NOLOCK) ON RT.RouteKey=A.RouteKey
		LEFT JOIN dbo.Leg L WITH (NOLOCK) ON L.LegKey=RT.LegKey

	CREATE TABLE #ContType
	(
		OrderDetailKey INT,
		CommentKey	INT,
		Comment		VARCHAR(200),
		ContNo		VARCHAR(20),
		ShortCmnt	VARCHAR(10)
	)

	select distinct OrderDetailkey, ContainerNo
	INTO #TMPDATA
	from  #ContainerListData

	INSERT INTO		#ContType
	SELECT			OrderDetailKey,CommentKey,Comment,ContNo,ShortCmnt
	FROM			(SELECT			OC.orderdetailkey,OC.commentkey, C.Description,[value]  --, STRING_SPLIT(C.description,',') 
									,LTRIM(RTRIM([value])) AS 'Comment', OD.ContainerNo AS ContNo,LEFT([value],3) AS ShortCmnt
					FROM			[dbo].[Comment]  C  WITH (NOLOCK)
					CROSS APPLY		STRING_SPLIT(C.description,',')  
					INNER JOIN		[dbo].[OrderDetailComments] OC  with (NOLOCK) ON  OC.CommentKey = C.CommentKey
					INNER JOIN		#TMPDATA OD on OD.OrderDetailKey = OC.OrderDetailKey
					WHERE			C.Description NOT LIKE '<p>%' AND C.Description NOT LIKE 'Container%'
									AND LEFT(C.Description,3)IN (SELECT LEFT(TypeDescription,3) from ContainerTypes)
					) A 
	INNER JOIN		ContainerTypes CT ON A.Comment = CT.TypeID

		
	
	SELECT OrderDetailkey, Comments
       into #ContTypeData
	FROM
		(
			SELECT DISTINCT OrderDetailkey, 
				(
					SELECT C.Comment + ',' AS [text()]
					FROM #ContType C
					WHERE C.OrderDetailKey = CL.OrderDetailkey
					ORDER BY C.Comment
					FOR XML PATH (''), TYPE
				).value('text()[1]','nvarchar(max)') Comments
			FROM #ContainerListData CL
		) [Main]

	--SELECT COUNT(*) FROM #ContainerListData
	
	SET @JSONOutput=(
	SELECT TOP 500 OrderKey,A.OrderDate,A.OrderDetailkey,A.OrderTypeKey,A.OrderNo,A.CsrName,
		A.ContainerNo,A.ContainerID,A.ContainerSizeKey,A.LastFreeDay,A.PickupDate,A.PickupTime, A.PickupDateTo,
		A.DropOffDate,A.DropOffTime, A.DropOffDateTo,A.[Status],A.OrderType,A.BillOfLading,A.BookingNo,A.ContainerSize,
		A.[Priority],A.Source_AddrName,A.Source_Address1,A.Source_City,A.Source_State,A.Source_ZipCode,A.Source_Country,
		A.Destination_AddrName,A.Destination_Address1,A.Destination_City,A.Destination_State,A.Destination_ZipCode,A.Destination_Country,
		A.Customer_AddrName,A.Customer_Address1,A.Customer_City,A.Customer_State,A.Customer_ZipCode,A.Customer_Country,
		A.Return_AddrName,A.Return_Address1,A.Return_City,A.Return_State,A.Return_ZipCode,A.Return_Country,
		A.NextAction,A.custKey,A.BrokerName,A.[Weight],A.VesselName,A.SealNo,ISNULL(A.CutOffDate,'')CutOffDate,
		--ISNULL(L.LegCount,0) AS LegCount ,D.CompleteStatus,K.CompletedRoutekey,Q.ToLocation
		S.AddrName,--CASE WHEN CompleteStatus='Dispatch Complete' THEN 0 WHEN LegCount=0 THEN 0 END AS CurrLeg, 
		--CASE WHEN CompleteStatus='Dispatch Confirmed' THEN 0 ELSE ISNULL(MN.LegNo,0) END AS Currrleg,
		--ISNULL(I.ToLocation,S.AddrName) AS CurLocation,
		CL.ContCurrLocation AS CurrentLocation, CL.RouteKey,
		--K.CompletedRoutekey,--CASE WHEN K.CompletedRoutekey IS NOT NULL THEN 0 ELSE M.LegNo END AS LegNo,
		CAST(ISNULL(MN.legNo,0) AS VARCHAR(10))+' [ '+ISNULL(CAST(MN.legNo AS VARCHAR(10)),0)+' of '+CAST(L.LegCount AS VARCHAR(10))+' ]' AS CurrentLeg
		,W.LocationType,isnull(CDC.DocumentCount,0) as DocumentCount
		, IsEmpty, A.IsTMF, A.DriverNotes, A.SchedulerNotes ,
		ISNULL(CASE WHEN CT.Comments LIKE '%Haz,%' then 1 else 0 end ,0) AS IsHazardous,
		--ISNULL(CAST(MN.legNo AS VARCHAR(10)),0)+' of '+CAST(L.LegCount AS VARCHAR(10)) AS CurLeg
		--CASE WHEN L.LegCount = 0 THEN '0 of 0'
		--WHEN  L.LegCount >0 THEN CAST(CASE WHEN A.[Status]='Dispatch Confirmed' THEN 0 
		--ELSE (CASE WHEN CompleteStatus='Dispatch Confirmed' THEN 0 ELSE ISNULL(MN.LegNo,0) END) END AS VARCHAR(50)) +' of '+ CAST(LegCount AS VARCHAR(50)) END AS CurLeg
		 isTransLoad
		, A.CustID, A.CustName, A.BrokerRefNo, A.VesselETA
		, convert(varchar,A.WeightUnit) as WeightUnit
		--, isnull(ct.Comments,'') ShortComment
		, SalesPersonName,A.MarketLocationKey,A.MarketLocation,
		ContainerProperties=ISNULL(STUFF((
			SELECT ',' + TypeID
			FROM ContainerTypesLink CTLI WITH (NOLOCK) 
			INNER JOIN ContainerTypes CTI  WITH (NOLOCK) ON CTI.ContainerTypeKey=CTLI.ContainerTypeKey
			WHERE CTLI.OrderDetailKey=A.OrderDetailkey
			FOR XML PATH('')
			), 1, 1, ''),''),
		HazardClasses=ISNULL(STUFF((
			SELECT ',' + Description
			FROM HazardClassesLink HCL
			INNER JOIN Container_HazardClasses CHC ON CHC.ClassKey=HCL.ClassKey
			WHERE HCL.OrderDetailKey=A.OrderDetailkey
			ORDER BY Description
			FOR XML PATH('')
		), 1, 1, ''),'')
		FROM #ContainerListData A 
		LEFT JOIN #LegCount L			ON L.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #CompletedLeg K		ON K.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #ComplLegLocation Q	ON Q.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #Sourceloc S			ON S.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #CompletedCont D		ON D.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #ContainerRoute2 I	ON I.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #RouteLegNo M			ON M.RouteKey=I.RouteKey
		LEFT JOIN #CurrLeg V			ON V.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #RouteLegNo MN		ON MN.RouteKey=V.CurrOPenRoutekey
		LEFT JOIN #ContCurlocation CL ON CL.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #LocationType W ON W.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN #ContTypeData CT ON		A.OrderDetailkey = CT.OrderDetailKey
		--LEFT JOIN #HazCont H ON H.OrderDetailKey=A.OrderDetailKey
		LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON a.OrderDetailKey = CDC.OrderDetailKey
		order by A.orderNo
		FOR JSON PATH
		)

		SELECT @JSONOutput AS JSONOutput 
		
		SET @Status = 1
		SET @Reason = 'Success'
		
END