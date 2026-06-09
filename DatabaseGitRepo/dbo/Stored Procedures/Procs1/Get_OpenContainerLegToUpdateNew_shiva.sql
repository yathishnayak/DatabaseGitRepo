
--  MSKU123457
-- [Get_OpenContainerLegToUpdateNew_shiva] @SearchText = 'TRHU4640350'
--   [Get_OpenContainerLegToUpdateNew_shiva]
--[Get_OpenContainerLegToUpdateNew_shiva] @Customer='', @OrderNo = '', @ContainerNo='', @PickUpDateFrom = '2020-08-01', @PickUpDateTo = '2022-09-07'
CREATE PROCEDURE [dbo].[Get_OpenContainerLegToUpdateNew_shiva] 
	@Customer		VARCHAR(50)='',
	@OrderNo		VARCHAR(20)='',
	@ContainerNo	VARCHAR(20)='',
	@PickUpDateFrom	DATE='01/01/2020',
	@PickUpDateTo	DATE='12/31/2099',
	@PickupTypeKey  SMALLINT=0,
	@PageNo				INT = 1,
	@PageSize			INT	= 10,
	@SortField			varchar(50) = 'FinalDestination',
	@IsAscending		bit = 1,
	@CreatedUSer		varchar(50) = '',
	@SearchText			varchar(200) = ''
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT
	DECLARE @StartDate		DATETIME
	DECLARE @EndDate		DATETIME
	DECLARE @PickUpFrom		VARCHAR(50)
	DECLARE @ContCmnt       VARCHAR(2000)
	DECLARE @RouteCompletedStatus	int = 0

	select status as StatusKey
	into #StatusKey
	from OrderDetailStatus  with (nolock)
	where Description in ('Schedule Confirmed','Dispatch InProgress','Dispatch OnHold', 'Dispatch Confirmed','Approved for Invoice/Driver Pay' ) 

	select @RouteCompletedStatus = Status
	from RouteStatus with (nolock)
	where Description = 'Leg Completed'

	SET @StartDate=CAST(GETDATE() AS DATE)
	SET @EndDate=DATEADD(SECOND,59,DATEADD(MINUTE,59,DATEADD(hh,23,DATEADD(DD,6,@StartDate))))
	SET @PickUpFrom= ( SELECT PickUpType from PickUpType WHERE PickupTypeKey=@PickupTypeKey)

	CREATE TABLE #ContainerListData
	(
	ContainerNo VARCHAR(50),
	OrderType VARCHAR(50),
	DropOffDate DATE,
	Origin VARCHAR(400),
	FinalDestination VARCHAR(400),
	OrderDetailKey INT,
	OrderKey INT,
	OrderNo VARCHAR(50),
	CustName VARCHAR(400),
	StatusName VARCHAR(50),
	ReadytoRelease BIT,
	BookingNo VARCHAR(50),
	CustAddress VARCHAR(2000),
	OrderTypeKey  SMALLINT,
	S_AddrName  VARCHAR(255),S_Address1  VARCHAR(255),S_City  VARCHAR(80),S_State  VARCHAR(50),S_ZipCode VARCHAR(100),S_Country  VARCHAR(50)
	,D_AddrName  VARCHAR(255),D_Address1  VARCHAR(255),D_City  VARCHAR(80),D_State  VARCHAR(50),D_ZipCode  VARCHAR(100),D_Country  VARCHAR(50)
	,PickupDateFrom  SMALLDATETIME
	,PickupDateTo SMALLDATETIME
	, IsEmpty Bit
	, PickUpType VARCHAR(20)
	,ContainerSize VARCHAR(50)	
	, RouteKey	int
	)
	create  index #ContainerListDataIndexOrderDetailKey on #ContainerListData (OrderDetailKey)
	


	CREATE TABLE #CurrLeg
	(
		OrderDetailKey INT,
		Routekey INT,
		PickupType	varchar(20)
	)
	create  index #CurrLegIndexComb on #CurrLeg (OrderDetailKey, RouteKey)

	CREATE TABLE #AllOrdComplLeg
	(
		OrderDetailKey INT,
		LastRoutekey   INT,
	)
	create  index #AllOrdComplLegIndexComb on #AllOrdComplLeg (OrderDetailKey, LastRoutekey)

	CREATE Table #ContainerStatus
	(
		StatusName VARCHAR(50),
		RouteKey INT,
		OrderDetailKey INT
	)
	create  index #ContainerStatusIndexComb on #ContainerStatus (OrderDetailKey, RouteKey)

	CREATE Table #Status
	(
		StatusKey INT
	)

	CREATE Table #ContainerTypeList
	(
		orderdetailkey INT, commentkey INT, Comment varchar(max)
	)

	CREATE Table #ContainerTypes
	(
		orderdetailkey INT, commentkey INT, Comment varchar(max), id int
	)

	CREATE Table #ContainerTypesFinal
	(
		orderdetailkey INT
	)

	TRUNCATE TABLE #Status
	TRUNCATE TABLE #ContainerStatus
	TRUNCATE TABLE #ContainerTypes
	TRUNCATE TABLE #ContainerTypeList
	TRUNCATE TABLE #ContainerTypesFinal

	SELECT RT.Status, RT.[Description] AS StatusName 
	INTO #StatusName
	FROM dbo.RouteStatus RT   with (nolock)
	where RT.IsActive = 1

	
	SELECT OD.ContainerNo, OT.OrderType ,OD.DropOffDate,
		SR.AddrName AS Origin,DT.AddrName AS FinalDestination,
		SR.AddrName AS S_AddrName,SR.Address1 AS S_Address1,SR.City AS S_City,SR.[State] AS S_State,
		SR.ZipCode AS S_ZipCode,SR.Country AS S_Country,
		DT.AddrName AS D_AddrName,DT.Address1 AS D_Address1,DT.City AS D_City,DT.[State] AS D_State,
		DT.ZipCode AS D_ZipCode,DT.Country AS D_Country,
		L.LegNo,L.[LegID],RT.PickupDateFrom 
		,RT.PickupDateTo
		,RT.SwitchTo,
		RT.DeliveryDateFrom AS DeliveryDate ,SRR.City AS FromLocation,DTR.city AS ToLocation,	
		ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,RT.ChassisNo,RT.ChassisType,
		RT.ActualDeparture AS ActualPickup,RT.ActualArrival AS ActualDelDate,
		CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  DATENAME(DW,RT.PickupDateFrom ) 
		WHEN RT.PickupDateFrom<@StartDate THEN 'Past'ELSE 'Future' END AS [WeekDay],
		CONVERT(VARCHAR(10), CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, RT.PickupDateFrom), 0) AS TIME),0) AS PickupTime,
		DR.DriverKey, RT.RouteKey,OD.OrderDetailKey,OD.OrderKey, RTS.[Description] AS StatusName, 
		RT.[Status] AS StatusKey, OH.OrderNo, CUS.CustName,OH.BookingNo,
		ISNULL(CAdr.Address1,'')+', '+ISNULL(CAdr.City,'')+', '+
		ISNULL(CAdr.State,'')+', '+ISNULL(CAdr.ZipCode,'')+', '+ISNULL(CAdr.Country,'') AS CustAddress	,
		OT.OrderTypeKey, isnull(OD.IsEmpty,0) as IsEmpty,
		 '' as PickUpType,S.[Description] AS ContainerSize
		INTO #DispatchData1
	FROM dbo.OrderDetail OD   WITH (NOLOCK) 
		INNER JOIN  dbo.OrderHeader OH	  WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey
		INNER JOIN  dbo.Customer CUS	  WITH (NOLOCK) ON CUS.CustKey=OH.CustKey
		INNER JOIN  dbo.OrderType OT	  WITH (NOLOCK) ON OT.OrderTypeKey=OH.OrderTypeKey
		INNER JOIN  dbo.[Routes] RT		  WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN  dbo.Leg L			  WITH (NOLOCK) ON RT.LegKey=L.LegKey
		INNER JOIN  dbo.LegType LT		  WITH (NOLOCK) ON LT.LegtypeKey=L.LegTypeKey
		INNER JOIN  dbo.RouteStatus RTS   WITH (NOLOCK) ON RTS.[Status]=RT.[Status]	
		LEFT JOIN   dbo.[Address] CAdr	  WITH (NOLOCK) ON CAdr.Addrkey=OH.BillToAddrKey
		LEFT JOIN   dbo.[Address] SRR	  WITH (NOLOCK) ON SRR.Addrkey=RT.SourceAddrkey
		LEFT JOIN   dbo.[Address] DTR	  WITH (NOLOCK) ON DTR.Addrkey=RT.DestinationAddrkey
		LEFT JOIN   dbo.[Address] SR	  WITH (NOLOCK) ON SR.Addrkey=OD.SourceAddrKey
		LEFT JOIN   dbo.[Address] DT	  WITH (NOLOCK) ON DT.Addrkey=OD.DestinationAddrKey
		LEFT JOIN   dbo.Driver DR		  WITH (NOLOCK) ON DR.DriverKey=RT.DriverKey
		LEFT JOIN   dbo.Chassis CH		  WITH (NOLOCK) ON CH.chassisKey=RT.ChassisKey	
		--LEFT JOIN   dbo.OrderDetailStatus ODS   WITH (NOLOCK) ON ODS.[Status]=OD.[Status]
		LEFT JOIN   dbo.ContainerSize S	  WITH (NOLOCK) ON S.ContainerSizeKey=OD.ContainerSizeKey	
		INNER JOIN #StatusKey SK ON OD.Status = SK.StatusKey
	WHERE 1=1
		AND	(@PickUpDateFrom	IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)
		AND (@PickUpDateTo		IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)		
	
		--********************************************************************************************

		SELECT OrderDetailKey, StatusKey,StatusName,LegNo,RouteKey,DriverKey 
		INTO #OrderStautsbyLeg
		FROM #DispatchData1
		ORDER BY OrderDetailKey,LegNo

		create NONCLUSTERED index #OrderStautsbyLegIndexODKey on  #OrderStautsbyLeg (OrderDetailKey)
		create NONCLUSTERED index #OrderStautsbyLegIndexRoutKey on  #OrderStautsbyLeg ( RouteKey)
				
		select OrderDetailKey, count(StatusName) as NoOfStatus 
		INTO #OrderStatusCount
		from (
		select distinct Orderdetailkey, StatusName from #OrderStautsbyLeg
		) a Group by OrderDetailKey

		INSERT INTO #ContainerStatus (StatusName, RouteKey,OrderDetailKey)
		select distinct StatusName, max(Routekey), A.OrderDetailKey 
		from #OrderStatusCount A
		inner join #OrderStautsbyLeg B on A.OrderDetailKey = B.OrderDetailKey
		where NoOfStatus = 1 and B.StatusKey = @RouteCompletedStatus --B.StatusName = 'Leg Completed'
		group by StatusName, A.OrderDetailKey

		INSERT INTO #ContainerStatus (StatusName, RouteKey,OrderDetailKey)
		select distinct '', min(Routekey), A.OrderDetailKey 
		from #OrderStatusCount A
		inner join #OrderStautsbyLeg B on A.OrderDetailKey = B.OrderDetailKey
		where NoOfStatus > 1 and  B.StatusKey <> @RouteCompletedStatus -- B.StatusName <> 'Leg Completed'
		group by  A.OrderDetailKey

		INSERT INTO #ContainerStatus (StatusName, RouteKey,OrderDetailKey)
		select distinct StatusName, min(Routekey), A.OrderDetailKey 
		from #OrderStatusCount A
		inner join #OrderStautsbyLeg B on A.OrderDetailKey = B.OrderDetailKey
		where NoOfStatus = 1 and  B.StatusKey <> @RouteCompletedStatus --B.StatusName <> 'Leg Completed'
		group by StatusName, A.OrderDetailKey

		UPDATE A
		SET A.StatusName= F.StatusName		
		FROM #ContainerStatus A 
		INNER JOIN #OrderStautsbyLeg F ON F.RouteKey=A.RouteKey			   
	
		UPDATE A
		SET A.StatusName=S.StatusName,A.PickUpDateFrom=D.PickupDateFrom
		FROM #DispatchData1 A 
			LEFT JOIN #ContainerStatus S ON S.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN #DispatchData1 D ON D.RouteKey=S.RouteKey


		UPDATE #DispatchData1
		SET [WeekDay]=  CASE WHEN PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  DATENAME(DW,PickupDateFrom ) 
						WHEN PickupDateFrom<@StartDate THEN 'Past'ELSE 'Future' END	
	
	--***********************************************************
		SELECT DISTINCT CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, ContainerPickUpTime), 0) AS TIME),0) AS ContainerPickUpTime,
		ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,		
			A.OrderDetailKey,OrderKey,OrderNo,CustName,	StatusName,			
			dbo.FN_IsOrderDetailComplete(A.OrderDetailKey) as ReadytoRelease, 
			BookingNo,
			CustAddress , OrderTypeKey 
			,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize
			, A.StatusKey, A.RouteKey
		into #DispatchDataFinal
		from (
		SELECT top 1000000
			ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,LegNo,LegID,PickupDateFrom,PickupDateTo,SwitchTo,DeliveryDate
			,FromLocation,ToLocation,DriverName,ChassisNo,ChassisType,ActualPickup,ActualDelDate,
			PickupTime,			
			DriverKey,RouteKey,OrderDetailKey,OrderKey,StatusName,StatusKey,OrderNo,CustName,
			MIN(PickupDateFrom) OVER( PARTITION BY OrderDetailKey Order by OrderDetailKey ) AS ContainerPickUpTime
			,BookingNo
			,CustAddress, OrderTypeKey 
			,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country , IsEmpty, PickUpType,ContainerSize
			--INTO #DispatchData
		FROM #DispatchData1
		ORDER BY [WeekDay],OrderKey,OrderDetailKey
		) a
		

		/*

		SELECT DISTINCT OrderDetailKey INTO #IncompleteCont
		FROM #DispatchData 
		WHERE ISNULL(ChassisNo ,'')='' OR ISNULL(DriverName,'')='' OR ActualDelDate IS NULL		
		*/


		/*
		SELECT DISTINCT CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, ContainerPickUpTime), 0) AS TIME),0) AS ContainerPickUpTime,
			ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,		
			A.OrderDetailKey,OrderKey,OrderNo,CustName,	StatusName,			
			dbo.FN_IsOrderDetailComplete(A.OrderDetailKey) as ReadytoRelease, 
			BookingNo,
			CustAddress , OrderTypeKey 
			,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize
			, A.StatusKey, A.RouteKey
			INTO #DispatchDataFinal
		FROM #DispatchData A			
		--	LEFT JOIN #IncompleteCont IT ON IT.OrderDetailKey=A.OrderDetailKey	
	*/

	create NONCLUSTERED index #DispatchDataFinalIndexOrderDetailKey on #DispatchDataFinal (OrderDetailKey)
	create NONCLUSTERED index #DispatchDataFinalIndexStatus on #DispatchDataFinal (StatusKey)
	

	IF (SELECT COUNT(1) FROM #ContainerTypesFinal)=0 AND (SELECT COUNT(1) FROM #StatusName )<> 0
	BEGIN
		INSERT INTO #ContainerListData 
		(
		ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
		OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	, ReadytoRelease, BookingNo,CustAddress, OrderTypeKey
		,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize, RouteKey
		)
		SELECT	ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
				OrderDetailKey,OrderKey,OrderNo,CustName,A.StatusName	,			
				ReadytoRelease,BookingNo,
				CustAddress, OrderTypeKey 
				,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
				,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country
				, IsEmpty, PickUpType,ContainerSize, RouteKey
		FROM #DispatchDataFinal A	
		inner join #StatusName B on A.StatusKey = B.Status
	END

	IF (SELECT COUNT(1) FROM #ContainerTypesFinal)<> 0 AND (SELECT COUNT(1) FROM #StatusName )<> 0
	BEGIN
		INSERT INTO #ContainerListData
		(
		ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
		OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	, ReadytoRelease, BookingNo,CustAddress, OrderTypeKey
		,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty	, PickUpType,ContainerSize, RouteKey
		)
		SELECT	ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
				A.OrderDetailKey,OrderKey,OrderNo,CustName,A.StatusName	,			
				ReadytoRelease,BookingNo,
				CustAddress, OrderTypeKey
				,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
				,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize, RouteKey
		FROM #DispatchDataFinal	A
		inner join #StatusName B on A.StatusKey = B.Status
		inner join #ContainerTypesFinal C on A.OrderDetailKey = C.orderdetailkey
		
	END

	IF (SELECT COUNT(1) FROM #ContainerTypesFinal)<> 0 AND (SELECT COUNT(1) FROM #StatusName ) = 0
	BEGIN	
		INSERT INTO #ContainerListData
		(
		ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
		OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	, ReadytoRelease, BookingNo,CustAddress, OrderTypeKey
		,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize, RouteKey
		)
		SELECT	ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
				A.OrderDetailKey,OrderKey,OrderNo,CustName,A.StatusName	,			
				ReadytoRelease, BookingNo,
				CustAddress, OrderTypeKey 
				,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
				,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country	
				, IsEmpty, PickUpType,ContainerSize, RouteKey
		FROM #DispatchDataFinal A
		inner join #StatusName B on A.StatusKey = B.Status
		inner join #ContainerTypesFinal C on A.OrderDetailKey = C.orderdetailkey
		
	END

		--***********************************************************************************
		/*
		SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY A.Routekey) AS LegNo,
			A.OrderDetailKey,W.RouteKey,RS.[Description] AS StatusDesc INTO #RouteLegNo
		FROM #ContainerListData A 
			INNER JOIN dbo.Routes W   WITH (NOLOCK) ON W.OrderDetailKey=A.OrderDetailKey
			INNER JOIN dbo.RouteStatus RS   WITH (NOLOCK) ON RS.Status=W.Status
		*/

		SELECT DISTINCT OrderDetailkey INTO #OrderDetl FROM #ContainerListData		

		SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
		FROM #OrderDetl A 
			LEFT JOIN dbo.Routes RT   WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
		GROUP BY A.OrderDetailKey
		create NONCLUSTERED index #LegCountIndex on #LegCount (OrderDetailKey)
		
		INSERT INTO #CurrLeg (OrderDetailKey,Routekey)
		SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
		FROM #OrderDetl A 
			INNER JOIN dbo.Routes RT		  WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
		WHERE  RT.Status <> @RouteCompletedStatus
		GROUP BY A.OrderDetailKey		

		SELECT OrderDetailKey INTO #AllOrdCompLeg 
		FROM #OrderDetl 
		WHERE OrderDetailKey NOT IN ( SELECT OrderDetailKey FROM #CurrLeg)

		INSERT INTO #AllOrdComplLeg (OrderDetailKey,LastRoutekey)
		SELECT OrderDetailKey,Routekey 
		FROM #CurrLeg

		INSERT INTO #CurrLeg (OrderDetailKey,Routekey)
		SELECT A.OrderDetailKey,ISNULL(MAX(RT.RouteKey),0) AS CurrOPenRoutekey
		FROM #AllOrdCompLeg A 
			INNER JOIN dbo.Routes RT   WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey		
		GROUP BY A.OrderDetailKey

		UPDATE A SET PickupType = PT.PickUpType
		--select *
		from #CurrLeg A
			Left join Routes RT   WITH (NOLOCK) on A.Routekey = RT.RouteKey
			Left Join dbo.Leg L   WITH (NOLOCK) on RT.LegKey = L.LegKey
			Left join dbo.PickUpType PT   WITH (NOLOCK) on L.PickupTypeKey = PT.PickupTypeKey

		
		SELECT ShortComment,orderdetailkey,Comment INTO #ContTypes
		FROM (
				SELECT 
						OC.orderdetailkey,[value] as 'Comment',LEFT([value],3) AS ShortComment
				FROM [dbo].[Comment] C    WITH (NOLOCK) 
					CROSS APPLY STRING_SPLIT(C.[description],',')  
					INNER JOIN 
						[dbo].[OrderDetailComments] OC     WITH (NOLOCK) ON   OC.CommentKey = C.CommentKey					
				WHERE OC.OrderDetailKey IN 	( SELECT OrderDetailKey FROM #ContainerListData )
			) A 
		INNER JOIN ContainerTypes CT   WITH (NOLOCK) ON A.Comment = CT.TypeID	
		
		--******************Hazmat Container********************
		SELECT DISTINCT CL.OrderDetailKey,1 AS IsHazmat INTO #HazCont 
		FROM #ContainerListData  CL
		--INNER JOIN dbo.vOrderContainerTypes OCT on CL.OrderDetailKey = OCT.OrderDetailKey
		--where Description like '%Hazard%'
		inner join 	(
			 SELECT orderdetailkey FROM #ContTypes WHERE Comment='Hazard'
			) HZ ON CL.OrderDetailKey=HZ.OrderDetailKey	
		--*******************************************************


		SELECT	isnull(ContainerNo,'') as ContainerNo,
				isnull(DropOffDate,'01-01-1900') as DropOffDate,
				isnull(D.AddrName,'') as FinalDestination,
				isnull(A.OrderDetailKey,0) as OrderDetailKey,
				isnull(A.OrderKey,0) as OrderKey,
				isnull(OrderType,'') as OrderType,
				isnull(S.AddrName,'') as Origin,
				isnull(StatusName,'') as StatusName,
				isnull(OrderNo,'') as OrderNo,
				isnull(CustName,'') as CustName,
				isnull(R.ScheduledPickupDate,'01-01-1900') as ContainerTime,
				isnull(ReadyToRelease,convert(bit,0)) as ReadyToRelease,
				isnull(BookingNo,'') as BookingNo,
				convert(bit,0) as IsRowHidden,
				isnull(CustAddress,'') as CustAddress,
				isnull(OrderTypeKey,0) as OrderTypeKey,
				isnull(I.DriverKey,0) as DriverKey,
				isnull(I.DriverID + ' : ' + I.FirstName+' '+ISNULL(I.LastName,''),'') as DriverName,
				isnull(S.AddrName,'') as FromLocation,
				isnull(D.AddrName ,'') as ToLocation,
				convert(datetime,isnull(R.ScheduledPickupDate,'01-01-1900')) as ScheduledPickupDate,
				convert(datetime,isnull(R.ScheduledArrival,'01-01-1900')) as ScheduledArrival,

				isnull(R.RouteKey,0) as RouteKey,
				convert(bigint, Isnull(ISNULL(R.LegNo,1),1))  as LegNo,
				isnull(H.IsHazmat,convert(bit,0)) as IsHazmat,
				isnull(S.Address1,'') as S_Address1,
				isnull(S.City,'') as S_City,
				isnull(S.State,'') as S_State,
				isnull(S.Country,'') as S_Country,
				isnull(S.ZipCode,'') as S_ZipCode,
				isnull(D.Address1,'') as D_Address1,
				isnull(D.City,'') as D_City,
				isnull(D.State,'') as D_State,
				isnull(D.Country,'') as D_Country,
				isnull(D.ZipCode,'') as D_ZipCode,
				convert(datetime,isnull(R.PickupDateFrom,'01-01-1900')) as PickupDateFrom,
				convert(datetime,isnull(R.PickupDateTo,'01-01-1900')) as PickupDateTo,
				isnull(CDC.DocumentCount,0) as DocumentCount,
				isnull(A.IsEmpty,convert(bit,0)) as IsEmpty,
				isnull(Q.PickupType,'') as PickupType,
				DATEDIFF(HH,getdate(),convert(datetime,isnull(ScheduledPickupDate,getdate()))) as DelayHours,
				isnull(ContainerSize,'') as ContainerSize,
				case when ScheduledPickupDate is null then 'NA' 
				 when DATEPART(HH,ScheduledPickupDate) >=18 OR DATEPART(HH,ScheduledPickupDate) <= 2 then 'Night'
				 else 'Day' end as DayNightIndicator,
				convert(varchar(100),'') as Scheduled_DateTime
			,CAST(ISNULL(R.LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50)) AS CurLeg
			
			
			, ContainerTypes= '' -- OCT.Description
			--STUFF(( 
			--	SELECT ', '+ShortComment 
			--	FROM #ContTypes 
			--	WHERE OrderDetailKey=A.OrderDetailKey
			--	FOR XML PATH('')), 1, 2, '')
		into #tempOutput
		FROM #ContainerListData A 
			INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=A.OrderDetailKey and Q.Routekey = A.RouteKey
			INNER JOIN dbo.Routes R   WITH (NOLOCK) ON R.RouteKey=Q.Routekey
			INNER JOIN #LegCount L ON L.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN dbo.[Address] S   WITH (NOLOCK) ON S.AddrKey=R.SourceAddrKey
			LEFT JOIN dbo.[Address] D   WITH (NOLOCK) ON D.AddrKey=R.DestinationAddrKey
			LEFT JOIN dbo.Driver I		WITH (NOLOCK) ON I.DriverKey=R.DriverKey
			LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN #HazCont H ON H.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN dbo.ContainerDocumentCount CDC   WITH (NOLOCK) ON A.OrderDetailKey = CDC.OrderDetailKey
		--	Left join #RouteLegNo RL WITH  (NOLOCK) ON A.OrderDetailKey = RL.OrderDetailKey AND A.RouteKey = RL.RouteKey
		--	Left Join vOrderContainerTypes OCT with (nolock) on A.OrderDetailKey = OCT.OrderDetailKey
		where 1=1 and (ISNULL(@SearchText,'') = '' OR
				A.ContainerNo like '%' + @SearchText + '%' OR
				A.OrderType  like '%' + @SearchText + '%' OR
				S.AddrName  like '%' + @SearchText + '%' OR
				D.AddrName  like '%' + @SearchText + '%' OR
				A.OrderNo  like '%' + @SearchText + '%' OR
				A.StatusName  like '%' + @SearchText + '%'  OR
				A.BookingNo like '%' + @SearchText + '%' )
		ORDER BY ScheduledPickupDate , ContainerNo
		--************************************************************************************
		
		Declare @cnt int = 0	
		select @cnt = count(1) from #tempOutput
	
		
		--select *, 0 as RecCount  from #FinalOutput
		DECLARE @STRSQL VARCHAR(MAX)

		SET @STRSQL = '
		SELECT *, ' + convert(Varchar,@cnt) + ' as RecCount  FROM (
			select top 1000000 *, ROW_NUMBER() Over(Order by ' + @SortField  + ' ) RowNum
			from #tempOutput  
			ORDER BY ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' 
		) a
		where ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))

		PRINT (@STRSQL)
		EXEC (@STRSQL)
END
