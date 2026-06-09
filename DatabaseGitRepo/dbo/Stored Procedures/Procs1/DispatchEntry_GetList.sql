
CREATE PROCEDURE [dbo].[DispatchEntry_GetList] -- DispatchEntry_GetList @CarrierStatus='4', @Status='1', @IsDebug = 1  
(  
 @Weekday    CHAR(3)='',  
 @Customer    VARCHAR(50)='',  
 @OrderNo    VARCHAR(20)='',  
 @ContainerNo   VARCHAR(20)='',  
 @LegType    VARCHAR(200)='',  
 @Status     VARCHAR(100)='',  
 @ContainerType   VARCHAR(100)='',  
 @PickUpDateFrom   DATE='01/01/2020',  
 @PickUpDateTo   DATE='12/31/2099',  
 @PickupTypeKey   SMALLINT=0,  
 @BookingNo    varchar(50) = '',  
 @DriverKey    int = 0,  
 @marketLocationKey  INT = 0,  
 @searchText    varchar(100)='',  
 @LegID     VARCHAR(100)='',  
 @CarrierStatus   int=0,  
 @Dispatcher    INT=0,  
 @IsDriverApp   INT=0,  
 @IsDebug    bit = 0  
)  
AS  
BEGIN   
 SET NOCOUNT ON;  
 SET FMTONLY OFF;  
 SET ARITHABORT ON;  
  
 if( @PickUpDateFrom='0001-01-01 00:00:00')  
 Begin  
  Set @PickUpDateFrom = '2020-01-01'  
 End  
   
 if(@PickUpDateTo='0001-01-02 00:00:00')  
 Begin  
  set @PickUpDateTo = '2050-12-31'  
 End  
   
  
 DECLARE @OrderDetailKey INT  
 DECLARE @StartDate  DATETIME  
 DECLARE @EndDate  DATETIME  
 DECLARE @PickUpFrom  VARCHAR(50)  
 DECLARE @ContCmnt       VARCHAR(2000)  
 declare @HazardTypeKey smallint  
  
 SET @StartDate=CAST(GETDATE() AS DATE)  
 SET @EndDate= DATEADD(d,7,@StartDate)  
 SET @PickUpFrom= ( SELECT PickUpType from PickUpType  WITH (NOLOCK) WHERE PickupTypeKey=@PickupTypeKey)  
 select @HazardTypeKey  = ContainerTypeKey from ContainerTypes  WITH (NOLOCK)  where TypeID = 'Hazard'  
  
   
 SELECT [Value] as ContainerType into #ContainerType FROM Fn_SplitParamCol(@ContainerType)   
  
 SELECT [Value] as LegKey into #LegKeys FROM Fn_SplitParam(@LegID)  
   
 SELECT  OrderDetailkey into #OrderDetailkey_Temp FROM OrderDetail  WITH (NOLOCK) WHERE ContainerNo = ISNULL(@searchText,'-') AND ISNULL(ContainerNo,'') <> ''  
      
 --SET @OrderDetailKey = ISNULL(@OrderDetailKey,0)  
  
 IF @IsDebug = 1  
 BEGIN  
  SELECT @searchText, @OrderDetailKey  
 END  
  
 CREATE TABLE #OrderDetailStatus  
 (  
  StatusKey INT  
 )  
  
 -- SELECT @IsContainerSearch  
  
 IF((select count(1) from #OrderDetailkey_Temp) > 0)  
  BEGIN  
   INSERT into #OrderDetailStatus  
   SELECT Status from OrderDetailStatus  WITH (NOLOCK)  
  END  
 ELSE  
  BEGIN  
   INSERT into #OrderDetailStatus  
   SELECT Status from OrderDetailStatus WITH (NOLOCK)  
   where Description in ('Schedule Confirmed','Dispatch InProgress','Dispatch OnHold')  
  END  
  
 Set @Status = replace(@Status,':','')  
 if(isnull(@status,'') = '')  
 Begin  
  set @Status = 0  
 End  
   
  
  
  SELECT   WeekNum =  CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  datepart(WEEKDAY, RT.PickupDateFrom )   
      WHEN RT.PickupDateFrom < convert(Date,@StartDate) THEN -9 ELSE 9 END ,  
   [WeekDay] =  CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN  LEFT(DATENAME(DW,RT.PickupDateFrom ) ,3)  
      WHEN RT.PickupDateFrom < convert(Date,@StartDate) THEN 'PAS' ELSE 'FUT' END ,  
   --ISNULL(MIN(PickupDateFrom) OVER( PARTITION BY OD.OrderDetailKey Order by OD.OrderDetailKey ),'12:00') as ContainerPickUpTime,  
    CONVERT(VARCHAR(10),CAST(DATEADD(HOUR, DATEDIFF(HOUR, 0, PickupDateFrom), 0) AS TIME),0) AS ContainerPickUpTime,  
   OD.ContainerNo,OrderType, OD.DropOffDate,  
   isnull(SR.AddrName,'') AS Origin,   
   isnull(DT.AddrName,'') AS FinalDestination,--Origin,FinalDestination,  
   OD.OrderDetailKey,OD.OrderKey,OrderNo,CustName,RTS.Description as StatusName ,   
   convert(bit,isnull(dbo.FN_IsOrderDetailComplete(OD.OrderDetailKey),0)) as ReadytoRelease,   
   convert(bit,isnull(dbo.FN_MoveComplete(OD.OrderDetailKey),0)) AS ReadytoMoveComplete,  
   isnull( OH.BookingNo,'') as BookingNo,  
   ISNULL(CAdr.Address1,'')+', '+ISNULL(CAdr.City,'')+', '+  
    ISNULL(CAdr.State,'')+', '+ISNULL(CAdr.ZipCode,'')+', '+ISNULL(CAdr.Country,'') as  CustAddress,   
   ISNULL(OD.OrderTypeKey, OH.OrderTypeKey) OrderTypeKey,  
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
   isnull(RT.DeliveryDateFrom,'01-01-1900')  as DeliveryDateFrom,  
   isnull(RT.DeliveryDateTo,'01-01-1900') as DeliveryDateTo,  
   --ISNULL(HZ.IsHazmat,0)  AS IsHazmat,   
   Case when isnull(HZ.TypeID,'') = '' then 0 else 1 end as IsHazmat,  
   isnull(CDC.DocumentCount,0) as DocumentCount,  
   isnull(od.IsEmpty,0) as IsEmpty,  
   isnull(pt.PickUpType,'') as PickUpType,  
   isnull(s.Description,'') as ContainerSize,   
   isnull(s.ContainerSizeKey,0) as ContainerSizeKey,  
   isnull(od.VesselETA,'01-01-1900') as VesselETA,  
   isnull(BillOfLading,'') as BillOfLading,  
   ContainerType= '',  
   --STUFF((   
   -- SELECT ', '+ ShortComment   
   -- FROM #ContTypes   
   -- WHERE OrderDetailKey=A.OrderDetailKey  
   -- FOR XML PATH('')), 1, 2, ''),  
   od.isStreetTurn,  
   ISNULL(u2.UserName,'') AS StreetTurnSetUser,  
   OD.StreetTurnSetDate,  
   OD.IsLinked,  
   OD.LinkedContainerNo,  
   OD.LinkedOrderDetailKey,  
      CAST(ISNULL(OD.TMFCheckOff,0)AS BIT) TMFCheckOff ,  
   CAST(ISNULL(OD.CTFCheckOff,0) AS BIT) CTFCheckOff ,  
   CAST(ISNULL(OD.IsTMFJCTPaid,0) AS BIT) IsTMFJCTPaid,  
   CAST(ISNULL(OD.IsTMFCustomerPaid,0) AS BIT) IsTMFCustomerPaid,  
   CAST(ISNULL(OD.IsCTFJCTPaid,0) AS BIT) IsCTFJCTPaid,  
   CAST(ISNULL(OD.IsCTFCustomerPaid,0) AS BIT) IsCTFCustomerPaid,  
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
         from CarrierMoveType CMT  WITH (NOLOCK)  
   INNER JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey=CMT.MoveTypeKey AND IsSelected=1  
      --   where DR.DriverKey = DM.DriverKey   
            FOR XML PATH(''), TYPE  
            ).value('.', 'NVARCHAR(MAX)')   
        ,1,2,'') MoveTypes,  
  CASE WHEN RT.ActualDepartureUpdateMethod ='DriverApp' OR RT.ActualArrivalUpdateMethod='DriverApp' OR   
    RT.ChassisSource='DriverApp' OR RT.DryRunSource='DriverApp' OR   
    RT.EmptySource='DriverApp' OR RT.BobtailSource='DriverApp' OR  
    RT.StreetTurnSource='DriverApp' THEN 1  
  ELSE 2 END AS IsDriverApp,  
  ML.MarketLocationKey,ML.MarketLocation,TT.TruckType,DR.TruckTypeKey, SL.LineName AS SteamShipLine,  
  CH.chassisNo AS ChassisNo, CUS.CustID AS CustID, OH.CustKey AS CustKey, CAST(ISNULL(MarkedNoEmptyAvailable,0) AS BIT) MarkedNoEmptyAvailable,  
  PortDropLegCount=(SELECT COUNT(LegKey) FROM [Routes] RTI WITH (NOLOCK) WHERE RTI.OrderDetailKey=OD.OrderDetailKey AND LegKey IN (35,37,39,52,54,56)),  
  LAST_ROUTEKEY  ,
  ETA_ATAChangedByUser,ContainerStatusChangedByUser,ISNULL(MBLChangedByUser,0) MBLChangedByUser,
  LFDChangedByUser, SSLChangedByUser,	Size_TypeChangedByUser,HoldChangedByUser,VesselChangedByUser,
  AvailableChangedByUser,HoldTypeChangedByUser,AvailableDateChangedByUser
 into #Data  
    
 FROM (SELECT * FROM dbo.OrderDetail WITH (NOLOCK)  
	WHERE ((Select count(1) from #OrderDetailkey_Temp) > 0 AND  OrderDetailKey in (Select OrderDetailKey from #OrderDetailkey_Temp)  ) 
	OR ( (Select count(1) from #OrderDetailkey_Temp) =0  )) OD     
  INNER JOIN  dbo.OrderHeader OH   WITH (NOLOCK) ON OH.OrderKey=OD.OrderKey  
  INNER JOIN  dbo.Customer CUS   WITH (NOLOCK) ON CUS.CustKey=OH.CustKey  
  INNER JOIN  dbo.OrderType OT   WITH (NOLOCK) ON OT.OrderTypeKey=isnull(OD.ordertypekey,OH.OrderTypeKey )
  INNER JOIN  dbo.[Routes] RT    WITH (NOLOCK) ON RT.OrderDetailKey=OD.OrderDetailKey  
  INNER JOIN (SELECT ORDERDETAILKEY , MAX(ROUTEKEY) AS LAST_ROUTEKEY FROM DBO.ROUTES  WITH (NOLOCK) GROUP BY ORDERDETAILKEY)  
   RTM  ON RTM.OrderDetailKey=OD.OrderDetailKey  
  INNER JOIN  dbo.Leg L     WITH (NOLOCK) ON RT.LegKey=L.LegKey  
  INNER JOIN  dbo.LegType LT    WITH (NOLOCK) ON LT.LegtypeKey=L.LegTypeKey  
  INNER JOIN  dbo.RouteStatus RTS   WITH (NOLOCK) ON RTS.[Status]=ISNULL(RT.[Status],1)   
  LEFT JOIN   dbo.[Address] CAdr   WITH (NOLOCK) ON CAdr.Addrkey=OH.BillToAddrKey  
  LEFT JOIN   dbo.[Address] SRR   WITH (NOLOCK) ON SRR.Addrkey=RT.SourceAddrkey  
  LEFT JOIN   dbo.[Address] DTR   WITH (NOLOCK) ON DTR.Addrkey=RT.DestinationAddrkey  
  LEFT JOIN   dbo.[Address] SR   WITH (NOLOCK) ON SR.Addrkey=OD.SourceAddrKey  
  LEFT JOIN   dbo.[Address] DT   WITH (NOLOCK) ON DT.Addrkey=OD.DestinationAddrKey  
  LEFT JOIN   dbo.Driver DR    WITH (NOLOCK) ON DR.DriverKey=RT.DriverKey  
  LEFT JOIN   dbo.Chassis CH    WITH (NOLOCK) ON CH.chassisKey=RT.ChassisKey   
  --LEFT JOIN   dbo.OrderDetailStatus ODS   WITH (NOLOCK) ON ODS.[Status]=OD.[Status]  
  LEFT JOIN   dbo.ContainerSize S   WITH (NOLOCK) ON S.ContainerSizeKey=OD.ContainerSizeKey   
  Left JOIN OrderDetailStatus RS  WITH (NOLOCK) ON OD.Status = RS.Status  
  Left join dbo.PickUpType PT   WITH (NOLOCK) on L.PickupTypeKey = PT.PickupTypeKey  
  LEFT JOIN dbo.ContainerDocumentCount CDC   WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey  
  Inner join #OrderDetailStatus ODS on ODS.StatusKey = OD.Status  
  lEFT jOIN [USER] u2 WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey  
  --leFT jOIN (  
  --   SELECT DISTINCT orderdetailkey, 1 AS IsHazmat FROM #ContTypes WHERE Comment='Hazard'  
  --) HZ ON od.OrderDetailKey = HZ.OrderDetailKey  
  LEFT JOIN (SELECT TOP 1 HZ1.* FROM vContainerType HZ1  WITH (NOLOCK)  
  LEFT JOIN OrderDetail OD1  WITH (NOLOCK) ON HZ1.ORDERDETAILKEY=OD1.OrderDetailKey AND HZ1.ContainerTypeKey = @HazardTypeKey) HZ ON HZ.ORDERDETAILKEY = OD.OrderDetailKey  
  LEFT JOIN (SELECT TOP 1 CTL1.* FROM ContainerTypesLink CTL1  WITH (NOLOCK)  
  LEFT JOIN OrderDetail OD1  WITH (NOLOCK) ON CTL1.OrderDetailKey=OD1.OrderDetailKey AND CTL1.IsSelected = 1) CTL ON HZ.ORDERDETAILKEY = OD.OrderDetailKey  
  --LEFT JOIN vContainerType HZ ON HZ.ORDERDETAILKEY = OD.OrderDetailKey AND HZ.ContainerTypeKey = @HazardTypeKey  
  --LEft join ContainerTypesLink CTL on OD.OrderDetailKey = CTL.OrderDetailKey and CTL.IsSelected = 1  
  LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey  
  LEFT JOIN TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey=DR.TruckTypeKey  
  LEFT JOIN SteamShipLine SL WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey  
  LEFT JOIN (select distinct ODI.OrderDetailKey,  
     CASE WHEN DRA.Description ='Reject' AND ISNULL(RTI.DriverKey,0)=0 THEN 1 --rejected  
     WHEN RTI.Status in (2,3) THEN 2 --in progress  
     WHEN RTI.Status=4 THEN 3 --driver assigned  
     WHEN RTI.Status=1 THEN 4 --pending  
     WHEN DRA.Description='Accept' THEN 5 --accept  
     ELSE 0  
     END AS RouteStatus  
     from Orderdetail ODI  WITH (NOLOCK)  
     LEFT JOIN Routes RTI  WITH (NOLOCK) ON (RTI.RouteKey=ODI.CurrentRouteKey)  
     LEFT JOIN DriverRouteAcceptance DRA WITH (NOLOCK) ON DRA.RouteKey=RTI.RouteKey) CS ON CS.OrderDetailKey=OD.OrderDetailKey   
     --AND CS.RouteStatus=@CarrierStatus  
	 --LEFT JOIN Container_GnosisData CGD WITH (NOLOCK) ON CGD.OrderDetailKey=OD.OrderDetailKey
	 OUTER APPLY (
						SELECT TOP 1 *
						FROM Container_GnosisData CGDI WITH (NOLOCK)
						WHERE CGDI.OrderDetailKey=OD.OrderDetailKey 
						)CGD
 WHERE OD.Status not in (1,11) and  RT.RouteKey = LAST_ROUTEKEY  
 AND (@PickUpDateFrom IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)  
 AND (@PickUpDateTo  IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)   
 AND (@Weekday  IS NULL OR @Weekday=''  OR   
   LEFT( (CASE WHEN RT.PickupDateFrom BETWEEN @StartDate AND @EndDate THEN upper(DATENAME(DW,RT.PickupDateFrom ) )  
      WHEN RT.PickupDateFrom<@StartDate THEN 'PAS'ELSE 'FUT' END),3)= @Weekday)  
  AND (isnull(@Customer,'') = '' OR CUS.CustName LIKE '%' + @Customer + '%')  
  AND (isnull(@OrderNo ,'') = '' OR OH.OrderNo LIKE '%' + @OrderNo + '%')  
  AND (isnull(@ContainerNo,'') = '' OR OD.ContainerNo LIKE '%' + @ContainerNo + '%')  
  AND (@PickUpDateFrom IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom>=@PickUpDateFrom)  
  AND (@PickUpDateTo  IS NULL OR RT.PickupDateFrom IS NULL OR RT.PickupDateFrom<=@PickUpDateTo)    
  AND (isnull(@PickupTypeKey,0) = 0 OR L.PickupTypeKey = @PickupTypeKey)   
  AND (isnull(@BookingNo,'') = '' OR OH.BookingNo like '%' + @BookingNo + '%')  
  AND (Isnull(@ContainerType,'') = '' OR CTl.ContainerTypeKey in (select ContainerType from #ContainerType))  
  AND (Isnull(@LegID,'') = '' OR RT.LegKey in (select LegKey from #LegKeys))  
  AND (isnull(@DriverKey,0) = 0 OR RT.DriverKey = @DriverKey)  
  AND (  ISNULL(@marketLocationKey,0) = 0 OR  OH.MarketLocationKey = @marketLocationKey )  
  AND (ISNULL(@Dispatcher,0)=0 OR RT.CarrierAssignedBy=@Dispatcher)  
  AND (ISNULL(@CarrierStatus,'')='' OR CS.RouteStatus=@CarrierStatus)  
  AND (  isnull(@SearchText ,'') = '' OR  
    OH.OrderNo like '%' +  @SearchText + '%'  OR  
    DTR.AddrName like '%' +  @SearchText + '%'  OR  
    isnull(CAdr.AddrName,'') like '%' +  @SearchText + '%'  OR  
    DT.AddrName like '%' +  @SearchText + '%'  OR  
    CH.chassisNo like '%' +  @SearchText + '%'  OR  
    OD.ContainerNo like '%' +  @SearchText + '%'  OR  
    OH.BookingNo like '%' +  @SearchText + '%'  OR  
    OH.BillOfLading like '%' +  @SearchText + '%'  OR  
    OT.OrderType like '%' +  @SearchText + '%'  OR  
    OH.BrokerRefNo like '%' +  @SearchText + '%'  OR  
    CUS.CustName like '%' +  @SearchText + '%'   
   )      
  
 ORDER BY ContainerTime, ScheduledPickupDate , ContainerNo  
  
 if(@IsDebug = 1)  
 Begin    
  select '#Data', COUNT(1) from #Data  
  SELECT * FROM #OrderDetailStatus  
    
 End  
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
  
   
  
 select   
  DispatchListResult = (  
  select *   
  from #data  
  where (isnull( @Status,0) = 0 OR @Status = Status)   
  AND (ISNULL(@IsDriverApp,0)=0 OR IsDriverApp=@IsDriverApp)  
  ORDER BY ContainerTime, ScheduledPickupDate , ContainerNo  
  for JSON AUTO  
 ),  
 DashBoardData  = (  
  Select A.Status as StatusKey, A.StatusName as Description,   
  A.Level, A.OrderBy, A.ContainerCount as DispatchCount   
  from #DashBoarData A for JSON Auto  
 )  FOR JSON PATH, without_array_wrapper  
END  