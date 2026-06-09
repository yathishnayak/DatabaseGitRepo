/* 
DECLARE 
	@UserKey INT=29,
	@JSONString NVARCHAR(MAX)= 
	'{"OrderType":"","IsGnosisTracking":false,"JCTPaidDemurrage":false,"ShipFromData":{"OrderDetailStopKey":815327,"OrderStopKey":343839,"StopTypeKey":1,"StopTypeName":"Pickup","OrderDetailKey":262220,"StopAddrKey":47039,"StopTypeShortcode":"SF","StopName":"ITS","StopAddress":"ITS","AddressLine1":"1281 PIER G EAST","AddressLine2":"","City":"LONG BEACH","State":"CA","ZipCode":"90802","Country":"US ","StopNumber":1,"LocationType":"Port","SchedulePickupDate":"2025-09-30T20:00:00","ActualPickupDate":"2025-10-01T00:24:07.130","SchedulePickupUserKey":264,"ActualPickupUserKey":284,"SchedulePickupSetDateTime":"2025-09-30T06:40:09.810","ActualPickupSetDateTime":"2025-10-01T00:24:07.210","RefNo":"0930-47383","IsFoundationStop":true,"OrderBy":1,"UpdateDate":"2025-09-30T06:40:09.810","UpdateUserName":"Margaret  Yoeth ","IsScheduleDeliveryDateExist":false,"IsUpdate":true,"SchedulePickupToDate":"2025-09-30","SchedulePickupFromTime":"20:00","SchedulePickupToTime":"21:00","IsPastSchedulePickup":false,"IsPastScheduleDelivery":false,"IsActualDeliveryDateExist":true,"IsDryRunPortSFMarked":false,"IsDryRunPortRTMarked":false,"IsDryRunCustomerMarked":false,"ShowStopDetails":false,"IsActualDeliveryEditable":true,"IsActualPickupEditable":true,"DateMisMatch":false},"ShipToData":{"OrderDetailStopKey":815328,"OrderStopKey":343840,"StopTypeKey":3,"StopTypeName":"Delivery","OrderDetailKey":262220,"StopAddrKey":47806,"StopTypeShortcode":"ST","StopName":"Alto Systems","StopAddress":"Alto Systems","AddressLine1":"13874 NORTON AVENUE","AddressLine2":"","City":"CHINO","State":"CA","ZipCode":"91710","Country":"US ","StopNumber":3,"LocationType":"Consignee","IsFoundationStop":true,"OrderBy":3,"UpdateDate":"2025-09-30T06:40:10.093","UpdateUserName":"Margaret  Yoeth ","IsScheduleDeliveryDateExist":false,"IsUpdate":true,"IsPastSchedulePickup":false,"IsPastScheduleDelivery":false,"IsActualDeliveryDateExist":false,"IsDryRunPortSFMarked":false,"IsDryRunPortRTMarked":false,"IsDryRunCustomerMarked":false,"ShowStopDetails":false,"ScheduleDeliverDate":"2025-10-02T07:00:00","ScheduleDeliveryFromTime":"7:0","ScheduleDeliveryToTime":"11:00","IsActualDeliveryEditable":true,"IsActualPickupEditable":true,"DropOrLive":"D","SchedulePickupDate":null,"SchedulePickupToTime":null,"Is247ReceivingPickup":false,"DateMisMatch":false,"IsScheduleDeliveryEditable":false},"AFStopOffData":[{"OrderDetailStopKey":818902,"StopTypeKey":2,"StopTypeName":"Stop","OrderDetailKey":262220,"StopAddrKey":48915,"StopTypeShortcode":"AF","StopName":"JCT-Chino","StopAddress":"JCT-Chino","AddressLine1":"11818 E End Ave","AddressLine2":" ","City":"Chino","State":"CA","ZipCode":"91710","Country":"USA","StopNumber":2,"LocationType":"Yard","IsFoundationStop":false,"OrderBy":2,"CreateDate":"2025-09-30T06:40:09.813","CreateUserName":"Margaret  Yoeth ","IsDryRunPort":false,"IsBobTail":false,"IsEmpty":false,"IsStreetTurn":false,"IsChassisSplit":false,"ScheduleDeliverDate":"2025-09-30T00:01:00","ScheduleDeliveryUserKey":264,"ScheduleDeliverySetDateTime":"2025-09-30T06:40:09.813","ActualDeliveryDate":"2025-10-01T01:11:17.903","ActualDeliveryUserKey":284,"ActualDeliverySetDateTime":"2025-10-01T01:11:17.957","IsScheduleDeliveryDateExist":true,"IsUpdate":true,"ScheduleDeliverToDate":"2025-09-30","ScheduleDeliveryFromTime":"00:01","ScheduleDeliveryToTime":"23:59","IsPastSchedulePickup":false,"IsPastScheduleDelivery":false,"IsActualDeliveryDateExist":true,"IsDryRunCustomer":false,"IsDryRunPortSFMarked":false,"IsDryRunPortRTMarked":false,"IsDryRunCustomerMarked":false,"ShowStopDetails":false,"SchedulePickupDate":"2025-10-02T07:00:00","SchedulePickupToTime":"11:00","IsActualDeliveryEditable":true,"IsActualPickupEditable":true,"DateMisMatch":false}],"ATStopOffData":[]}',
	@Status			BIT=0, @IsDebug		BIT = 1, @Reason			VARCHAR(100)=''
	EXec [Dispatch_SaveStopsData_BASE20250110] @UserKey,@JSONString,@IsDebug, @Status OUTPUT,@Reason OUTPUT
	Select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Dispatch_SaveStopsData_BASE20250110]  
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
  
 DECLARE @ShipFromData  NVARCHAR(MAX),@ShipToData  NVARCHAR(MAX),@ReturnToData  NVARCHAR(MAX),  
   @AFStopOffData NVARCHAR(MAX), @ATStopOffData NVARCHAR(MAX),  
   @OrderDetailKey INT=0  
  
 SELECT @ShipFromData=ShipFromData,@ShipToData=ShipToData,@ReturnToData=ReturnToData,  
     @AFStopOffData=AFStopOffData, @ATStopOffData=ATStopOffData  
 FROM OPENJSON(@JsonString, '$')  
 WITH(   
   ShipFromData    NVARCHAR(MAX) '$.ShipFromData' AS JSON,  
   ShipToData     NVARCHAR(MAX) '$.ShipToData' AS JSON,  
   ReturnToData    NVARCHAR(MAX) '$.ReturnToData' AS JSON,  
   AFStopOffData    NVARCHAR(MAX) '$.AFStopOffData' AS JSON,  
   ATStopOffData    NVARCHAR(MAX) '$.ATStopOffData' AS JSON  
  )  
 BEGIN TRAN  
 BEGIN TRY  
  SELECT  
   @OrderDetailKey=OrderDetailKey  
   FROM OPENJSON(@ShipFromData, '$')  
   WITH (  
   OrderDetailKey   INT    '$.OrderDetailKey'  
   )  
  
  IF(ISNULL(@OrderDetailKey,0)=0)  
  BEGIN  
   SELECT  
  @OrderDetailKey=OrderDetailKey  
  FROM OPENJSON(@ShipToData, '$')  
  WITH (  
   OrderDetailKey   INT    '$.OrderDetailKey'  
   )  
  END  
  
    
  IF(ISNULL(@ShipFromData,'')<>'')  
  BEGIN  
	PRINT @ShipFromData
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipFromData,@IsDebug,@Status,@Reason  
  END  
  IF(ISNULL(@AFStopOffData,'')<>'')  
  BEGIN  
	print @AFStopOffData
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@AFStopOffData,@IsDebug,@Status,@Reason  
  END  
  IF(ISNULL(@ShipToData,'')<>'')  
  BEGIN  
	print @ShipToData
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipToData,@IsDebug,@Status,@Reason  
  END  
  IF(ISNULL(@ATStopOffData,'')<>'')  
  BEGIN  
	print @ATStopOffData
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ATStopOffData,@IsDebug,@Status,@Reason  
  END  
  IF(ISNULL(@ReturnToData,'')<>'')  
  BEGIN  
	PRINT @ReturnToData
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ReturnToData,@IsDebug,@Status,@Reason  
  END  
    
  
  print 'Before Linking'  
    Exec [RoutesAndStopsLinking] @OrderDetailKey,0, 0  
  print 'After Linking'  
 --/// ********************** update routes data  
  UPDATE RT  
     SET   
   SourceAddrKey = ODs.StopAddrKey,  
         PickupDateFrom = ODS.SchedulePickupDate ,  
         PickupDateTo = ODS.SchedulePickupDateTo ,  
         ScheduledPickupDate =  ODS.SchedulePickupDate ,  
   ActualDeparture = case when  ODS.ActualPickupDate is not null then ODS.ActualPickupDate else RT.ActualDeparture end , 
    ActualDepartureUpdateDate = case when  ODS.ActualPickupDate is not null and ODS.ActualPickupDate <> Rt.ActualDeparture 
			then GETDATE() else RT.ActualDepartureUpdateDate end ,
	ActualArrivalUpdateMethod = case when  ODS.ActualPickupDate is not null and ODS.ActualPickupDate <> Rt.ActualDeparture 
			then 'JCB User' else RT.ActualArrivalUpdateMethod end ,
	ActualArrivalUpdateUser = case when  ODS.ActualPickupDate is not null and ODS.ActualPickupDate <> Rt.ActualDeparture 
			then @UserKey else RT.ActualArrivalUpdateUser end ,
   --ConfirmationNo = ODS.RefNo,  
   LastUpdateDate = GETDATE(),  
   UpdateUserKey = @UserKey  
  From Routes RT   
  inner join OrderDetailStops ODS WITH (NOLOCK) on RT.routekey = ODS.FromRouteKey  
     WHERE ODS.OrderDetailKey = @OrderDetailKey  
  print 'upd - 1'  
  
  UPDATE RT  
     SET   
   DestinationAddrKey = ODs.StopAddrKey,  
         DeliveryDateFrom = ODS.ScheduleDeliveryDate ,  
         DeliveryDateTo = ODS.ScheduleDeliveryDateTo ,  
   LastUpdateDate = GETDATE(),  
   ActualArrival = case when  ODS.ActualDeliveryDate is not null then ODS.ActualDeliveryDate else RT.ActualArrival end ,
   ActualArrivalUpdateDate = case when  ODS.ActualDeliveryDate is not null and ODS.ActualDeliveryDate <> Rt.ActualArrival 
			then GETDATE() else RT.ActualArrivalUpdateDate end ,
	ActualArrivalUpdateMethod = case when  ODS.ActualDeliveryDate is not null and ODS.ActualDeliveryDate <> Rt.ActualArrival 
			then 'JCB User' else RT.ActualArrivalUpdateMethod end ,
	ActualArrivalUpdateUser = case when  ODS.ActualDeliveryDate is not null and ODS.ActualDeliveryDate <> Rt.ActualArrival 
			then @UserKey else RT.ActualArrivalUpdateUser end ,
   UpdateUserKey = @UserKey,  
   IsBobtail = ODS.IsBobTail,  
   BobtailSetUser = ODs.BobtailSetUserKey,  
   BobtailSetDate = ODs.BobtailSetDateTime,  
   ISEmpty = ODs.IsEmpty,  
   EmptySetUser = ODs.EmptySetUserKey,  
   EmptySetDate = ODs.EmptySetDateTime,  
   isStreetTurn = ODs.IsStreetTurn,  
   StreetTurnSetUser = ODs.StreetSturnSetUserKey,  
   StreetTurnSetDate = ODS.StreetSturnSetDateTime,  
   DelConfirmationNo = ODS.RefNo,  
   IsChassisSplit = ODS.IsChassisSplit,  
   ChassisSplitBy = ODS.ChassisSplitSetUserKey,  
   ChassisSplitDate = ODS.ChassisSplitSetDateTime,  
   LegType = case when ODS.DropOrLive =  'L' then 'Live'   
     when ODS.DropOrLive = 'D' then 'Drop'  
     else null end  
  From Routes RT   
  inner join OrderDetailStops ODS WITH (NOLOCK) on RT.routekey = ODS.ToRouteKey  
     WHERE ODS.OrderDetailKey = @OrderDetailKey  
  print 'upd - 2'  
  
  exec Scheduler_RecreateLegID @OrderDetailKey  
  SET @Status=1;  
  SET @Reason='Success';  
 COMMIT TRAN;  
 END TRY  
 BEGIN CATCH  
  print error_message();  
  PRINT error_line()
  PRINT ERROR_PROCEDURE()
  SET @Status=0;  
  SET @Reason='Failed to save data';  
  ROLLBACK TRAN;  
 END CATCH  
END  