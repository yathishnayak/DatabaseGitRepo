    
CREATE PROCEDURE [dbo].[RoutesAndStopsLinking]  -- [RoutesAndStopsLinking] 230206, 0,1     
(      
 @OrderDetailKey     INT = 0,      
 @IsDelete   BIT = 0,    
 @IsDebug   BIT = 0      
)      
AS      
BEGIN      
 SET NOCOUNT ON;      
 SET FMTONLY OFF;      
 SET ARITHABORT ON;      
   
      
 --ALTER TABLE Routes Add  FromODStopKey bigint, ToODStopKey  bigint, LegID  varchar(50)      
 DECLARE        
     --@OrderDetailKey      INT = 178010,      
     @OrderKey       INT = 0,      
     @OrderTypeKey      INT = 0,      
     @OrderNo       VARCHAR(50) = '',      
     @Containerno      VARCHAR(50) = '',      
     @TotalStopsCount     INT = 0,      
     @ReadyStopsCount     INT = 0,      
     @RoutesCount      INT = 0,      
     @DryRunPortStopKey     INT = 0,      
     @DryRunCustomerStopKey INT = 0      
      
      
 SELECT @OrderKey = OH.orderKey,      
     @OrderNo  = OH.OrderNo,      
     @OrderTypeKey  = OD.OrderTypeKey,      
     @Containerno   = OD.ContainerNo      
 FROM OrderDetail OD WITH (NOLOCK)       
 INNER JOIN ORderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.OrderKey      
 WHERE ORderDetailKey = @OrderDetailKey      
       
 SELECT @TotalStopsCount = COUNT(1)      
 FROM ORderDetailStops ODS WITH (NOLOCK)      
 WHERE OrderDetailKey = @OrderDetailKey      
       
 SELECT @ReadyStopsCount = COUNT(1)      
 FROM ORderDetailStops ODS WITH (NOLOCK)      
 WHERE OrderDetailKey = @OrderDetailKey AND isnull(StopAddrKey,0) > 0 AND isnull(LocationType,'') <> ''      
       
 SELECT @DryRunPortStopKey = OrderDetailStopKey      
 FROM ORderDetailStops ODS WITH (NOLOCK)      
 WHERE OrderDetailKey = @OrderDetailKey AND isnull(IsDryRunPort,0) = 1      
       
 SELECT @DryRunCustomerStopKey = OrderDetailStopKey      
 FROM ORderDetailStops ODS WITH (NOLOCK)      
 WHERE OrderDetailKey = @OrderDetailKey AND isnull(IsDryRunCustomer,0) = 1      
       
       
 SELECT @RoutesCount = COUNT(1)      
 FROM Routes RT WITH (NOLOCK)      
 WHERE OrderDetailKey = @OrderDetailKey      
       
 IF(@IsDebug = 1)      
    BEGIN      
  SELECT       
      @OrderDetailKey        AS  OrderDetailKey,      
   @OrderKey              AS  OrderKey,      
   @OrderTypeKey          AS  OrderTypeKey,      
   @OrderNo               AS  OrderNo,      
   @Containerno           AS  Containerno,      
   @TotalStopsCount       AS  TotalStopsCount,      
   @ReadyStopsCount       AS  ReadyStopsCount,      
   @RoutesCount           AS  RoutesCount,      
   @DryRunPortStopKey     AS  DryRunPortStopKey,      
   @DryRunCustomerStopKey AS  DryRunCustomerStopKey      
    END      
       
 CREATE TABLE #StopMap      
 (      
  FromStopNo   INT,      
  FromODSStopKey  INT,      
  FromRouteKey  INT,      
  FromPickupDate  Datetime,      
  ToStopNo   INT,      
  ToODSStopKey  INT,      
  ToRouteKey   INT,      
  ToDeliveryDate  DateTime,      
  IsRouteMatching  BIT DEFAULT  0      
 )      
      
 -- ********************************************* Initial setups      
 -- ********************************************* UPDATE MISSING LOCATION TYPE      
 update ODS set LocationType = OS.LocationType      
 --select *      
 from orderdetailstops ODS      
 inner join OrderStops OS on ODS.OrderStopKey = OS.OrderStopKey      
 where ODS.locationType  is null and OS.LocationType is not null      
      
 update ODS set LocationType = A.LocationType      
 --select *      
 from ORderDetailStops ODS      
 inner join (      
 SELECT AddrKey, 'Yard' as LocationType       
 FROM YARD Y WITH (NOLOCK)       
 inner join OrderDetailStops ODS WITH (NOLOCK) on Y.AddrKey = ODs.StopAddrKey and ODs.OrderDetailKey = @OrderDetailKey      
 WHERE ODS.LocationType is null      
 union ALL      
 SELECT AddrKey, 'Port' as LocationType       
 FROM ShippingPortTerminals P WITH (NOLOCK)       
 inner join OrderDetailStops ODS WITH (NOLOCK) on P.AddrKey = ODs.StopAddrKey and ODs.OrderDetailKey = @OrderDetailKey      
 WHERE ODS.LocationType is null      
 union ALL      
 SELECT C.AddrKey, 'Customer' as LocationType       
 FROM CustomerAddress C  WITH (NOLOCK)       
 inner join OrderDetailStops ODS WITH (NOLOCK) on C.AddrKey = ODs.StopAddrKey and ODs.OrderDetailKey = @OrderDetailKey      
 WHERE ODS.LocationType is null      
 ) A on ODs.StopAddrKey = A.AddrKey      
