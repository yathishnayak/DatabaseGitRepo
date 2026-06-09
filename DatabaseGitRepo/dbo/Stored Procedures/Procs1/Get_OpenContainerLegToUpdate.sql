
--  MSKU123457
-- [Get_OpenContainerLegToUpdate] @ContainerNo = 'SHIV1111120'
--   [Get_ContainerDispatchDetailSearch] @Status = '1'
--Get_ContainerDispatchDetailSearch_test @Weekday ='', @Customer='', @OrderNo = '', @ContainerNo='ashu4444444', @LegType = '', @Status='', @ContainerType='',@PickUpDateFrom = '2020-08-01', @PickUpDateTo = '2020-09-07'
CREATE PROCEDURE [dbo].[Get_OpenContainerLegToUpdate] 
@Customer		VARCHAR(50)='',
@OrderNo		VARCHAR(20)='',
@ContainerNo	VARCHAR(20)='',
@PickUpDateFrom	DATE='01/01/2020',
@PickUpDateTo	DATE='12/31/2099',
@PickupTypeKey  SMALLINT=0
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT
	DECLARE @StartDate		DATETIME
	DECLARE @EndDate		DATETIME
	DECLARE @PickUpFrom		VARCHAR(50)
	DECLARE @ContCmnt       VARCHAR(2000)

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

	)

	CREATE TABLE #CurrLeg
	(
		OrderDetailKey INT,
		Routekey INT,
		PickupType	varchar(20)
	)

	CREATE TABLE #AllOrdComplLeg
	(
		OrderDetailKey INT,
		LastRoutekey   INT,
	)

	CREATE Table #ContainerStatus
	(
		StatusName VARCHAR(50),
		RouteKey INT,
		OrderDetailKey INT
	)

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

	
	INSERT INTO #ContainerTypeList(orderdetailkey, commentkey, Comment) 
	SELECT 
		OC.orderdetailkey,OC.commentkey,[value] as 'Comment'
	FROM [dbo].[Comment] C  WITH (NOLOCK) 
		CROSS APPLY string_split(C.description,',')  
	INNER JOIN 
		[dbo].[OrderDetailComments] OC   ON  OC.CommentKey = C.CommentKey;


	INSERT INTO #ContainerTypes (orderdetailkey, commentkey, Comment,id) 
	SELECT CTL.*, CT.ContainerTypeKey 
	FROM 
		#ContainerTypeList CTL 
	INNER JOIN  [dbo].[ContainerTypes] CT   WITH (NOLOCK) ON CT.TypeID = CTL.comment

	IF (SELECT COUNT(1) FROM #Status)=0
	BEGIN
		INSERT INTO #Status (StatusKey)
		SELECT [Status] FROM dbo.RouteStatus    WITH (NOLOCK) where IsActive=1 
	END

	SELECT RT.[Description] AS StatusName INTO #StatusName
	FROM #Status A 
	INNER JOIN dbo.RouteStatus RT   WITH (NOLOCK) ON RT.[Status]=A.StatusKey

	SELECT OD.ContainerNo, OT.OrderType ,OD.DropOffDate,
		SR.AddrName AS Origin,DT.AddrName AS FinalDestination,
		SR.AddrName AS S_AddrName,SR.Address1 AS S_Address1,SR.City AS S_City,SR.[State] AS S_State,SR.ZipCode AS S_ZipCode,SR.Country AS S_Country,
		DT.AddrName AS D_AddrName,DT.Address1 AS D_Address1,DT.City AS D_City,DT.[State] AS D_State,DT.ZipCode AS D_ZipCode,DT.Country AS D_Country,
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
	FROM OrderDetail OD   WITH (NOLOCK) 
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
		LEFT JOIN   dbo.OrderDetailStatus ODS   WITH (NOLOCK) ON ODS.[Status]=OD.[Status]
		LEFT JOIN   dbo.ContainerSize S	  WITH (NOLOCK) ON S.ContainerSizeKey=OD.ContainerSizeKey		
	WHERE ( ODS.[Description] IN ('Schedule Confirmed','Dispatch InProgress','Dispatch OnHold', 'Dispatch Confirmed') )	
		
		AND (@Customer IS NULL OR @Customer='' OR CUS.CustName LIKE '%' + @Customer + '%')
		AND (@OrderNo  IS NULL OR @OrderNo=''  OR OH.OrderNo LIKE '%' + @OrderNo + '%')
		AND (@ContainerNo  IS NULL OR @ContainerNo=''  OR OD.ContainerNo LIKE '%' + @ContainerNo + '%')
		AND	(@PickUpDateFrom	IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)
		AND (@PickUpDateTo		IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)		
		AND (@PickupTypeKey		IS NULL OR @PickupTypeKey=0	OR L.PickupTypeKey = @PickupTypeKey)		
		--********************************************************************************************
		

		SELECT OrderDetailKey,StatusName,LegNo,RouteKey,DriverKey INTO #OrderStautsbyLeg
		FROM #DispatchData1
		ORDER BY OrderDetailKey,LegNo
				
		SELECT DISTINCT OrderDetailKey INTO #OrdeDtlKey FROM #OrderStautsbyLeg		

		WHILE ( SELECT COUNT(1) FROM #OrdeDtlKey )>0
		BEGIN
				SET @OrderDetailKey=0
				SET @OrderDetailKey= ( SELECT TOP 1 OrderDetailKey FROM #OrdeDtlKey ORDER BY OrderDetailKey )				
				
				IF (	SELECT COUNT(1) 
						FROM
						(
							SELECT COUNT(1) AS Cnt FROM #OrderStautsbyLeg 
							WHERE OrderDetailKey=@OrderDetailKey 
							GROUP BY StatusName
						)R
				 )=1
				BEGIN	
					IF ( SELECT COUNT(1) FROM #OrderStautsbyLeg WHERE OrderDetailKey=@OrderDetailKey AND StatusName='Completed' )>0
					BEGIN					
						INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
						SELECT StatusName,MAX(RouteKey) AS RouteKey ,@OrderDetailKey
						FROM #OrderStautsbyLeg 
						WHERE OrderDetailKey=@OrderDetailKey
						GROUP BY StatusName
					END
					ELSE
					BEGIN					
						INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
						SELECT StatusName,MIN(RouteKey) AS RouteKey ,@OrderDetailKey
						FROM #OrderStautsbyLeg 
						WHERE OrderDetailKey=@OrderDetailKey
						GROUP BY StatusName
					END
				END
				ELSE				
				BEGIN					
					INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
					SELECT NULL,MIN(RouteKey) AS RouteKey,@OrderDetailKey 
					FROM #OrderStautsbyLeg 
					WHERE StatusName<>'Leg Completed' AND OrderDetailKey=@OrderDetailKey		
				END			
			DELETE FROM #OrdeDtlKey WHERE OrderDetailKey=@OrderDetailKey
		END
		
		UPDATE A
		SET A.StatusName= F.StatusName		
		FROM #ContainerStatus A 
		INNER JOIN #OrderStautsbyLeg F ON F.RouteKey=A.RouteKey			   
	
		UPDATE A
		SET A.StatusName=S.StatusName,A.PickUpDateFrom=D.PickupDateFrom
		FROM #DispatchData1 A 
			LEFT JOIN #ContainerStatus S ON S.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN #DispatchData1 D ON D.RouteKey=S.RouteKey

		--UPDATE #DispatchData1
		--SET PickupDateFrom=NULL,[WeekDay]=NULL		
		--WHERE StatusName='Ready To Complete'

		--UPDATE #DispatchData1
		--SET StatusName='Ready To Complete'
		--WHERE StatusName='Leg Completed'

		UPDATE #DispatchData1
		SET [WeekDay]=  CASE WHEN PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  DATENAME(DW,PickupDateFrom ) 
						WHEN PickupDateFrom<@StartDate THEN 'Past'ELSE 'Future' END	
	
	--***********************************************************
		SELECT 
			ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,LegNo,LegID,PickupDateFrom,PickupDateTo,SwitchTo,DeliveryDate
			,FromLocation,ToLocation,DriverName,ChassisNo,ChassisType,ActualPickup,ActualDelDate,
			PickupTime,			
			DriverKey,RouteKey,OrderDetailKey,OrderKey,StatusName,StatusKey,OrderNo,CustName,
			MIN(PickupDateFrom) OVER( PARTITION BY OrderDetailKey Order by OrderDetailKey ) AS ContainerPickUpTime
			,BookingNo
			,CustAddress, OrderTypeKey 
			,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country , IsEmpty, PickUpType,ContainerSize
			INTO #DispatchData
		FROM #DispatchData1
		ORDER BY [WeekDay],OrderKey,OrderDetailKey

		SELECT DISTINCT OrderDetailKey INTO #IncompleteCont
		FROM #DispatchData 
		WHERE ISNULL(ChassisNo ,'')='' OR ISNULL(DriverName,'')='' OR ActualDelDate IS NULL		

		SELECT DISTINCT CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, ContainerPickUpTime), 0) AS TIME),0) AS ContainerPickUpTime,
			ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,		
			A.OrderDetailKey,OrderKey,OrderNo,CustName,	StatusName,			
			dbo.FN_IsOrderDetailComplete(A.OrderDetailKey) as ReadytoRelease, 
			BookingNo,
			CustAddress , OrderTypeKey 
			,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize
			INTO #DispatchDataFinal
		FROM #DispatchData A			
			LEFT JOIN #IncompleteCont IT ON IT.OrderDetailKey=A.OrderDetailKey	
			
	
	IF (SELECT COUNT(1) FROM #ContainerTypesFinal)=0 AND (SELECT COUNT(1) FROM #StatusName )<> 0
	BEGIN
		INSERT INTO #ContainerListData 
		(
		ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
		OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	, ReadytoRelease, BookingNo,CustAddress, OrderTypeKey
		,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize
		)
		SELECT	ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
				OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	,			
				ReadytoRelease,BookingNo,
				CustAddress, OrderTypeKey 
				,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
				,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country
				, IsEmpty, PickUpType,ContainerSize
		FROM #DispatchDataFinal	
		WHERE ( StatusName IN ( SELECT StatusName FROM #StatusName )) 		
	END

	IF (SELECT COUNT(1) FROM #ContainerTypesFinal)<> 0 AND (SELECT COUNT(1) FROM #StatusName )<> 0
	BEGIN
		INSERT INTO #ContainerListData
		(
		ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
		OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	, ReadytoRelease, BookingNo,CustAddress, OrderTypeKey
		,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty	, PickUpType,ContainerSize
		)
		SELECT	ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
				OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	,			
				ReadytoRelease,BookingNo,
				CustAddress, OrderTypeKey
				,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
				,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize
		FROM #DispatchDataFinal	
		WHERE ( StatusName IN ( SELECT StatusName FROM #StatusName )  AND 
			  (OrderDetailKey IN (select orderdetailkey from #ContainerTypesFinal )) ) 		
	
	END

	IF (SELECT COUNT(1) FROM #ContainerTypesFinal)<> 0 AND (SELECT COUNT(1) FROM #StatusName ) = 0
	BEGIN	
		INSERT INTO #ContainerListData
		(
		ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
		OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	, ReadytoRelease, BookingNo,CustAddress, OrderTypeKey
		,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
			,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country, IsEmpty, PickUpType,ContainerSize
		)
		SELECT	ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
				OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	,			
				ReadytoRelease, BookingNo,
				CustAddress, OrderTypeKey 
				,S_AddrName,S_Address1,S_City,S_State,S_ZipCode,S_Country
				,D_AddrName,D_Address1,D_City,D_State,D_ZipCode,D_Country	
				, IsEmpty, PickUpType,ContainerSize
		FROM #DispatchDataFinal
		WHERE  (OrderDetailKey IN ( SELECT orderdetailkey FROM #ContainerTypesFinal ))  	
			AND StatusName IN ( SELECT StatusName FROM #StatusName )		
	END

		--***********************************************************************************
		SELECT ROW_NUMBER() OVER ( PARTITION BY A.Orderdetailkey ORDER BY Routekey) AS LegNo,
			A.OrderDetailKey,W.RouteKey,RS.[Description] AS StatusDesc INTO #RouteLegNo
		FROM #ContainerListData A 
			INNER JOIN dbo.Routes W   WITH (NOLOCK) ON W.OrderDetailKey=A.OrderDetailKey
			INNER JOIN dbo.RouteStatus RS   WITH (NOLOCK) ON RS.Status=W.Status

		SELECT DISTINCT OrderDetailkey INTO #OrderDetl FROM #ContainerListData		

		SELECT A.OrderDetailKey,COUNT(RT.RouteKey) AS LegCount INTO #LegCount
		FROM #OrderDetl A 
			LEFT JOIN dbo.Routes RT   WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
		GROUP BY A.OrderDetailKey
		
		INSERT INTO #CurrLeg (OrderDetailKey,Routekey)
		SELECT A.OrderDetailKey,ISNULL(MIN(RT.RouteKey),0) AS CurrOPenRoutekey
		FROM #OrderDetl A 
			INNER JOIN dbo.Routes RT		  WITH (NOLOCK) ON RT.OrderDetailKey=A.OrderDetailKey
			INNER JOIN dbo.RouteStatus RTS	  WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
		WHERE RTS.[Description]<>'Leg Completed'
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
		INNER JOIN
			(
			 SELECT orderdetailkey FROM #ContTypes WHERE Comment='Hazard'
			) HZ ON CL.OrderDetailKey=HZ.OrderDetailKey	
		--*******************************************************
		SELECT ContainerNo,OrderType,DropOffDate,S.AddrName AS Origin, D.AddrName AS FinalDestination,--Origin,FinalDestination,
			A.OrderDetailKey,A.OrderKey,OrderNo,CustName,StatusName	, ReadytoRelease, BookingNo,CustAddress, OrderTypeKey,
			CASE WHEN C.LastRoutekey IS NULL THEN 0 ELSE ISNULL(V.LegNo,0) END AS NextLeg	
			,CAST(ISNULL(V.LegNo,0) AS VARCHAR(50))+' of '+CAST(L.LegCount AS VARCHAR(50)) AS CurLeg
			,S.AddrName AS FromLocation,D.AddrName AS ToLocation,I.DriverID + ' : ' + I.FirstName+' '+ISNULL(I.LastName,'') AS DriverName,
			I.DriverKey,
			R.ScheduledPickupDate,R.ScheduledArrival,R.RouteKey
			,S.AddrName AS S_AddrName,S.Address1 AS S_Address1, S.City AS S_City,s.State as s_State ,S.ZipCode AS S_ZipCode,S.Country AS S_Country
			,D.AddrName AS D_AddrName,D.Address1 AS D_Address1,D.City AS D_City,D.State AS D_State, D.ZipCode AS D_ZipCode,D.Country AS D_Country,R.PickupDateFrom,R.PickupDateTo
			,ISNULL(H.IsHazmat,0) AS IsHazmat, isnull(CDC.DocumentCount,0) as DocumentCount
			, A.IsEmpty, Q.PickUpType,ContainerSize,
			ContainerTypes= 
			STUFF(( 
				SELECT ', '+ShortComment 
				FROM #ContTypes 
				WHERE OrderDetailKey=A.OrderDetailKey
				FOR XML PATH('')), 1, 2, '')
		into #TempOutput
		FROM #ContainerListData A 
			INNER JOIN #CurrLeg Q ON Q.OrderDetailKey=A.OrderDetailKey
			INNER JOIN #RouteLegNo V ON V.RouteKey=Q.Routekey
			INNER JOIN dbo.Routes R   WITH (NOLOCK) ON R.RouteKey=Q.Routekey
			INNER JOIN #LegCount L ON L.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN dbo.[Address] S   WITH (NOLOCK) ON S.AddrKey=R.SourceAddrKey
			LEFT JOIN dbo.[Address] D   WITH (NOLOCK) ON D.AddrKey=R.DestinationAddrKey
			LEFT JOIN dbo.Driver I		WITH (NOLOCK) ON I.DriverKey=R.DriverKey
			LEFT JOIN #AllOrdComplLeg C ON C.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN #HazCont H ON H.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN ContainerDocumentCount CDC   WITH (NOLOCK) ON A.OrderDetailKey = CDC.OrderDetailKey		
		ORDER BY ScheduledPickupDate , ContainerNo
		--************************************************************************************

		--// Added on 2022-03-08
		select 
			isnull(ContainerNo,'') as ContainerNo,
			isnull(DropOffDate,'01-01-1900') as DropOffDate,
			isnull(FinalDestination,'') as FinalDestination,
			isnull(OrderDetailKey,0) as OrderDetailKey,
			isnull(OrderKey,0) as OrderKey,
			isnull(OrderType,'') as OrderType,
			isnull(Origin,'') as Origin,
			isnull(StatusName,'') as StatusName,
			isnull(OrderNo,'') as OrderNo,
			isnull(CustName,'') as CustName,
			isnull(ScheduledPickupDate,'01-01-1900') as ContainerTime,
			isnull(ReadyToRelease,convert(bit,0)) as ReadyToRelease,
			convert(bit,0) as IsRowHidden,
			isnull(BookingNo,'') as BookingNo,
			isnull(CustAddress,'') as CustAddress,
			isnull(OrderTypeKey,0) as OrderTypeKey,
			isnull(DriverKey,0) as DriverKey,
			isnull(DriverName,'') as DriverName,
			isnull(FromLocation,'') as FromLocation,
			isnull(ToLocation,'') as ToLocation,
			convert(datetime,isnull(ScheduledPickupDate,'01-01-1900')) as ScheduledPickupDate,
			convert(datetime,isnull(ScheduledArrival,'01-01-1900')) as ScheduledArrival,
			isnull(RouteKey,0) as RouteKey,
			isnull(NextLeg,0) as LegNo,
			isnull(IsHazmat,convert(bit,0)) as IsHazmat,
			isnull(S_Address1,'') as S_Address1,
			isnull(S_City,'') as S_City,
			isnull(S_State,'') as S_State,
			isnull(S_Country,'') as S_Country,
			isnull(S_ZipCode,'') as S_ZipCode,
			isnull(D_Address1,'') as D_Address1,
			isnull(D_City,'') as D_City,
			isnull(D_State,'') as D_State,
			isnull(D_Country,'') as D_Country,
			isnull(D_ZipCode,'') as D_ZipCode,
			convert(datetime,isnull(PickupDateFrom,'01-01-1900')) as PickupDateFrom,
			convert(datetime,isnull(PickupDateTo,'01-01-1900')) as PickupDateTo,
			isnull(DocumentCount,0) as DocumentCount,
			isnull(IsEmpty,convert(bit,0)) as IsEmpty,
			isnull(PickupType,'') as PickupType,
			DATEDIFF(HH,getdate(),convert(datetime,isnull(ScheduledPickupDate,getdate()))) as DelayHours,
			isnull(ContainerSize,'') as ContainerSize,
			isnull(ContainerTypes,'') as ContainerType,
			case when ScheduledPickupDate is null then 'NA' 
				 when DATEPART(HH,ScheduledPickupDate) >=18 OR DATEPART(HH,ScheduledPickupDate) <= 2 then 'Night'
				 else 'Day' end as DayNightIndicator,
			convert(varchar(100),'') as Scheduled_DateTime
			
		from #TempOutput
END
