/*  
   declare @UserKey  INT=952,  
 @JsonString  VARCHAR(MAX)='{"OrderDetailStopKey":675889,"OrderStopKey":277711,"StopTypeKey":3,"StopTypeName":"Delivery","OrderDetailKey":225063,"StopAddrKey":45152,"StopTypeShortcode":"ST","StopName":"MANN WAREHOUSING INC","StopAddress":"MANN WAREHOUSING
 INC","AddressLine1":"2700 52ND STREET","AddressLine2":"","City":"Kenosha","State":"WI","ZipCode":"53140","Country":"USA","StopNumber":3,"LocationType":"Customer","DropOrLive":"D","DropOrLiveSetUserKey":512,"DropOrLiveSetDatetime":"2025-06-15T23:16:09.857
","IsFoundationStop":true,"OrderBy":3,"CreateDate":"2025-06-06T00:12:22.407","CreateUserName":"Arun Kumar","UpdateDate":"2025-06-15T23:16:09.857","UpdateUserName":"Praveen Kumar","ScheduleDeliverDate":"2025-06-18T00:01:00","ScheduleDeliveryUserKey":512,"S
cheduleDeliverySetDateTime":"2025-06-15T23:16:09.857","IsScheduleDeliveryDateExist":true,"IsUpdate":true,"SchedulePickupToDate":"2025-06-19","ScheduleDeliverToDate":"2025-06-18","ScheduleDeliveryFromTime":"00:01","SchedulePickupToTime":"23:59","ScheduleDe
liveryToTime":"12:15","IsPastSchedulePickup":false,"IsPastScheduleDelivery":false,"IsActualDeliveryDateExist":false,"IsDryRunPortSFMarked":false,"IsDryRunPortRTMarked":false,"IsDryRunCustomerMarked":false,"ShowStopDetails":false,"IsActualDeliveryEditable"
:true,"IsActualPickupEditable":true,"IsSchedulePickupEditable":false,"SchedulePickupDate":"2025-06-19T23:17:00"}',  
 @IsDebug  BIT = 1,  
 @Status   BIT = 0 ,  
 @Reason   NVARCHAR(1000) = ''   
  
 exec [Scheduler_InsertUpdateStops_v2] @UserKey,@JsonString,@IsDebug,@Status output, @Reason output  
 select @Reason,@Status  
  
 */  
  
