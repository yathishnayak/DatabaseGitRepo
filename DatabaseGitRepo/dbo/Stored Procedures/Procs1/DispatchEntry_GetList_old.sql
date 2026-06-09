

-- [DispatchEntry_GetList] @status = '2:'

CREATE PROCEDURE [dbo].[DispatchEntry_GetList_old] 
@Weekday		CHAR(3)='',
@Customer		VARCHAR(50)='',
@OrderNo		VARCHAR(20)='',
@ContainerNo	VARCHAR(20)='',
@LegType		VARCHAR(200)='',
@Status			VARCHAR(100)='',
@ContainerType	VARCHAR(100)='',
@PickUpDateFrom	DATE='01/01/2020',
@PickUpDateTo	DATE='12/31/2099',
@PickupTypeKey  SMALLINT=0,
@BookingNo		varchar(50) = '',
@DriverKey		int = 0
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @OrderDetailKey INT
	DECLARE @StartDate		DATETIME
	DECLARE @EndDate		DATETIME
	DECLARE @PickUpFrom		VARCHAR(50)
	DECLARE @ContCmnt       VARCHAR(2000)
	declare @HazardTypeKey	smallint

	SET @StartDate=CAST(GETDATE() AS DATE)
	SET @EndDate= DATEADD(d,7,@StartDate)
	SET @PickUpFrom= ( SELECT PickUpType from PickUpType WHERE PickupTypeKey=@PickupTypeKey)
	select @HazardTypeKey  = ContainerTypeKey from ContainerTypes  where TypeID = 'Hazard'

	
	SELECT [Value] as ContainerType into #ContainerType FROM Fn_SplitParamCol(@ContainerType)	

	select Status as StatusKey
	into #OrderDetailStatus
	from OrderDetailStatus
	where Description in ('Schedule Confirmed','Dispatch InProgress','Dispatch OnHold')

	Set @Status = replace(@Status,':','')



		SELECT	  WeekNum =  CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  datepart(WEEKDAY, RT.PickupDateFrom ) 
						WHEN RT.PickupDateFrom < convert(Date,@StartDate) THEN -9 ELSE 9 END	,
			[WeekDay] =  CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  LEFT(DATENAME(DW,RT.PickupDateFrom ) ,3)
						WHEN RT.PickupDateFrom < convert(Date,@StartDate) THEN 'PAS' ELSE 'FUT' END	,
			--ISNULL(MIN(PickupDateFrom) OVER( PARTITION BY OD.OrderDetailKey Order by OD.OrderDetailKey ),'12:00') as ContainerPickUpTime,
			 CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, PickupDateFrom), 0) AS TIME),0) AS ContainerPickUpTime,
			OD.ContainerNo,OrderType, OD.DropOffDate,
			isnull(SR.AddrName,'') AS Origin, 
			isnull(DT.AddrName,'') AS FinalDestination,--Origin,FinalDestination,
			OD.OrderDetailKey,OD.OrderKey,OrderNo,CustName,RTS.Description as StatusName	, 
			convert(bit,isnull(dbo.FN_IsOrderDetailComplete(OD.OrderDetailKey),0)) as ReadytoRelease, 
			convert(bit,isnull(dbo.FN_MoveComplete(OD.OrderDetailKey),0)) AS ReadytoMoveComplete,
			isnull(BookingNo,'') as BookingNo,
			ISNULL(CAdr.Address1,'')+', '+ISNULL(CAdr.City,'')+', '+
				ISNULL(CAdr.State,'')+', '+ISNULL(CAdr.ZipCode,'')+', '+ISNULL(CAdr.Country,'') as  CustAddress, 
			OH.OrderTypeKey,
			CONVERT(BIGINT,ISNULL(OD.CurrentLegNo,0) ) AS LegNo	
			,CAST(ISNULL(OD.CurrentLegNo,0) AS VARCHAR(50))+' of '+CAST(od.TotalLegs AS VARCHAR(50)) AS CurLeg
			,isnull(SRR.AddrName,'') AS FromLocation,
			isnull(DTR.AddrName,'') AS ToLocation,
			isnull(DR.DriverID + ' : ' + DR.FirstName+' '+ISNULL(DR.LastName,''),'')  AS DriverName,
			Dr.DriverKey,
			isnull(RT.ScheduledPickupDate,'01-01-1900') as ScheduledPickupDate,
			isnull(RT.ScheduledArrival,'01-01-1900') as ScheduledArrival,
			RT.RouteKey
			,isnull(SRR.AddrName,'') AS S_AddrName,
			isnull(SRR.Address1,'') AS S_Address1, 
			isnull(SRR.City,'') AS S_City,
			isnull(sRR.State,'') as s_State ,
			isnull(SRR.ZipCode,'') AS S_ZipCode,
			isnull(SRR.Country,'') AS S_Country
			,isnull(DTR.AddrName,'') AS D_AddrName,
			isnull(DTR.Address1,'') AS D_Address1,
			isnull(DTR.City,'') AS D_City,
			isnull(DTR.State,'') AS D_State, 
			isnull(DTR.ZipCode,'') AS D_ZipCode,
			isnull(DTR.Country,'') AS D_Country,
			isnull(RT.PickupDateFrom,'01-01-1900')  as PickupDateFrom,
			isnull(RT.PickupDateTo,'01-01-1900') as PickupDateTo,
			--isnull(RT.DeliveryDateFrom,'01-01-1900')  as DeliveryDateFrom,
			--isnull(RT.DeliveryDateTo,'01-01-1900') as DeliveryDateTo,
			--ISNULL(HZ.IsHazmat,0)  AS IsHazmat, 
			Case when isnull(HZ.TypeID,'') = '' then 0 else 1 end as IsHazmat,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			isnull(od.IsEmpty,0) as IsEmpty,
			isnull(pt.PickUpType,'') as PickUpType,
			isnull(s.Description,'') as ContainerSize, 
			isnull(od.VesselETA,'01-01-1900') as VesselETA,
			isnull(BillOfLading,'') as BillOfLading,
			ContainerType= '',
			--STUFF(( 
			--	SELECT ', '+ ShortComment 
			--	FROM #ContTypes 
			--	WHERE OrderDetailKey=A.OrderDetailKey
			--	FOR XML PATH('')), 1, 2, ''),
			od.isStreetTurn,
			ISNULL(u2.UserName,'') AS StreetTurnSetUser,
			OD.StreetTurnSetDate,
			OD.IsLinked,
			OD.LinkedContainerNo,
			OD.LinkedOrderDetailKey,
		    CAST( ISNULL(OD.TMFCheckOff,0)AS BIT) TMFCheckOff ,
			CAST(ISNULL(OD.CTFCheckOff,0) AS BIT) CTFCheckOff ,
			RT.Status,

			L.LegID as LegID,
			isnull(RT.ScheduledPickupDate,'01-01-1900') as ContainerTime,
			DelayHours =  Case when RT.Status = 2 then 0 
								when RT.ScheduledPickupDate is null then 0
								else DATEDIFF(HOUR, RT.ScheduledPickupDate, Getdate()) end,
			DayNightIndicator = Case when RT.ScheduledPickupDate is null then 'NA'
							when DATEPART(Hour,RT.ScheduledPickupDate) >= 18 then 'Night'
							when DATEPART(Hour,RT.ScheduledPickupDate) <= 2 then 'Night'
							else 'Day' end,
			STUFF((SELECT distinct ', ' + CMT.MoveTypeName
         from CarrierMoveType CMT
		 INNER JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey=CMT.MoveTypeKey AND IsSelected=1
         where DR.DriverKey = DM.DriverKey
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,2,'') MoveTypes
	into #Data
		
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
		Left JOIN OrderDetailStatus RS ON OD.Status = RS.Status
		Left join dbo.PickUpType PT   WITH (NOLOCK) on L.PickupTypeKey = PT.PickupTypeKey
		LEFT JOIN dbo.ContainerDocumentCount CDC   WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
		inner join #OrderDetailStatus ODS on ODS.StatusKey = OD.Status
		lEFT jOIN [USER] u2 WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey
		--leFT jOIN (
		--		 SELECT DISTINCT orderdetailkey, 1 AS IsHazmat FROM #ContTypes WHERE Comment='Hazard'
		--) HZ ON od.OrderDetailKey = HZ.OrderDetailKey
		LEFT JOIN vContainerType HZ ON HZ.ORDERDETAILKEY = OD.OrderDetailKey AND HZ.ContainerTypeKey = @HazardTypeKey
		LEft join ContainerTypesLink CTL on OD.OrderDetailKey = CTL.OrderDetailKey and CTL.IsSelected = 1
	WHERE OD.Status not in (1,11) and  RT.RouteKey = OD.CurrentRouteKey  
	AND	(@PickUpDateFrom	IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)
	AND (@PickUpDateTo		IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)	
	AND (@Weekday  IS NULL OR @Weekday=''  OR 
		 LEFT( (CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN upper(DATENAME(DW,RT.PickupDateFrom ) )
					 WHEN RT.PickupDateFrom<@StartDate THEN 'PAS'ELSE 'FUT' END),3)= @Weekday)
		AND (isnull(@Customer,'') = '' OR CUS.CustName LIKE '%' + @Customer + '%')
		AND (isnull(@OrderNo ,'') = '' OR OH.OrderNo LIKE '%' + @OrderNo + '%')
		AND (isnull(@ContainerNo,'') = '' OR OD.ContainerNo LIKE '%' + @ContainerNo + '%')
		AND	(@PickUpDateFrom	IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)
		AND (@PickUpDateTo		IS NULL OR RT.PickupDateFrom	IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)		
		AND (isnull(@PickupTypeKey,0) = 0 OR L.PickupTypeKey = @PickupTypeKey)	
		AND (isnull(@BookingNo,'') = '' OR OH.BookingNo like '%' + @BookingNo + '%')
		AND (Isnull(@ContainerType,'') = '' OR CTl.ContainerTypeKey in (select ContainerType from #ContainerType))

		AND (isnull(@DriverKey,0) = 0 OR RT.DriverKey = @DriverKey)

	ORDER BY ContainerTime, ScheduledPickupDate , ContainerNo

	SELECT A.[Description] AS StatusName ,A.[Status],COUNT(ContainerNo) AS ContainerCount,'I' as [Level] 
	INTO #DashBoarData1
	FROM dbo.RouteStatus A WITH (NOLOCK)
		LEFT JOIN #Data F ON F.StatusName=A.Description
	GROUP BY A.[Description],A.[Status]
	UNION ALL
	SELECT 'Total Containers' ,0,COUNT(ContainerNo) AS ContainerCount,'S' as Level
	FROM dbo.RouteStatus A WITH (NOLOCK)
		LEFT JOIN #Data F ON F.StatusName=A.Description
			
	SELECT A.StatusName,A.Status,A.ContainerCount,A.[Level],ISNULL(B.OrderBy ,50) AS OrderBy 
	INTO #DashBoarData
	FROM  #DashBoarData1 A
	LEFT JOIN dbo.RouteStatus B ON B.[Description]=A.StatusName

	--select * from #data
	
	select DashBoardData  = (
		Select A.Status as StatusKey, A.StatusName as Description, 
		A.Level, A.OrderBy, A.ContainerCount as DispatchCount 
		from #DashBoarData A for JSON Auto
	), DispatchListResult = (
		select * 
		from #data
		where (isnull( @Status,0) = 0 OR @Status = Status) 
		ORDER BY ContainerTime, ScheduledPickupDate , ContainerNo
		for JSON AUTO
	)  FOR JSON PATH, without_array_wrapper
END
