

-- [Get_ContainerDispatchDetailSearch] @ContainerNo = 'MSKU100000002'
--Get_ContainerDispatchDetailSearch @Weekday ='', @Customer='', @OrderNo = '', @ContainerNo='', @LegType = '', @Status='', @PickUpDateFrom = '2020-08-01', @PickUpDateTo = '2020-09-07'
CREATE PROCEDURE [dbo].[Get_ContainerDispatchPrintData] 
@Weekday		CHAR(3)='',
@Customer		VARCHAR(50)='',
@OrderNo		VARCHAR(20)='',
@ContainerNo	VARCHAR(20)='',
@LegType		VARCHAR(200)='',
@Status			VARCHAR(100)='',
@PickUpDateFrom	DATE='01/01/2020',
@PickUpDateTo	DATE='12/31/2099',
@PickupTypeKey  SMALLINT=0
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;	

	DECLARE @OrderDetailKey INT
	DECLARE @StartDate	DATETIME
	DECLARE @EndDate	DATETIME

	SET @StartDate=CAST(GETDATE() AS DATE)
	SET @EndDate=DATEADD(SECOND,59,DATEADD(MINUTE,59,DATEADD(hh,23,DATEADD(DD,6,@StartDate))))

	;WITH    AllDays
          AS ( SELECT   @StartDate AS [Date], 1 AS [OrderBy]
               UNION ALL
               SELECT   DATEADD(DAY, 1, [Date]), [OrderBy] + 1
               FROM     AllDays
               WHERE    [Date] < @EndDate )
     SELECT [Date], [OrderBy] INTO #Weekdayorder
     FROM   AllDays 

	 DELETE FROM #Weekdayorder WHERE Orderby=8

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

	CREATE Table #LegType
	(
		LegKey SMALLINT
	)

	TRUNCATE TABLE #Status
	TRUNCATE TABLE #LegType
	TRUNCATE TABLE #ContainerStatus

	INSERT INTO #Status (StatusKey)
	SELECT [Value] FROM Fn_SplitParamCol(@Status)

	IF (SELECT COUNT(1) FROM #Status)=0
	BEGIN
		INSERT INTO #Status (StatusKey)
		SELECT [Status] FROM dbo.RouteStatus where IsActive=1 
	END

	INSERT INTO #LegType (LegKey)
	SELECT [Value] FROM Fn_SplitParamCol(@LegType)

	SELECT DISTINCT FromLocation  INTO #FromLoc
	FROM dbo.Leg 
	WHERE LegKey IN ( SELECT LegKey FROM #LegType )

	SELECT RT.[Description] AS StatusName INTO #StatusName
	FROM #Status A 
	INNER JOIN dbo.RouteStatus RT ON RT.[Status]=A.StatusKey	

	SELECT OD.ContainerNo, OT.OrderType ,OD.DropOffDate,
		DSour.AddrName AS Origin,DDest.AddrName AS FinalDestination,
		L.LegNo,L.[LegID],RT.PickupDateFrom ,RT.SwitchTo,
		RT.DeliveryDateFrom ,Sour.City AS FromLocation,Dest.city AS ToLocation,	
		ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,RT.ChassisNo,RT.ChassisType,
		RT.ActualDeparture AS ActualPickup,RT.ActualArrival AS ActualDelDate,
		CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  DATENAME(DW,RT.PickupDateFrom ) 
		WHEN RT.PickupDateFrom<@StartDate THEN 'Past'ELSE 'Future' END AS [WeekDay],
		CONVERT(VARCHAR(10), CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, RT.PickupDateFrom), 0) AS TIME),0) AS PickupTime,
		DR.DriverKey, RT.RouteKey,OD.OrderDetailKey,OD.OrderKey, RTS.[Description] AS StatusName, 
		RT.[Status] AS StatusKey, OH.OrderNo, CUS.CustName,OH.BookingNo,
		ISNULL(CAdr.Address1,'')+', '+ISNULL(CAdr.City,'')+', '+
		ISNULL(CAdr.State,'')+', '+ISNULL(CAdr.ZipCode,'')+', '+ISNULL(CAdr.Country,'') AS CustAddress	,
		OT.OrderTypeKey, --,L.FromLocation as filterloc,L.LegKey  
		OD.VesselETA
		INTO #DispatchData1
	FROM OrderDetail OD 
		INNER JOIN  dbo.OrderHeader OH	ON OH.OrderKey=OD.OrderKey
		INNER JOIN  dbo.Customer CUS	ON CUS.CustKey=OH.CustKey
		INNER JOIN  dbo.OrderType OT		ON OT.OrderTypeKey=OH.OrderTypeKey
		INNER JOIN  dbo.[Routes] RT		ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN  dbo.Leg L			ON RT.LegKey=L.LegKey
		INNER JOIN  dbo.LegType LT		ON LT.LegtypeKey=L.LegTypeKey
		INNER JOIN  dbo.RouteStatus RTS ON RTS.[Status]=RT.[Status]	
		LEFT JOIN   dbo.[Address] CAdr	ON CAdr.Addrkey=OH.BillToAddrKey
		LEFT JOIN   dbo.[Address] Sour	ON Sour.Addrkey=RT.SourceAddrkey
		LEFT JOIN   dbo.[Address] Dest	ON Dest.Addrkey=RT.DestinationAddrkey
		LEFT JOIN   dbo.[Address] DSour	ON DSour.Addrkey=OD.SourceAddrKey
		LEFT JOIN   dbo.[Address] DDest	ON DDest.Addrkey=OD.DestinationAddrKey
		LEFT JOIN   dbo.Driver DR		ON DR.DriverKey=RT.DriverKey
		LEFT JOIN   dbo.Chassis CH		ON CH.chassisKey=RT.ChassisKey	
		LEFT JOIN   dbo.OrderDetailStatus ODS ON ODS.[Status]=OD.[Status]		
	WHERE ( ODS.[Description] IN ('Schedule Confirmed','Dispatch InProgress') ) AND ( RTS.[Description]<>'Leg Completed' ) --AND RT.pickupDate >= @StartDate
		AND RTS.[Status] IN ( SELECT StatusKey FROM #Status )
		AND (@Weekday  IS NULL OR @Weekday=''  OR 
		 LEFT( (CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  DATENAME(DW,RT.PickupDateFrom ) 
					 WHEN RT.PickupDateFrom<@StartDate THEN 'Past'ELSE 'Future' END),3)= @Weekday)
		AND (@Customer IS NULL OR @Customer='' OR CUS.CustName LIKE '%' + @Customer + '%')
		AND (@OrderNo  IS NULL OR @OrderNo=''  OR OH.OrderNo LIKE '%' + @OrderNo + '%')
		AND (@ContainerNo  IS NULL OR @ContainerNo=''  OR OD.ContainerNo LIKE '%' + @ContainerNo + '%')
		--AND (@LegType  IS NULL OR @LegType=''  OR L.LegKey IN ( SELECT LegTypeKey FROM #LegType) )
		AND (@LegType  IS NULL OR @LegType=''  OR L.FromLocation IN ( SELECT FromLocation FROM #FromLoc) )	
		AND	(@PickUpDateFrom	IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)
		AND (@PickUpDateTo		IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)		
		AND (@PickupTypeKey		IS NULL OR @PickupTypeKey=0	OR L.PickupTypeKey = @PickupTypeKey)
		--********************************************************************************************

		--select * from #DispatchData1

		--return

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
					IF (	SELECT COUNT(1) 
							FROM #OrderStautsbyLeg 
							WHERE OrderDetailKey=@OrderDetailKey AND StatusName='Leg Completed'
					   )>0
					BEGIN					
						INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
						SELECT NULL,MIN(RouteKey) AS RouteKey,@OrderDetailKey 
						FROM #OrderStautsbyLeg 
						WHERE StatusName<>'Leg Completed' AND OrderDetailKey=@OrderDetailKey						
					END					
					ELSE
					BEGIN						
						INSERT INTO #ContainerStatus (StatusName,RouteKey,OrderDetailKey)
						SELECT NULL,MIN(RouteKey) AS RouteKey,@OrderDetailKey 
						FROM #OrderStautsbyLeg 
						WHERE OrderDetailKey=@OrderDetailKey						
					END
				END			
			DELETE FROM #OrdeDtlKey WHERE OrderDetailKey=@OrderDetailKey
		END
		
		UPDATE A
		SET A.StatusName= F.StatusName		
		FROM #ContainerStatus A 
		INNER JOIN #OrderStautsbyLeg F ON F.RouteKey=A.RouteKey			   
	
		UPDATE A
		SET A.StatusName=S.StatusName,A.PickupDateFrom=D.PickupDateFrom---,A.[WeekDay]= DATENAME(DW,D.PickupDate )
		FROM #DispatchData1 A 
			LEFT JOIN #ContainerStatus S ON S.OrderDetailKey=A.OrderDetailKey
			LEFT JOIN #DispatchData1 D ON D.RouteKey=S.RouteKey

		--UPDATE #DispatchData1
		--SET PickupDateFrom=NULL,[WeekDay]=NULL		
		--WHERE StatusName='Leg Completed'

		UPDATE #DispatchData1
		SET [WeekDay]=  CASE WHEN PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  DATENAME(DW,PickupDateFrom ) 
						WHEN PickupDateFrom<@StartDate THEN 'Past'ELSE 'Future' END	
	
--***********************************************************
		SELECT 
			ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,LegNo,LegID,PickupDateFrom,SwitchTo,DeliveryDateFrom
			,FromLocation,ToLocation,DriverName,ChassisNo,ChassisType,ActualPickup,ActualDelDate,
			UPPER(LEFT([WeekDay],3)) AS [WeekDay],PickupTime,			
			OrderBy AS WeekNum,
			DriverKey,RouteKey,OrderDetailKey,OrderKey,StatusName,StatusKey,OrderNo,CustName,--ConfirmationNo,
			MIN(PickupDateFrom) OVER( PARTITION BY OrderDetailKey Order by OrderDetailKey ) AS ContainerPickUpTime
			,BookingNo--,AppointmentNo
			,CustAddress, OrderTypeKey, VesselETA --,  FromLocationKey,  ToLocationKey
			INTO #DispatchData
		FROM #DispatchData1
			LEFT JOIN #Weekdayorder W ON CAST(W.[DATE] AS DATE)=CAST(PickupDateFrom AS DATE)
		ORDER BY [WeekDay],OrderKey,OrderDetailKey

		UPDATE #DispatchData
		SET WeekNum=9
		WHERE [WeekDay]='FUT'

		UPDATE #DispatchData
		SET WeekNum=-9
		WHERE [WeekDay]='PAS'
	 
		SELECT DISTINCT OrderDetailKey INTO #IncompleteCont
		FROM #DispatchData 
		WHERE ISNULL(ChassisNo ,'')='' OR ISNULL(DriverName,'')='' OR ActualDelDate IS NULL		

		SELECT DISTINCT
			WeekNum,
			[WeekDay],CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, ContainerPickUpTime), 0) AS TIME),0) AS ContainerPickUpTime,
			ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,		
			A.OrderDetailKey,OrderKey,OrderNo,CustName,	StatusName,
			CASE WHEN IT.OrderDetailKey IS NULL AND StatusName<> 'Leg Completed' THEN 1 ELSE 0 END AS ReadytoRelease,
			BookingNo,--ConfirmationNo,AppointmentNo,
			CustAddress , OrderTypeKey, VesselETA --,  FromLocationKey,  ToLocationKey
			INTO #DispatchDataFinal
		FROM #DispatchData A			
			LEFT JOIN #IncompleteCont IT ON IT.OrderDetailKey=A.OrderDetailKey	

		SELECT	WeekNum,[WeekDay],ContainerPickUpTime,ContainerNo,OrderType,DropOffDate,Origin,FinalDestination,
				OrderDetailKey,OrderKey,OrderNo,CustName,StatusName	,			
				ReadytoRelease,BookingNo,--ConfirmationNo,AppointmentNo,
				CustAddress, OrderTypeKey INTO #ContainerDtl --,  FromLocationKey,  ToLocationKey
		FROM #DispatchDataFinal	
		WHERE( StatusName IN ( SELECT StatusName FROM #StatusName ) OR 1=1)		
		ORDER BY WeekNum, [WeekDay],ContainerPickUpTime, ContainerNo
		--****************************Leg Detail****************************

		SELECT OD.ContainerNo,
		--L.LegNo, 
		CAST(ROW_number () OVER ( ORDER BY RT.RouteKey) AS SMALLINT )AS LegNo,
		L.[LegID],RT.PickupDateFrom ,RT.SwitchTo,
		RT.DeliveryDateFrom ,ISNULL(Sour.AddrName,'')+', '+ISNULL(Sour.City,'') AS FromLocation,ISNULL(Dest.AddrName,'')+', '+ISNULL(Dest.city,'') AS ToLocation,	
		ISNULL(DR.DriverID,'') + ': ' + ISNULL(DR.FirstName,'')+' '+ISNULL(DR.LastName,'') AS DriverName,RT.ChassisNo,RT.ChassisType,
		CASE WHEN ISNULL(RT.ActualDeparture,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualDeparture END AS ActualPickup,
		CASE WHEN ISNULL(RT.ActualArrival,'1970-01-01 00:00:00.000') = '1970-01-01 00:00:00.000' THEN NULL ELSE RT.ActualArrival END AS  ActualDelDate,
		DR.DriverKey, RT.RouteKey,OD.OrderDetailKey,OD.OrderKey, RTS.[Description] AS StatusName, 
		RT.[Status] AS StatusKey, OD.ConfirmationNo , RT.ChassisKey,
		RT.PickupDateFrom AS ScheduledPickupDate,
		RT.DeliveryDateFrom AS ScheduledDeliveryDate, CH.chassisNo as ChassisID, VesselETA,
		Case when dbo.FN_IsRouteComplete(RT.RouteKey) = 1 then 1 else 0 end as ReadyToMarkComplete,
		Sour.AddrKey as FromLocationKey, Dest.AddrKey as ToLocationKey, L.LegKey INTO #LegDetail
	FROM OrderDetail OD 
		INNER JOIN  dbo.[Routes] RT	ON RT.OrderDetailKey=OD.OrderDetailKey
		INNER JOIN  dbo.Leg L		ON RT.LegKey=L.LegKey
		INNER JOIN  dbo.LegType LT	ON LT.LegtypeKey=L.LegTypeKey
		INNER JOIN  dbo.RouteStatus RTS ON RTS.[Status]=RT.[Status]	
		LEFT JOIN   dbo.[Address] Sour	ON Sour.Addrkey=RT.SourceAddrkey
		LEFT JOIN   dbo.[Address] Dest	ON Dest.Addrkey=RT.DestinationAddrkey
		LEFT JOIN   dbo.Driver DR		ON DR.DriverKey=RT.DriverKey
		LEFT JOIN   dbo.Chassis CH		ON CH.chassisKey=RT.ChassisKey	
		LEFT JOIN  dbo.OrderDetailStatus ODS ON ODS.[Status]=OD.[Status]		
	WHERE OD.OrderDetailKey in( SELECT DISTINCT OrderDetailKey FROM #DispatchData1 )
	--***********************************************************************

	SELECT A.WeekNum,A.[WeekDay],A.ContainerNo,B.ScheduledPickupDate,B.ScheduledDeliveryDate,
			CONVERT(varchar(15),CAST(B.ScheduledPickupDate  AS TIME),100) AS ContainerPickUpTime,A.OrderType,A.Origin,A.FinalDestination,
				--A.OrderDetailKey,A.OrderKey,
			A.OrderNo,A.CustName,A.StatusName	,			
			A.ReadytoRelease,A.BookingNo,A.CustAddress,B.FromLocation,B.ToLocation,B.ActualPickup,B.ActualDelDate,
			B.LegID,B.SwitchTo,B.DriverName,B.ConfirmationNo,B.ChassisID,B.ChassisType, VesselETA,
			ROW_NUMBER() OVER ( Partition by A.ContainerNo ORDER BY B.LegNo) AS LegNo,B.StatusName as LegStatusName
	FROM #ContainerDtl A 
	LEFT JOIN #LegDetail B ON A.ContainerNo=B.ContainerNo
	--select * from #LegDetail
END