CREATE PROCEDURE [dbo].[Scheduler_InsertUpdateStops_V2_base20251001]  
(  
 @UserKey  INT=512,  
 @JsonString  VARCHAR(MAX)='',  
 @IsDebug  BIT = 1,  
 @Status   BIT = 0 OUTPUT,  
 @Reason   NVARCHAR(1000) = '' OUTPUT  
)  
AS  
BEGIN  
 SET NOCOUNT ON;  
 SET FMTONLY OFF;  
 SET ARITHABORT ON;  
  
 IF(ISNULL(@JsonString,'')='')  
 BEGIN  
  SET @Status=0;  
  SET @Reason='Parameter not found';  
  RETURN;  
 END  
  
 DECLARE @StopName VARCHAR(100)='',  
   @StopTypeKey INT,  
   @OrderDetailKey  int  
   
 SELECT  
 OrderDetailKey  ,  
 OrderDetailStopKey ,  
 StopTypeShortcode ,  
 StopTypeKey   ,  
 StopAddrKey   ,  
 StopName   ,  
 StopNo    ,  
 LocationType  ,  
 RefNo    ,  
 SchedulePickUp,ScheduleDelivery,ActualPickUp,ActualDelivery,  
 DropOrLive, SchedulePickupToDate, ScheduleDeliverToDate,  
 SchedulePickupFromTime,SchedulePickupToTime,  
 ScheduleDeliveryFromTime,ScheduleDeliveryToTime,Is247Pickup,Is247Delivery,  
 IsDryRunPort,IsDryRunCustomer,IsBobtail ,IsEmptyReady,IsStreetTurn,IsChassisSplit, StopIndex  
 INTO #tempstopsdata  
 FROM OPENJSON(@JsonString, '$')  
 WITH (  
   OrderDetailKey   INT    '$.OrderDetailKey',  
   OrderDetailStopKey  BIGINT   '$.OrderDetailStopKey',  
   StopTypeShortcode  Varchar(5)  '$.StopTypeShortcode',  
   StopTypeKey    INT    '$.StopTypeKey',  
   StopAddrKey    INT    '$.StopAddrKey',  
   StopName    VARCHAR(100) '$.StopName',  
   StopNo     INT    '$.StopNumber',  
   LocationType   VARCHAR(100) '$.LocationType',  
   RefNo     VARCHAR(50)  '$.RefNo',  
   SchedulePickUp   DATETIME  '$.SchedulePickupDate',  
   ScheduleDelivery  DATETIME  '$.ScheduleDeliverDate',     
   ActualPickUp   DATETIME  '$.ActualPickupDate',  
   ActualDelivery   DATETIME  '$.ActualDeliveryDate',  
   DropOrLive    VARCHAR(5)  '$.DropOrLive',  
   SchedulePickupToDate DATETIME  '$.SchedulePickupToDate',  
   ScheduleDeliverToDate DATETIME  '$.ScheduleDeliverToDate',  
   SchedulePickupFromTime DATETIME  '$.SchedulePickupFromTime',  
   SchedulePickupToTime DATETIME  '$.SchedulePickupToTime',  
   ScheduleDeliveryFromTime DATETIME  '$.ScheduleDeliveryFromTime',  
   ScheduleDeliveryToTime DATETIME  '$.ScheduleDeliveryToTime',  
   Is247Pickup    BIT    '$.Is247Pickup',  
   Is247Delivery   BIT    '$.Is247Delivery',  
   IsDryRunPort   BIT    '$.IsDryRunPort',  
   IsDryRunCustomer  BIT    '$.IsDryRunCustomer',  
   IsBobtail    BIT    '$.IsBobTail',  
   IsEmptyReady   BIT    '$.IsEmpty',  
   IsStreetTurn   BIT    '$.IsStreetTurn',  
   IsChassisSplit   BIT    '$.IsChassisSplit',  
   StopIndex    INT    '$.StopIndex'  
   )  
