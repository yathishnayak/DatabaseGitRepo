CREATE PROCEDURE [dbo].[Dispatch_SaveStopsData]  
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
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipFromData,0,@Status,@Reason  
  END  
  IF(ISNULL(@AFStopOffData,'')<>'')  
  BEGIN  
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@AFStopOffData,0,@Status,@Reason  
  END  
  IF(ISNULL(@ShipToData,'')<>'')  
  BEGIN  
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipToData,0,@Status,@Reason  
  END  
  IF(ISNULL(@ATStopOffData,'')<>'')  
  BEGIN  
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ATStopOffData,0,@Status,@Reason  
  END  
  IF(ISNULL(@ReturnToData,'')<>'')  
  BEGIN  
   EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ReturnToData,0,@Status,@Reason  
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
  SET @Status=0;  
  SET @Reason='Failed to save data';  
  ROLLBACK TRAN;  
 END CATCH  
END  