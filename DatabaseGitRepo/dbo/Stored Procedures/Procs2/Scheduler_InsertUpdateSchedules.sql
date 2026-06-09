
/*  
   
 declare @UserKey  INT=512,  
 @JsonString  VARCHAR(MAX)='{"IsGnosisTracking":false,"OrderDetailKey":230265,"OrderTypeKey":1,"BookingNo":"","CustRefNo":"FLEX-3099633A-7195624","CSRKey":40,"MBL":"ONEYSH5FV4804600","GnosisData":{"MBL":"ONEYSH5FV4804600","SSLKey":0,"SizeTypeKey":9,"Hold":0,"Vessel":"ONE FRONTIER","ETA":"2025-06-19T17:00:00","StatusKey":9,"Available":0,"HoldNote":"","OrderDetailKey":230265},"IsConfirm":true,"ShipFromData":{"OrderDetailStopKey":169387,"OrderStopKey":142443,"StopTypeKey":1,"StopTypeName":"Pickup","OrderDetailKey":230265,"StopAddrKey":29512,"StopTypeShortcode":"SF","StopName":"ITS-LB 234-ONLY USE","StopAddress":"ITS-LB 234","AddressLine1":"1281 PIER G WAY","AddressLine2":"","City":"Long Beach","State":"CA","ZipCode":"90802","Country":"USA","StopNumber":1,"LocationType":"Port","StatusKey":1,"IsFoundationStop":true,"OrderBy":1,"CreateDate":"2025-06-18T02:43:13.960","CreateUserName":"Lissette Magana","IsDeleted":false,"IsScheduleDeliveryDateExist":false,"IsUpdate":true,"IsPastSchedulePickup":false,"IsPastScheduleDelivery":false,"IsActualDeliveryDateExist":false,"IsDryRunPortSFMarked":false,"IsDryRunPortRTMarked":false,"IsDryRunCustomerMarked":false,"ShowStopDetails":false,"SchedulePickupDate":"2025-06-26T11:00","SchedulePickupToTime":"12:00","IsActualDeliveryEditable":true,"IsActualPickupEditable":true,"IsSchedulePickupEditable":false},"ShipToData":{"OrderDetailStopKey":423665,"StopTypeKey":3,"StopTypeName":"Delivery","OrderDetailKey":230265,"StopAddrKey":30770,"StopTypeShortcode":"ST","StopName":"FLUIDRA DC WEST","StopAddress":"FLUIDRA DC WEST","AddressLine1":"19319 Harvill Ave","AddressLine2":"","City":"Perris","State":"CA","ZipCode":"92570","Country":"USA","StopNumber":3,"LocationType":"Consignee","StatusKey":1,"IsFoundationStop":true,"OrderBy":3,"CreateDate":"2025-06-18T02:43:18.630","CreateUserName":"Lissette Magana","IsDeleted":false,"IsScheduleDeliveryDateExist":false,"IsUpdate":true,"IsPastSchedulePickup":false,"IsPastScheduleDelivery":false,"IsActualDeliveryDateExist":false,"IsDryRunPortSFMarked":false,"IsDryRunPortRTMarked":false,"IsDryRunCustomerMarked":false,"ShowStopDetails":false,"IsActualDeliveryEditable":true,"IsActualPickupEditable":true},"AFStopOffData":[{"OrderDetailStopKey":0,"showAddressChange":false,"ShowStopDetails":true,"IsUpdate":true,"ShowSchedulePickup":false,"ShowScheduleDelivery":false,"IsScheduleDeliveryDateExist":false,"IsSchedulePickupEditable":false,"IsScheduleDeliveryEditable":false,"IsActualPickupEditable":true,"IsActualDeliveryEditable":true,"editPickup":false,"editDelivery":false,"editReturn":false,"editStops":false,"IsPastSchedulePickup":false,"IsPastScheduleDelivery":false,"Is247ReceivingPickup":false,"Is247ReceivingDelivery":false,"IsActualDeliveryDateExist":false,"IsChassisSplit":false,"IsDryRunCustomer":false,"IsBobTail":false,"IsEmpty":false,"IsDryRunPort":false,"IsStreetTurn":false,"StopTypeShortcode":"AF","StopName":"JCT-Ontario","StopTypeName":"Stop","LocationType":"Yard","StopAddrKey":44906,"OrderDetailKey":230265,"City":"Ontario","State":"CA","ZipCode":"91761","Country":"USA","AddressLine1":"13519 S Grove Ave Ontario, CA","ScheduleDeliverDate":"2025-06-26T11:00","ScheduleDeliveryFromTime":"00:01","ScheduleDeliveryToTime":"23:59","StopNumber":2}],"ATStopOffData":[]}',  
 @IsDebug  BIT = 1,  
 @Status   BIT = 0 ,  
 @Reason   NVARCHAR(1000) = ''   
  
 exec Scheduler_InsertUpdateSchedules @UserKey,@JsonString,@IsDebug,@Status output, @Reason output  
 select @Reason,@Status  
  
*/  
CREATE PROCEDURE [dbo].[Scheduler_InsertUpdateSchedules]  
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
 
 /* Adding the next block just to retrun twithout saving - To be removed later 
 Begin
	SET @Status=0;  
	SET @Reason='Test Failure - to Stop processing';  
	RETURN;  
 End
 */

 IF(ISNULL(@JsonString,'')='')  
 BEGIN  
  SET @Status=0;  
  SET @Reason='Parameter not found';  
  RETURN;  
 END  
 --** Main Object **--  
 DECLARE @ContainerNo VARCHAR(20) = '',@OrderDetailKey INT = 0,@OrderTypeKey INT = 0,@PriorityKey INT = 0,@BookingNo VARCHAR(100) = '',  
   @CustRefNo VARCHAR(100) = '',@LFD DATETIME,@IsTMF BIT,@IsCTF BIT,@IsContainerSizeCheckOff BIT,@GnosisData NVARCHAR(MAX),  
   @ShipFromData  NVARCHAR(MAX),@ShipToData  NVARCHAR(MAX),@ReturnToData  NVARCHAR(MAX),@MBL NVARCHAR(50),@SenderInfo VARCHAR(300) = '',  
   @AFStopOffData NVARCHAR(MAX), @ATStopOffData NVARCHAR(MAX),@IsConfirm  BIT=0, @CSRKey INT=0,@JCTPaidDemurrage BIT=0  ,
   @ConsigneeKey INT, @PTTChecked BIT
   --@Consignee NVARCHAR(400)
  
 SELECT @ContainerNo=ContainerNo,@OrderDetailKey = OrderDetailKey,@OrderTypeKey=OrderTypeKey,@PriorityKey=PriorityKey,  
     @BookingNo=BookingNo,@CustRefNo=CustRefNo,@IsTMF=IsTMF,@IsCTF=IsCTF,  
     @IsContainerSizeCheckOff=IsContainerSizeCheckOff,@MBL=MBL,@GnosisData=GnosisData,@ShipFromData=ShipFromData,  
     @ShipToData=ShipToData,@ReturnToData=ReturnToData,@AFStopOffData=AFStopOffData,  
     @ATStopOffData=ATStopOffData,@IsConfirm=IsConfirm, @CSRKey=CSRKey,@JCTPaidDemurrage=JCTPaidDemurrage,@SenderInfo=SenderInfo ,
	 @ConsigneeKey=ConsigneeKey,@PTTChecked = PTTChecked
	 --@Consignee=Consignee
 FROM OPENJSON(@JsonString, '$')  
 WITH(   
   ContainerNo				VARCHAR(20)		'$.ContainerNo',  
   OrderDetailKey			INT				'$.OrderDetailKey',  
   OrderTypeKey				INT				'$.OrderTypeKey',  
   PriorityKey				INT				'$.PriorityKey',  
   BookingNo				VARCHAR(100)	'$.BookingNo',  
   CustRefNo				VARCHAR(100)	'$.CustRefNo',  
   IsTMF					BIT				'$.IsTMF',  
   IsCTF					BIT				'$.IsCTF',  
   IsContainerSizeCheckOff  BIT				'$.IsContainerSizeCheckOff',  
   MBL						VARCHAR(100)	'$.MBL',  
   GnosisData				NVARCHAR(MAX)	'$.GnosisData' AS JSON,  
   ShipFromData				NVARCHAR(MAX)	'$.ShipFromData' AS JSON,  
   ShipToData				NVARCHAR(MAX)	'$.ShipToData' AS JSON,  
   ReturnToData				NVARCHAR(MAX)	'$.ReturnToData' AS JSON,  
   AFStopOffData			NVARCHAR(MAX)	'$.AFStopOffData' AS JSON,  
   ATStopOffData			NVARCHAR(MAX)	'$.ATStopOffData' AS JSON,  
   IsConfirm				BIT				'$.IsConfirm',  
   CSRKey					INT				'$.CSRKey',  
   JCTPaidDemurrage			BIT				'$.JCTPaidDemurrage',  
   SenderInfo				NVARCHAR(300)	'$.SenderInfo'  ,
   ConsigneeKey				INT				'$.ConsigneeKey'  ,
   --Consignee     NVARCHAR(400) '$.Consignee'
   PTTChecked				BIT				'$.PTTChecked'	
  )  
   
 BEGIN TRAN  
 BEGIN TRY  
  UPDATE  OrderDetail  
  SET  OrderTypeKey  = @OrderTypeKey,  
    PriorityKey   = @PriorityKey,  
    BookingNo   = @BookingNo,  
    CustRefNo   = @CustRefNo,  
    CSRKey    = @CSRKey,  
    JCTPaidDemurrage = @JCTPaidDemurrage,  
    BillOfLadding  = @MBL,  
    SenderInfo   = @SenderInfo  ,
	ConsigneeKey=@ConsigneeKey,
	--Consignee=@Consignee
	PTTChecked =@PTTChecked,
	PTTCheckedBy= @Userkey,
	PTTCheckedDate = getdate()
  WHERE OrderDetailKey = @OrderDetailKey  
  
  --Select @ShipFromData;  
  --Select @AFStopOffData;  
  --Select @ShipToData;  
  
  IF(ISNULL(@GnosisData,'')<>'')  
  BEGIN  
	EXEC Scheduler_InsertUpdateGnosisData @UserKey,@GnosisData,0,@Status,@Reason  
  END  
    
	   print 'SHIPFROM'  
	   IF(ISNULL(@ShipFromData,'')<>'')  
	   BEGIN  
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipFromData,0,@Status,@Reason  
	   END  
	   print 'AF-STOP'  
	   IF(ISNULL(@AFStopOffData,'')<>'')  
	   BEGIN  
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@AFStopOffData,0,@Status,@Reason  
	   END 
	   print 'SHIPTO'  
	   IF(ISNULL(@ShipToData,'')<>'')  
	   BEGIN  
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ShipToData,0,@Status,@Reason  
	   END 
	   print 'AT-STOP'  
	   IF(ISNULL(@ATStopOffData,'')<>'')  
	   BEGIN  
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ATStopOffData,0,@Status,@Reason  
	   END 
	   print 'RETURN'  
	   IF(ISNULL(@ReturnToData,'')<>'')  
	   BEGIN  
			EXEC Scheduler_InsertUpdateStops_V2 @UserKey,@ReturnToData,0,@Status,@Reason  
	   END  
  IF(@IsConfirm=1)  
  BEGIN
	   print 'Before Linking'
	   Exec [RoutesAndStopsLinking] @OrderDetailKey,0, 0
		print 'After Linking'
		exec Scheduler_RecreateLegID @OrderDetailKey
	END
	--/// ********************** update routes data
		UPDATE RT
	    SET 
			SourceAddrKey = ODs.StopAddrKey,
	        PickupDateFrom = ODS.SchedulePickupDate ,
	        PickupDateTo = ODS.SchedulePickupDateTo ,
	        ScheduledPickupDate =  ODS.SchedulePickupDate ,
			ActualDeparture = case when ODs.ActualPickupDate is not null then ODs.ActualPickupDate else rt.ActualDeparture end,
			ActualDepartureUpdateDate = case when ODs.ActualPickupDate is not null and ods.ActualPickupDate <> RT.ActualDeparture 
							then GetDate() else rt.ActualDepartureUpdateDate end,
			ActualDepartureUpdateMethod = case when ODs.ActualPickupDate is not null and ods.ActualPickupDate <> RT.ActualDeparture 
							then 'JCB User' else rt.ActualDepartureUpdateMethod end,
			ActualDepartureUpdateUser = case when ODs.ActualPickupDate is not null and ods.ActualPickupDate <> RT.ActualDeparture 
							then @UserKey else rt.ActualDepartureUpdateUser end,
			ConfirmationNo = ODS.RefNo,
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
			ActualArrival = case when ODS.ActualDeliveryDate is not null then ods.ActualDeliveryDate else rt.ActualArrival end,
			ActualArrivalUpdateDate = case when ODS.ActualDeliveryDate is not null and ODS.ActualDeliveryDate <> RT.ActualArrival 
							then GetDate() else rt.ActualArrivalUpdateDate end,
			ActualArrivalUpdateMethod = case when ODS.ActualDeliveryDate is not null and ODS.ActualDeliveryDate <> RT.ActualArrival 
							then 'JCB User' else rt.ActualArrivalUpdateMethod end,
			ActualArrivalUpdateUser = case when ODS.ActualDeliveryDate is not null and ODS.ActualDeliveryDate <> RT.ActualArrival 
							then @UserKey else rt.ActualArrivalUpdateUser end,
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
		
  SET @Status=1;  
  SET @Reason='Success';  
  COMMIT TRAN;  
 END TRY  
 BEGIN CATCH  
  print error_message();  
  print Error_Line();
  print Error_Procedure()
  SET @Status=0;  
  SET @Reason='Failed to save data';  
  ROLLBACK TRAN;  
 END CATCH  
END  