print'geer'  
   --select * from   
 --SELECT @StopTypeName=StopTypeName FROM StopsMaster WHERE StopTypeKey=(SELECT TOP 1 StopTypeKey FROM #tempstopsdata)  
   
																															   
																																	   
  
 update #tempstopsdata set   
  SchedulePickupFromTime = '00:01',  
  SchedulePickupToTime = '23:59',  
  ScheduleDeliveryFromTime = '00:01',  
  ScheduleDeliveryToTime = '23:59'  
 where StopTypeKey in (2,4)  
  
 SELECT @StopTypeKey = StopTypeKey from StopsMaster WITH (NOLOCK) where StopTypeShortcode=(SELECT TOP 1 StopTypeShortcode FROM #tempstopsdata)  
  
 Select @StopName = Addrname from Address WITH (NOLOCK) where AddrKey = (SELECT TOP 1 StopAddrKey FROM #tempstopsdata)  
  
 SElect @OrderDetailKey = OrderDetailKey from #tempstopsdata  
  
 print 'Drop'  
  
 UPDATE TSD   
 SET TSD.StopName=A.AddrName  
 FROM #tempstopsdata TSD  
 INNER JOIN Address A WITH (NOLOCK) ON A.AddrKey=TSD.StopAddrKey  
  
 --DECLARE Cur_AddrName CURSOR FOR  
 --Select Addrname from Address   
 --WHERE AddrKey = (SELECT TOP 1 StopAddrKey FROM #tempstopsdata)  
  
 --OPEN Cur_AddrName  
 --IF @@CURSOR_ROWS > 0  
 --BEGIN  
 -- FETCH NEXT FROM Cur_AddrName  
 -- INTO @StopName  
  
  IF(@IsDebug = 1)  
  BEGIN  
   SELECT * FROM #tempstopsdata  
   SELECT @StopName StopName  
  END  
  
  --WHILE @@Fetch_status = 0  
  --BEGIN  
  
   --UPDATE #tempstopsdata SET SchedulePickUp=CASE WHEN SchedulePickUp IS NULL THEN   
   --        CAST(SchedulePickUp AS datetime) + CAST(SchedulePickupFromTime AS datetime) ELSE SchedulePickUp END,  
   --        SchedulePickupToDate=CASE WHEN SchedulePickupToDate IS NULL THEN   
   --        CAST(SchedulePickupToDate AS datetime) + CAST(SchedulePickupToTime AS datetime) ELSE SchedulePickupToDate END,  
   --        ScheduleDelivery=CASE WHEN ScheduleDelivery IS NULL THEN  
   --        CAST(ScheduleDelivery AS datetime) + CAST(ScheduleDeliveryFromTime AS datetime) ELSE ScheduleDelivery END,  
   --        ScheduleDeliverToDate=CASE WHEN ScheduleDeliverToDate IS NULL THEN  
   --        CAST(ScheduleDeliverToDate AS datetime) + CAST(ScheduleDeliveryToTime AS datetime) ELSE ScheduleDeliverToDate END  
  print '0'
   UPDATE #tempstopsdata SET --SchedulePickUp=CASE WHEN SchedulePickUp IS NULL THEN CAST(SchedulePickUp AS datetime) + CAST(SchedulePickupFromTime AS datetime) ELSE SchedulePickUp END,  
       --SchedulePickupToDate=CASE WHEN SchedulePickupToDate IS NULL THEN CAST(SchedulePickupToDate AS datetime) + CAST(SchedulePickupToTime AS datetime) ELSE SchedulePickupToDate END,  
       SchedulePickUp=CASE WHEN SchedulePickupFromTime IS NOT NULL THEN DATEADD(MINUTE,   
            DATEPART(HOUR, SchedulePickupFromTime) * 60 + DATEPART(MINUTE, SchedulePickupFromTime),   
            CAST(CONVERT(DATE, SchedulePickUp) AS DATETIME)) ELSE SchedulePickUp END,  
       SchedulePickupToDate=DATEADD(MINUTE,   
            DATEPART(HOUR, SchedulePickupToTime) * 60 + DATEPART(MINUTE, SchedulePickupToTime),   
            CAST(CONVERT(DATE, SchedulePickUp) AS DATETIME)),  
       ScheduleDelivery=DATEADD(MINUTE,   
            DATEPART(HOUR, ScheduleDeliveryFromTime) * 60 + DATEPART(MINUTE, ScheduleDeliveryFromTime),   
            CAST(CONVERT(DATE, ScheduleDelivery) AS DATETIME)),  
            --Update ScheduleDeliverToDate column,  
       ScheduleDeliverToDate= DATEADD(MINUTE,   
             DATEPART(HOUR, ScheduleDeliveryToTime) * 60 + DATEPART(MINUTE, ScheduleDeliveryToTime),   
             CAST(CONVERT(DATE, ScheduleDelivery) AS DATETIME))  
  
   IF(@IsDebug = 1)  
   BEGIN  
    SELECT * FROM #tempstopsdata  
    SELECT @StopName StopName  
   END  
  print '1'
   INSERT INTO  OrderDetailStops  
      (OrderDetailKey,StopTypeKey,StopName,StopNameSetUserKey,StopNameSetDateTime,  
       StopAddrKey,StopNumber,LocationType,RefNo,  
       SchedulePickupDate, SchedulePickupUserKey,SchedulePickupSetDateTime,  
       ActualPickupDate,ActualPickupUserKey, ActualPickupSetDateTime,   
       ScheduleDeliveryDate, ScheduleDeliveryUserKey,ScheduleDeliverySetDateTime,  
       ActualDeliveryDate, ActualDeliveryUserKey,ActualDeliverySetDateTime,  
       DropOrLive,DropOrLiveSetUserKey, DropOrLiveSetDatetime,  
       SchedulePickupDateTo, SchedulePickupToUserKey, SchedulePickupToSetDateTime,  
       ScheduleDeliveryDateTo, ScheduleDeliveryToUserKey, ScheduleDeliveryToSetDateTime,  
       Is247Pickup,Is247PickupMarkedby,Is247PickupMarkedDate,  
       CreateDate,CreateUserKey,  
       IsDryRunPort,DryRunPortSetUserKey, DryRunPortSetDateTime,  
       IsDryRunCustomer,DryRunCustomerSetUserKey, DryRunCustomerSetDateTime,  
       IsBobTail,BobtailSetUserKey, BobtailSetDateTime,  
       IsEmpty,EmptySetUserKey, EmptySetDateTime,  
       IsStreetTurn,StreetSturnSetUserKey, StreetSturnSetDateTime,  
       IsChassisSplit,ChassisSplitSetUserKey, ChassisSplitSetDateTime,  
       Is247Delivery,Is247DeliveryMarkedBy,Is247DeliveryMarkedDate, StopIndex  
       )  
   SELECT   OrderDetailKey,@StopTypeKey,StopName,@UserKey,GETDATE(),  
       StopAddrKey,StopNo,LocationType,RefNo,  
       SchedulePickUp, case when SchedulePickUp is null then null else @UserKey end,  
       case when SchedulePickUp is null then null else GETDATE() end,  
       REPLACE(ActualPickUp,'T',' ') , case when ActualPickUp is null then null else @UserKey end,  
       case when ActualPickUp is null then null else GETDATE() end,  
       ScheduleDelivery, case when ScheduleDelivery is null then null else @UserKey end,  
       case when ScheduleDelivery is null then null else GETDATE() end,  
       REPLACE(ActualDelivery,'T',' ') , case when ActualDelivery is null then null else @UserKey end,  
       case when ActualDelivery is null then null else GETDATE() end,  
       DropOrLive,case when isnull(DropOrLive,'') = ''  then null else @UserKey end ,  
       case when isnull(DropOrLive,'') = ''  then null else GETDATE() end,  
       SchedulePickupToDate,case when SchedulePickupToDate is null then null else @UserKey end ,  
       case when SchedulePickupToDate is null then null else GETDATE() end,  
       --REPLACE(ScheduleDeliverToDate,'T',' '),  
       ScheduleDeliverToDate,case when ScheduleDeliverToDate is null then null else @UserKey end ,  
       case when ScheduleDeliverToDate is null then null else GETDATE() end,  
       Is247Pickup, case when isnull(Is247Pickup,0) = 0  then null else @UserKey end,  
       case when isnull(Is247Pickup,0) = 0  then null else GETDATE() end,  
       GETDATE(),@UserKey,  
       IsDryRunPort,case when isnull(IsDryRunPort,0) = 0  then null else @UserKey end ,  
       case when isnull(IsDryRunPort,0) = 0  then null else GETDATE() end,  
       IsDryRunCustomer,case when isnull(IsDryRunCustomer,0) = 0  then null else @UserKey end ,  
       case when isnull(IsDryRunCustomer,0) = 0  then null else GETDATE() end,  
       IsBobtail,case when isnull(IsBobtail,0) = 0  then null else @UserKey end ,  
       case when isnull(IsBobtail,0) = 0  then null else GETDATE() end,  
       IsEmptyReady,case when isnull(IsEmptyReady,0) = 0  then null else @UserKey end ,  
       case when isnull(IsEmptyReady,0) = 0  then null else GETDATE() end,  
       IsStreetTurn,case when isnull(IsStreetTurn,0) = 0  then null else @UserKey end ,  
       case when isnull(IsStreetTurn ,0) = 0  then null else GETDATE() end,  
       IsChassisSplit,case when isnull(IsChassisSplit,0) = 0  then null else @UserKey end ,  
       case when isnull(IsChassisSplit,0) = 0  then null else GETDATE() end,  
       Is247Delivery,case when isnull(Is247Delivery,0) = 0  then null else @UserKey end ,  
       case when isnull(Is247Delivery,0) = 0  then null else GETDATE() end,  
       StopIndex  
   FROM   #tempstopsdata   
   WHERE ISNULL(OrderDetailStopKey,0) = 0  
  
  print '2'
   EXEC Scheduler_InsertStopsAuditLogs @UserKey,'',0,0,''  
  

  print '2-1'
   UPDATE OD  
   SET  StopTypeKey=@StopTypeKey,StopAddrKey=TD.StopAddrKey,StopNumber=TD.StopNo,  
     LocationType=TD.LocationType,RefNo=TD.RefNo,StopName=TD.StopName,  
     StopNameSetUserKey=case when TD.StopName is null then null when OD.StopName=TD.StopName then StopNameSetUserKey else @UserKey end,  
     StopNameSetDateTime=case when TD.StopName is null then null when OD.StopName=TD.StopName then StopNameSetDateTime else GETDATE() end ,  
     SchedulePickupDate=TD.SchedulePickUp,  
     SchedulePickupUserKey=case when TD.SchedulePickUp is null then null else @UserKey end,  
     SchedulePickupSetDateTime=case when Td.SchedulePickUp is null then null else GETDATE() end ,  
  
     SchedulePickupDateTo=TD.SchedulePickupToDate,  
     SchedulePickupToUserKey = case when TD.SchedulePickupToDate is null then null else @UserKey end,  
     SchedulePickupToSetDateTime = case when TD.SchedulePickupToDate is null then null else GETDATE() end,  
  
     ActualPickupDate= REPLACE(TD.ActualPickUp,'T',' '), -- REPLACE(substring(TD.ActualPickUp,1,19),'T',' '),
     ActualPickupUserKey=case when TD.ActualPickUp is null then null else @UserKey end,  
     ActualPickupSetDateTime= case when TD.ActualPickUp is null then null else GETDATE() end ,   
  
     ScheduleDeliveryDate=TD.ScheduleDelivery,   
     ScheduleDeliveryUserKey=case when TD.ScheduleDelivery is null then null else @UserKey end,  
     ScheduleDeliverySetDateTime=case when TD.ScheduleDelivery is null then null else GETDATE() end ,  
  
     ScheduleDeliveryDateTo=TD.ScheduleDeliverToDate,  
     ScheduleDeliveryToUserKey = case when TD.ScheduleDeliverToDate is null then null else @UserKey end,  
     ScheduleDeliveryToSetDateTime = case when TD.ScheduleDeliverToDate is null then null else GETDATE() end,  
  
     ActualDeliveryDate=REPLACE(TD.ActualDelivery,'T',' '), --  REPLACE(substring(TD.ActualDelivery,1,19),'T',' '),
     ActualDeliveryUserKey=case when TD.ActualDelivery is null then null else @UserKey end,  
     ActualDeliverySetDateTime=case when TD.ActualDelivery is null then null else GETDATE() end ,  
  
     DropOrLive=TD.DropOrLive,   
     DropOrLiveSetDatetime=Case when isnull(TD.DropOrLive,'') = '' then null else GETDATE() end,  
     DropOrLiveSetUserKey=Case when isnull(TD.DropOrLive,'') = '' then null else @UserKey end ,  
  
     Is247Pickup=TD.Is247Pickup,  
     Is247PickupMarkedby= Case when isnull(TD.Is247Pickup,0) = 0 then null else @UserKey end ,  
     Is247PickupMarkedDate=Case when isnull(TD.Is247Pickup,0) = 0 then null else GETDATE() end,  
  
     UpdateDate=GETDATE(),UpdateUserKey=@UserKey,  
  
     IsDryRunPort=TD.IsDryRunPort,  
     DryRunPortSetDateTime=Case when isnull(TD.IsDryRunPort,0) = 0 then null else GETDATE() end ,  
     DryRunPortSetUserKey=Case when isnull(TD.IsDryRunPort,0) = 0 then null else @UserKey end,  
  
     IsDryRunCustomer=TD.IsDryRunCustomer,  
     DryRunCustomerSetDateTime=Case when isnull(TD.IsDryRunCustomer,0) = 0 then null else GETDATE() end,  
     DryRunCustomerSetUserKey= Case when isnull(TD.IsDryRunCustomer,0) = 0 then null else @UserKey end ,  
  
     IsBobtail=TD.IsBobtail,  
     BobtailSetDateTime=Case when isnull(TD.IsBobtail,0) = 0 then null else GETDATE() end,  
     BobtailSetUserKey= Case when isnull(TD.IsBobtail ,0) = 0 then null else @UserKey end ,  
  
     IsEmpty=TD.IsEmptyReady,  
     EmptySetDateTime=case when isnull(TD.IsEmptyReady,0) = 0 then null else GETDATE() end,  
     EmptySetUserKey=case when isnull(TD.IsEmptyReady ,0) = 0 then null else @UserKey end ,  
  
     IsStreetTurn=TD.IsStreetTurn,  
     StreetSturnSetDateTime=case when isnull(TD.IsStreetTurn,0) = 0 then null else GETDATE() end,  
     StreetSturnSetUserKey=case when isnull(TD.IsStreetTurn,0) = 0 then null else @UserKey end ,  
  
     IsChassisSplit=TD.IsChassisSplit,  
     ChassisSplitSetDateTime= case when isnull(TD.IsChassisSplit,0) = 0 then null else GETDATE() end,  
     ChassisSplitSetUserKey= case when isnull(TD.IsChassisSplit,0) = 0 then null else @UserKey end ,  
  
     Is247Delivery=TD.Is247Delivery,  
     Is247DeliveryMarkedBy= case when isnull(TD.Is247Delivery ,0) = 0 then null else @UserKey end ,  
     Is247DeliveryMarkedDate=case when isnull(TD.Is247Delivery ,0) = 0 then null else GETDATE() end,  
     StopIndex = TD.StopIndex  
   FROM OrderDetailStops OD   
   INNER JOIN #tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey   
     and od.OrderDetailStopKey = Td.OrderDetailStopKey  
  print '3'
 -- END  
 --END  
 --CLOSE Cur_AddrName  
 --DEALLOCATE Cur_AddrName  
 Declare @DryRunCount int = 0  
 Select @DryRunCount = Count(1) from #tempstopsdata where isnull(IsDryRunPort,0) = 1 OR ISNULL(IsDryRunCustomer,0) = 1  
 if(@DryRunCount > 0)  
 Begin  
	print '4'
   INSERT INTO  OrderDetailStops  
      (OrderDetailKey,StopTypeKey,StopName,StopAddrKey,LocationType,  
       DropOrLive,DropOrLiveSetUserKey, DropOrLiveSetDatetime,  
       CreateDate,CreateUserKey  
       )  
   SELECT   OrderDetailKey,@StopTypeKey,StopName,StopAddrKey,LocationType,  
       DropOrLive,case when isnull(DropOrLive,'') = ''  then null else @UserKey end ,  
       case when isnull(DropOrLive,'') = ''  then null else GETDATE() end,  
       GETDATE(),@UserKey  
   FROM   #tempstopsdata   
   WHERE   isnull(IsDryRunPort,0) = 1 OR ISNULL(IsDryRunCustomer,0) = 1  
  
   declare @RowsInserted_1 int = 0  
   select @RowsInserted_1 = @@ROWCOUNT  
   if( @RowsInserted_1 > 0 )  
   Begin  
	print '5'
    update A set StopNumber = B.NewStopNumber  
    from OrderDetailStops A  
    inner join (  
     select ROW_NUMBER() Over (Order by OrderDetailKey, SM.StoptypeKey,ODS.SchedulePickupDate) as NewStopNumber, SM.StopTypeShortcode, OrderDetailStopKey  
     from OrderDetailStops ODS  
     inner join StopsMaster SM on ODS.StopTypeKey = SM.StopTypeKey  
     where ODs.orderdetailkey = @OrderDetailKey  
    ) B on A.OrderDetailStopKey = B.OrderDetailStopKey  
   End  
 End  
 if(@IsDebug = 1)  
 Begin  
  SElect @OrderDetailKey as OrderDetailKey  
 End  
 print 'exec'  
   
 DROP TABLE #tempstopsdata  
  
   
END  