where ODs.OrderDetailKey = @OrderDetailKey and ODs.LocationType is null      
      
       
 -- ******************************************** UPDATE STOPS WHERE SCHEDULE MISSING AND ACTUAL EXISTS      
      
 update ODS set       
  SchedulePickupDate = case when SchedulePickupDate is null then ActualPickupDate else SchedulePickupDate end      
 --Select *       
 from orderdetailstops ODS      
 where orderdetailkey = @OrderDetailKey and  SchedulePickupDate is null  and ActualPickupDate is not null      
      
 update ODS set       
  ScheduleDeliveryDate = case when ScheduleDeliveryDate is null then ActualDeliveryDate else ScheduleDeliveryDate end      
 --Select *       
 from orderdetailstops ODS      
 where orderdetailkey = @OrderDetailKey and  ScheduleDeliveryDate is null  and ActualDeliveryDate is not null      
      
 -- ******************************************** DELETE ROUTES NOT MAPPING TO STOPS     
 if(@IsDelete = 1)    
 Begin    
  Update OrderExpense     
  SET Routekey = null, OrderDetailKey = @OrderDetailKey    
  WHERE Routekey in (      
    select Rt.RouteKey       
    from Routes RT WITH (NOLOCK)      
    LEFT JOIN OrderDetailStops ODSF WITH (NOLOCK) on Rt.FromODStopKey = ODSF.OrderDetailStopKey      
    LEFT join ORderDetailStops ODST WITH (NOLOCK) on RT.ToODStopKey = ODST.OrderDetailStopKey      
    where RT.orderDetailkey = @OrderDetailKey and (ODSF.FromRouteKey is null OR ODST.ToRouteKey is null)       
     and RT.Status not in (3, 5)      
  )--addded by praveen for foreign key ref issue      
      
  Delete from ROUTES where Routekey in (      
   select Rt.RouteKey       
   from Routes RT WITH (NOLOCK)      
   LEFT JOIN OrderDetailStops ODSF WITH (NOLOCK) on Rt.FromODStopKey = ODSF.OrderDetailStopKey      
   LEFT join ORderDetailStops ODST WITH (NOLOCK) on RT.ToODStopKey = ODST.OrderDetailStopKey      
   where RT.orderDetailkey = @OrderDetailKey and (ODSF.FromRouteKey is null OR ODST.ToRouteKey is null)      
  ) and Status not in (3, 5)      
     
  update ODS SET FromRouteKey = null      
  from OrderDetailStops ODS       
  LEFT JOIN ROUTES RT WITH (NOLOCK) on  ODS.OrderDetailKey = RT.OrderDetailKey  and  ODS.FromRouteKey = RT.RouteKey      
  where ODS.OrderDetailKey = @OrderDetailKey and Rt.RouteKey is null      
      
  Update ODS SET ToRouteKey = null      
  from OrderDetailStops ODS       
  LEFT Join  ROUTES RT WITH (NOLOCK) on ODS.OrderDetailKey = RT.OrderDetailKey and  ODS.ToRouteKey = Rt.RouteKey      
  where ODS.OrderDetailKey = @OrderDetailKey  and Rt.RouteKey is null      
  END    
    
  /*    
 -- ***************************Update the Stop Numbers      
 update A set StopNumber = B.NewStopNumber      
 from OrderDetailStops A      
 inner join (      
  select ROW_NUMBER() Over (Order by OrderDetailKey, SM.StoptypeKey,ODS.SchedulePickupDate) as NewStopNumber, SM.StopTypeShortcode, OrderDetailStopKey      
  from OrderDetailStops ODS      
  inner join StopsMaster SM on ODS.StopTypeKey = SM.StopTypeKey      
  where ODs.orderdetailkey = @OrderDetailKey      
 ) B on A.OrderDetailStopKey = B.OrderDetailStopKey      
      
  */    
 -- ***************************Update the Dry Run Mismatch      
 Update RT SET IsDryRun = 1,      
  DryRunSetDate = isnull(ODs.DryRunPortSetDateTime, ODS.DryRunCustomerSetDateTime),      
  DryRunSetUser = ISNULL(ODS.DryRunPortSetUserKey, ODS.DryRunCustomerSetUserKey),      
  DryRunType = 1      
 --Select *      
 from OrderDetailStops ODS WITH (NOLOCK)      
 inner join Routes RT WITH (NOLOCK) on ODs.FromRouteKey = RT.RouteKey      
 where (ISNULL(ODs.IsDryRunPort,0) = 1 ) and isnull(RT.IsDryRun ,0) = 0      
  and ODS.orderdetailkey = @OrderDetailKey      
       
 Update RT SET IsDryRun = 1,      
  DryRunSetDate = isnull(ODs.DryRunPortSetDateTime, ODS.DryRunCustomerSetDateTime),     
  DryRunSetUser = ISNULL(ODS.DryRunPortSetUserKey, ODS.DryRunCustomerSetUserKey),      
  DryRunType = 2      
 --Select *      
 from OrderDetailStops ODS WITH (NOLOCK)      
 inner join Routes RT WITH (NOLOCK) on ODs.ToRouteKey = RT.RouteKey      
 where ( ISNULL(ODS.IsDryRunCustomer,0) = 1 ) and isnull(RT.IsDryRun ,0) = 0      
  and ODS.orderdetailkey = @OrderDetailKey      
      
 -- ********************************************* GET THE @ReadyStopsCount > 0      
 SELECT ODS.*, SM.StopTypeShortcode      
 INTO #ReadyStops      
 FROM OrderDetailStops ODS  WITH (NOLOCK)      
 inner join StopsMaster SM WITH (NOLOCK) on ODS.StopTypeKey = SM.StopTypeKey      
 inner join ORderDetail OD WITH (NOLOCK) on ODS.OrderDetailKey = OD.OrderDetailKey      
 inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.orderKey      
 inner join OrderdetailStops ODST WITH (NOLOCK)       
  on ODS.OrderDetailKey = ODST.OrderDetailKey and ODST.StopTypeKey = 1       
   and isnull(ODST.IsDryRunPort,0) = 0 and isnull(ODST.IsDryRunCustomer,0) = 0        
   and ODST.SchedulePickupDate is not null      
 WHERE  ODS.OrderDetailKey = @OrderDetailKey       
   AND isnull(ODS.StopAddrKey,0) > 0 AND isnull(ODS.LocationType,'') <> ''      
   AND  isnull(ODS.IsDryRunPort,0) = 0 AND isnull(ODS.IsDryRunCustomer,0) = 0      
 ORDER BY ODS.StopNumber      
      
 UPDATE #ReadyStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')      
 UPDATE #ReadyStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')      
       
 INSERT INTO #stopMap (FromStopNo, FromODSStopKey, FromRouteKey, FromPickupDate)      
 SELECT StopNumber, OrderDetailStopKey, FromRouteKey, SchedulePickupDate      
 FROM #ReadyStops      
       
 UPDATE A SET       
  ToStopNo = B.StopNumber,      
  ToDeliveryDate = B.ScheduleDeliveryDate ,      
  ToODSStopKey = B.OrderDetailStopKey,      
  ToRouteKey = B.ToRouteKey      
 FROM #StopMap A      
 INNER JOIN (Select *, lag(stopnumber) over ( order by orderdetailKey, stopnumber) as PRevStopNumber       
 from #ReadyStops) B ON A.FromStopNo = B.PRevStopNumber      
       
 DELETE FROM #StopMap WHERE ToStopNo IS NULL      
 IF(@IsDebug = 1)      
    BEGIN      
  SELECT '#StopMap' AS StopMap,* from #StopMap ORDER BY FromStopNo      
 End      
 -- ********************************************* GET THE @IsDryRunPort = 1      
 Declare @DryRnPortCount int = 0, @DryRunCustomerCount int = 0      
 SELECT ODS.*, SM.StopTypeShortcode      
 INTO #DryRunPortStops      
 FROM OrderDetailStops ODS  WITH (NOLOCK)      
 inner join StopsMaster SM WITH (NOLOCK) on ODS.StopTypeKey = SM.StopTypeKey      
 inner join ORderDetail OD WITH (NOLOCK) on ODS.OrderDetailKey = OD.OrderDetailKey      
 inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.orderKey      
 inner join OrderdetailStops ODST WITH (NOLOCK)       
  on ODS.OrderDetailKey = ODST.OrderDetailKey and ODST.StopTypeKey = 1       
   and isnull(ODST.IsDryRunPort,0) = 0 and isnull(ODST.IsDryRunCustomer,0) = 0        
   --and ODST.SchedulePickupDate is not null      
 WHERE   ods.OrderDetailKey = @OrderDetailKey       
   AND ISNULL(ODS.StopAddrKey,0) > 0 AND ISNULL(ODS.LocationType,'') <> ''      
   AND  ISNULL(ODS.IsDryRunPort,0) = 1  and ODS.FromRouteKey  is null      
 ORDER BY ODS.StopNumber      
       
 Select @DryRnPortCount = count(1) from #DryRunPortStops      
 -- ********************************************* GET THE @IsDryRunCustomer = 1      
 SELECT ODS.*, SM.StopTypeShortcode      
 INTO #DryRunCustomerStops      
 FROM OrderDetailStops ODS  WITH (NOLOCK)      
 inner join StopsMaster SM WITH (NOLOCK) on ODS.StopTypeKey = SM.StopTypeKey      
 inner join ORderDetail OD WITH (NOLOCK) on ODS.OrderDetailKey = OD.OrderDetailKey      
 inner join OrderHeader OH WITH (NOLOCK) on OD.OrderKey = OH.orderKey      
 inner join OrderdetailStops ODST WITH (NOLOCK)       
  on ODS.OrderDetailKey = ODST.OrderDetailKey and ODST.StopTypeKey = 1       
   and isnull(ODST.IsDryRunPort,0) = 0 and isnull(ODST.IsDryRunCustomer,0) = 0        
   --and ODST.SchedulePickupDate is not null      
 WHERE   ods.OrderDetailKey = @OrderDetailKey       
   AND ISNULL(ODS.StopAddrKey,0) > 0 AND ISNULL(ODS.LocationType,'') <> ''      
   AND  ISNULL(ODS.IsDryRunCustomer,0) = 1 and ODS.FromRouteKey is null      
 ORDER BY ODS.StopNumber      
       
 SElect @DryRunCustomerCount = count(1) from #DryRunCustomerStops      
       
 print '@DryRunCustomerCount'      
 print @DryRunCustomerCount      
      
 if(@DryRnPortCount > 0)      
 Begin      
  declare @DryRunPortStop varchar(5) =''      
  select @DryRunPortStop = StopTypeShortcode       
  from #DryRunPortStops A      
      
  UPDATE #DryRunPortStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')      
  UPDATE #DryRunPortStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')      
      
  if(@DryRunPortStop = 'SF')      
  Begin      
   declare @DR_SF_Routekey int = 0      
   INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo,       
      DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status,       
      ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,        
      LegType, FromODStopKey, ToODStopKey, IsDryRun, DryRunSetDate, DryRunSetUser, DryRunType)      
   SELECT @OrderDetailKey, @OrderKey, LegKey, F.StopNumber, F.StopAddrKey AS SourceAddrKey,       
    F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo,       
    T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo,       
    F.locationType AS FromLocation,T.LocationType AS  ToLocation,       
    T.StopAddrKey AS DestinationAddrKey, 1 AS Status,       
    F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture,       
    T.CreateUserKey,  T.CreateDate,       
    'L', --CASE WHEN isnull(T.DropOrLive,'L') = 'L' THEN 'Live' ELSE 'Drop' END AS LegType,      
    F.OrderDetailStopKey, T.OrderDetailStopKey, 1, Getdate(), F.CreateUserKey, 1      
   FROM #DryRunPortStops F       
   INNER JOIN #ReadyStops T ON T.StopTypeShortcode = 'ST'      
   INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation      
    --AND L.Statuskey = 1      
   --INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey      
   where F.StopTypeShortcode ='SF' and T.StopTypeShortcode = 'ST'      
      
   select @DR_SF_Routekey = SCOPE_IDENTITY()      
         
   update ODS set FromRouteKey = @DR_SF_Routekey, ToRouteKey = @DR_SF_Routekey      
   from OrderDetailStops ODS      
   inner join #DryRunPortStops DS on ODs.OrderDetailStopKey = DS.OrderDetailStopKey      
   where DS.StopTypeShortcode = 'SF'      
  end      
      
  if(@DryRunPortStop = 'RT')      
  Begin      
   declare @DR_RT_Routekey int = 0      
   INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo,       
      DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status,       
      ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,        
      LegType, FromODStopKey, ToODStopKey, IsDryRun, DryRunSetDate, DryRunSetUser, DryRunType)      
   SELECT @OrderDetailKey, @OrderKey, LegKey, F.StopNumber, F.StopAddrKey AS SourceAddrKey,       
    F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo,       
    T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo,       
    F.locationType AS FromLocation,T.LocationType AS  ToLocation,       
    T.StopAddrKey AS DestinationAddrKey, 1 AS Status,       
    F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture,       
    T.CreateUserKey,  T.CreateDate,       
    'L', --CASE WHEN isnull(T.DropOrLive,'L') = 'L' THEN 'Live' ELSE 'Drop' END AS LegType,      
    F.OrderDetailStopKey, T.OrderDetailStopKey, 1, Getdate(), F.CreateUserKey, 1      
   FROM #ReadyStops  F       
   INNER JOIN #DryRunPortStops T ON 1=1      
   INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation      
    --AND L.Statuskey = 1      
   --INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey      
   where F.StopTypeShortcode = 'ST' and T.StopTypeShortcode ='RT'      
      
   select @DR_RT_Routekey = SCOPE_IDENTITY()      
      
   update ODS set FromRouteKey = @DR_RT_Routekey, ToRouteKey = @DR_RT_Routekey      
 from OrderDetailStops ODS      
   inner join #DryRunPortStops DS on ODs.OrderDetailStopKey = DS.OrderDetailStopKey      
   where DS.StopTypeShortcode = 'RT'      
  end      
 End      
 if(@DryRunCustomerCount > 0)      
 Begin      
  declare @DryRunCustomerStop varchar(5) =''      
  select @DryRunCustomerStop = StopTypeShortcode       
  from #DryRunCustomerStops A      
      
  UPDATE #DryRunCustomerStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')      
  UPDATE #DryRunCustomerStops SET LocationType = REPLACE( REPLACE(LocationType,'Customer','Consignee'), 'Shipper','Consignee')      
      
      
  if(@DryRunCustomerStop = 'ST')      
  Begin      
   declare @DR_ST_Routekey int = 0      
   INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo,       
      DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status,       
      ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,        
      LegType, FromODStopKey, ToODStopKey, IsDryRun, DryRunSetDate, DryRunSetUser, DryRunType)      
   SELECT @OrderDetailKey, @OrderKey, LegKey, F.StopNumber, F.StopAddrKey AS SourceAddrKey,       
    F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo,       
    T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo,       
    F.locationType AS FromLocation,T.LocationType AS  ToLocation,       
    T.StopAddrKey AS DestinationAddrKey, 1 AS Status,       
    F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture,       
    T.CreateUserKey,  T.CreateDate,       
    'L', --CASE WHEN isnull(T.DropOrLive,'L') = 'L' THEN 'Live' ELSE 'Drop' END AS LegType,      
    F.OrderDetailStopKey, T.OrderDetailStopKey, 1, Getdate(), F.CreateUserKey, 2      
   FROM #DryRunCustomerStops T       
   INNER JOIN #ReadyStops F ON T.StopNumber   = F.stopnumber  - 1      
   INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation      
      
   select @DR_ST_Routekey = SCOPE_IDENTITY()      
      
   update ODS set FromRouteKey = @DR_ST_Routekey, ToRouteKey = @DR_ST_Routekey      
   from OrderDetailStops ODS      
   inner join #DryRunCustomerStops DS on ODs.OrderDetailStopKey = DS.OrderDetailStopKey      
   where DS.StopTypeShortcode = 'ST'      
  end      
      
        
 End      
      
 If(@IsDebug = 1)      
 Begin      
  SELECT '#ReadyStops' AS ReadyStops, * FROM #ReadyStops ORDER BY StopNumber      
  SELECT '#DryRunPortStops' AS DryRunPortStops, * FROM #DryRunPortStops  ORDER BY StopNumber      
  SELECT '#DryRunCustomerStops' AS DryRunCustomerStops, * FROM #DryRunCustomerStops  ORDER BY StopNumber      
  Select @DR_SF_Routekey as DR_SF_Routekey, @DR_ST_Routekey as DR_ST_Routekey, @DR_RT_Routekey as DR_RT_Routekey      
 End      
      
 -- ********************************************* GET THE ROUTES DATA      
 /*    
 DELETE FROM OrderExpense WHERE Routekey in (      
  select Routekey      
 from Routes RT      
 LEFT join OrderDetailStops ODs on RT.OrderDetailKey = ODs.OrderDetailKey and Rt.RouteKey = ODs.FromRouteKey      
 where RT.orderdetailkey = @OrderDetailKey and ODs.FromRouteKey is null and RT.Status not in (3, 5))--addded by praveen for foreign key ref issue      
      
 Delete From Routes where Routekey in (      
 select Routekey      
 from Routes RT      
 LEFT join OrderDetailStops ODs on RT.OrderDetailKey = ODs.OrderDetailKey and Rt.RouteKey = ODs.FromRouteKey      
 where RT.orderdetailkey = @OrderDetailKey and ODs.FromRouteKey is null and RT.Status not in (3, 5))      
  */    
 SELECT RouteKey, RT.LegNo, RT.LegKey,  L.FromLocation as LegFromLocation, L.ToLocation LegToLocation,       
  RT.FromLocation RTFromLocation, RT.ToLocation  RTToLocation, RT.LegID, Rt.FromODStopKey, Rt.ToODStopKey      
 INTO #Routes      
 FROM Routes RT WITH (NOLOCK)      
 INNER JOIN Leg L WITH (NOLOCK) ON RT.legkey = L.LegKey      
 where ORderDetailKey = @OrderDetailKey and isnull(IsDryRun,0) = 0 and isnull(IsManual,0) = 0      
       
 If(@IsDebug = 1)      
 Begin      
  SELECT '#Routes' AS Routes,* FROM #Routes      
 End      
       
 -- ############################################# VERIFY THE DATA      
       
      
       
 DECLARE @IsRoutesExists BIT = 0,      
   @RouteToBeCount INT = 0,      
   @RouteCount  INT = 0,      
   @IsRoutesCountMatching BIT = 0,      
   @IsDryRunPortMatching BIT = 0,      
   @IsDryRunCustomerMAtching BIT = 0      
       
 SELECT @IsRoutesExists = CASE WHEN  COUNT(1) > 0 THEN 1 ELSE 0 END FROM #Routes      
 SELECT @RouteToBeCount = COUNT(1) FROM #StopMap where ToDeliveryDate is not null      
 SELECT @RouteCount = COUNT(1)  FROM #Routes      
 SELECT @IsRoutesCountMatching = CASE WHEN @RouteToBeCount = @RouteCount THEN 1 ELSE 0 END      
       
 IF(@IsDebug = 1)      
    BEGIN      
  SELECT @IsRoutesExists AS IsRoutesExists,@RouteCount AS RouteCount, @RouteToBeCount AS RouteToBeCount,      
   @IsRoutesCountMatching AS IsRoutesCountMatching      
 End      
      
 IF(@RouteCount = 0 AND @RouteToBeCount > 0)      
 BEGIN      
  DECLARE @RowsInserted INT = 0      
  INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo,       
     DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status,       
     ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,        
     LegType, FromODStopKey, ToODStopKey)      
  SELECT  @OrderDetailKey, @OrderKey, LegKey, A.FromStopNo, F.StopAddrKey AS SourceAddrKey,       
   F.SchedulePickupDate AS PickupDateFrom, F.SchedulePickupDateTo AS PickupDateTo,       
   T.ScheduleDeliveryDate AS  DeliveryDateFrom, T.ScheduleDeliveryDateTo AS  DeliveryDateTo,       
   F.locationType AS FromLocation,T.LocationType AS  ToLocation,       
   T.StopAddrKey AS DestinationAddrKey, 1 AS Status,       
   F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate AS ScheduledDeparture,       
   T.CreateUserKey,  T.CreateDate,      
   CASE WHEN isnull(T.DropOrLive,'L') = 'L' THEN 'Live' ELSE 'Drop' END AS LegType,      
   A.FromODSStopKey, A.ToODSStopKey      
  FROM #StopMap a      
  INNER JOIN #ReadyStops F ON a.FromStopNo = F.StopNumber AND A.FromODSStopKey = F.OrderDetailStopKey      
  INNER JOIN #ReadyStops T ON a.ToStopNo = T.StopNumber AND A.ToODSStopKey = T.OrderDetailStopKey      
  INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation      
   --and case when isnull(T.DropOrLive,'L') = 'L' then 'Live' else 'Drop' end = f.DropOrLive      
  --INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey      
  ORDER BY A.FromStopNo      
        
  SET @RowsInserted = @@ROWCOUNT       
  If(@IsDebug = 1)      
  Begin      
   SELECT  @RowsInserted AS RowsInserted      
  End      
  IF(@RowsInserted > 0)      
  BEGIN      
   UPDATE ODS SET FromRouteKey = null, ToRouteKey = null       
   from OrderDetailStops ODS      
   inner join #ReadyStops RS on ODs.OrderDetailStopKey = RS.OrderDetailStopKey      
   WHERE ODS.OrderDetailkey = @OrderDetailKey       
       
   UPDATE A SET FromRouteKey = Rt.RouteKey, ToRouteKey = Rt.Routekey      
   FROM #StopMap A      
   INNER JOIN Routes RT ON A.FromODSStopKey = Rt.FromODStopKey AND A.ToODSStopKey = Rt.ToODStopKey      
       
   UPDATE ODS SET FromRouteKey = SM.FromRouteKey      
   FROM OrderDetailStops ODS      
   INNER JOIN #StopMap SM ON ODs.OrderDetailStopKey = SM.FromODSStopKey      
       
   UPDATE ODS SET ToRouteKey = SM.ToRouteKey      
   FROM OrderDetailStops ODS      
   INNER JOIN #StopMap SM ON ODs.OrderDetailStopKey = SM.ToODSStopKey      
       
   UPDATE RT SET FromODStopKey = SM.FromODSStopKey, ToODStopKey = SM.ToODSStopKey      
   FROM Routes RT      
   INNER JOIN #StopMap SM ON Rt.routekey = SM.Fromroutekey AND Rt.RouteKey = SM.ToRouteKey     
       
   IF(@IsDebug = 1)      
   BEGIN      
    SELECT * FROM #StopMap      
    SELECT * FROM orderDetailStops WHERE OrderDetailKey =@OrderDetailKey ORDER BY StopNumber      
    SELECT * FROM Routes WHERE OrderDetailKey = @OrderDetailKey ORDER BY LegNo      
   end      
  End      
        
 End      
       
 IF( @RouteCount > 0 AND @RouteToBeCount > 0)      
 BEGIN      
  UPDATE A SET IsRouteMatching =  0     
  FROM #StopMap A      
  where ToRouteKey is null    
       
  IF(@IsDebug = 1)      
  BEGIN      
   SELECT 'Line 501',* FROM #StopMap      
  end      
      
  DECLARE @RouteNotMatchingCount INT = 0      
  SELECT @RouteNotMatchingCount = count(1) FROM #StopMap WHERE IsRouteMatching = 0      
  IF(@RouteNotMatchingCount > 0)      
  BEGIN      
    SELECT * INTO #PrevRoutes FROM Routes WHERE orderDetailKey = @OrderDetailKey      
    IF(@IsDebug = 1)      
    BEGIN      
     SELECT 'Line 511', * FROM #PrevRoutes      
    END      
  /*    
    DELETE OrderExpense      
    WHERE Routekey  in      
    (select Routekey from Routes RT      
     inner join #StopMap SM on Rt.RouteKey = SM.FromRouteKey  and IsRouteMatching = 0       
     where RT.Status not in (3, 5)      
     )      
      
    DELETE FROM Routes  WHERE orderdetailkey = @OrderDetailKey AND        
     routekey IN (SELECT FromRouteKey FROM #StopMap WHERE IsRouteMatching = 0)       
     and  Status not in (3, 5)      
  */    
       
   Create table #IdentityPKs (RouteKey int, FromODSStopKey int, ToODSStopKey int )    
    
    DECLARE @RowsInserted2 INT = 0      
    
    INSERT INTO routes ( OrderDetailKey, OrderKey, LegKey, LegNo, SourceAddrKey, PickupDateFrom, PickupDateTo,       
     DeliveryDateFrom, DeliveryDateTo, FromLocation, ToLocation, DestinationAddrKey, Status,       
     ScheduledPickupDate, ScheduledDeparture,  CreateUserKey,  CreateDate,        
     LegType, FromODStopKey, ToODStopKey)     
 OUTPUT INSERTED.RouteKey, INSERTED.FromODStopKey, INSERTED.ToODStopKey INTO #IdentityPKs    
 SELECT  @OrderDetailKey, @OrderKey, LegKey, A.FromStopNo, F.StopAddrKey as SourceAddrKey,       
     F.SchedulePickupDate as PickupDateFrom, F.SchedulePickupDateTo as PickupDateTo,       
     T.ScheduleDeliveryDate as  DeliveryDateFrom, T.ScheduleDeliveryDateTo as  DeliveryDateTo,       
     F.locationType as FromLocation,T.LocationType as  ToLocation,       
     T.StopAddrKey as DestinationAddrKey, 1 as Status,       
     F.SchedulePickupDate  ScheduledPickupDate, F.SchedulePickupDate as ScheduledDeparture,       
     T.CreateUserKey,  T.CreateDate, case when isnull(T.DropOrLive,'L') = 'L' then 'Live' else 'Drop' end as LegType,      
     A.FromODSStopKey, A.ToODSStopKey      
    FROM #StopMap a      
    INNER JOIN #ReadyStops F ON a.FromStopNo = F.StopNumber AND A.FromODSStopKey = F.OrderDetailStopKey      
    INNER JOIN #ReadyStops T ON a.ToStopNo = T.StopNumber AND A.ToODSStopKey = T.OrderDetailStopKey      
    INNER JOIN LegFiltered L ON F.LocationType = L.FromLocation AND T.LocationType = L.ToLocation       
     --and case when isnull(T.DropOrLive,'L') = 'L' then 'Live' else 'Drop' end = f.DropOrLive      
    --INNER JOIN LegType LT ON L.LegTypeKey = LT.LegtypeKey AND LT.OrderTypeKey = @OrderTypeKey      
    WHERE a.toroutekey is null --a.IsRouteMatching = 0      
    ORDER BY A.FromStopNo      
       
       
    
    SET @RowsInserted2 = @@ROWCOUNT       
          
    IF(@RowsInserted2 > 0)      
    Begin      
     UPDATE ODS SET FromRouteKey = null, ToRouteKey = null       
     from OrderDetailStops ODS      
     inner join #ReadyStops RS on ODs.OrderDetailStopKey = RS.OrderDetailStopKey      
     WHERE ODS.OrderDetailkey = @OrderDetailKey       
       
       
     UPDATE A SET FromRouteKey = Rt.RouteKey, ToRouteKey = Rt.Routekey      
     FROM #StopMap A      
     INNER JOIN Routes RT ON A.FromODSStopKey = Rt.FromODStopKey AND A.ToODSStopKey = Rt.ToODStopKey      
    
  update A set fromRoutekey = ToRouteKey    
  from #StopMap A    
  where A.FromRouteKey  is null    
    
     UPDATE ODS SET FromRouteKey = SM.FromRouteKey      
     FROM OrderDetailStops ODS      
     INNER JOIN #StopMap SM ON ODs.OrderDetailStopKey = SM.FromODSStopKey      
       
     UPDATE ODS SET ToRouteKey = SM.ToRouteKey      
     FROM OrderDetailStops ODS      
     INNER JOIN #StopMap SM ON ODS.OrderDetailStopKey = SM.ToODSStopKey      
       
     UPDATE RT SET     
  FromODStopKey = SM.FromODSStopKey,     
  ToODStopKey = SM.ToODSStopKey ,    
  LegNo = FromStopNo    
     FROM Routes RT      
     INNER JOIN #StopMap SM ON Rt.routekey = SM.Fromroutekey --AND Rt.RouteKey = SM.ToRouteKey      
       
     IF(@IsDebug = 1)      
     BEGIN      
  SELECT '#IdentityPKs', * FROM #IdentityPKs    
  SELECT '#StopMap',* FROM #StopMap  order by FromStopNo     
  SELECT 'orderDetailStops',OrderDetailStopKey,FromRouteKey,ToRouteKey, * FROM orderDetailStops WHERE OrderDetailKey =@OrderDetailKey ORDER BY StopNumber      
  SELECT 'Routes',RouteKey, FromODStopKey,ToODStopKey,* FROM Routes WHERE OrderDetailKey = @OrderDetailKey ORDER BY LegNo      
     END      
    END      
       
    DROP TABLE #PrevRoutes      
  END      
        
 END      
      
 -- ******************************************** SET SCHEDULER TO CONFIRM STATUS      
 Declare @FinalRouteCount int = 0,      
   @OrderDetailStatus smallint = 0,      
   @CurrentRouteKey int = 0,      
   @CurrentLegNo  int = 0,      
   @FirstRouteKey  int = 0,      
   @IsCurrentRouteInvalid bit = 1      
      
 select @OrderDetailStatus = Status, @CurrentLegNo = CurrentLegNo, @CurrentRouteKey = CurrentRouteKey        
 from OrderDetail OD WITH(NOLOCK) where ORderdetailkey = @OrderDetailKey      
 select @FinalRouteCount = count(1) from Routes where orderdetailkey = @OrderDetailKey      
 select top 1 @FirstRouteKey = routekey from Routes where OrderDetailkey = @OrderDetailKey and LegNo = 1      
      
 select @IsCurrentRouteInvalid = 0  from Routes RT WITH (NOLOCK) where Routekey = @CurrentRouteKey      
      
 select @FirstRouteKey = Routekey,@CurrentRouteKey = RouteKey, @CurrentLegNo = Legno from (      
 select ROW_NUMBER() over(order by status desc, legno) as FirstOpenRoute, *      
 from routes      
 where Orderdetailkey = @OrderDetailKey and Status<> 5       
 ) a where  FirstOpenRoute = 1      
      
 if(@OrderDetailStatus in (0,1,2,3) and @FinalRouteCount > 0)      
 Begin      
  update OrderDetail set Status = 2      
  where OrderDetailKey = @OrderDetailKey      
        
  update ORderDetail set CurrentRouteKey = @FirstRouteKey, CurrentLegNo = @CurrentLegNo ,       
   TotalLegs = @FinalRouteCount      
  where ORderDetailKey = @OrderDetailKey      
 End      
 else if (@IsCurrentRouteInvalid = 1)      
 Begin      
  update ORderDetail set CurrentRouteKey = @FirstRouteKey, CurrentLegNo = @CurrentLegNo ,       
   TotalLegs = @FinalRouteCount      
  where ORderDetailKey = @OrderDetailKey      
 End      
 -- ********************************************* CLOSING STEPS      
 DROP TABLE #ReadyStops      
 DROP TABLE #DryRunPortStops      
 DROP TABLE #DryRunCustomerStops      
 DROP TABLE #StopMap      
 DROP TABLE #Routes      
END 