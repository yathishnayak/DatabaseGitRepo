/*    
     
Declare @UserKey  INT=512,    
 @JsonString  NVARCHAR(MAX)=N'{"IsGnosisTracking":false,"OrderDetailKey":226353,"OrderTypeKey":2,"PriorityKey":5,"BookingNo":"N/A","CustRefNo":"123","CSRKey":96,"MBL":"123","SenderInfo":"User","ConsigneeKey":0,"GnosisData":{"SizeTypeKey":12,"Available":1,"MBLChangedByUser":false,"OrderDetailKey":226353},"IsConfirm":false,"ShipFromData":{"OrderDetailStopKey":678062,"OrderStopKey":283944,"StopTypeKey":1,"StopTypeName":"Pickup","OrderDetailKey":226353,"StopAddrKey":29512,"StopTypeShortcode":"SF","StopName":"ITS-LB 234-ONLY USE","StopAddress":"ITS-LB 234-ONLY USE","AddressLine1":"1281 PIER G WAY","City":"Long Beach","State":"CA","ZipCode":"90802","Country":"USA","StopNumber":1,"LocationType":"Port","IsFoundationStop":true,"OrderBy":1,"IsUpdate":true},"ShipToData":{"OrderDetailStopKey":678063,"OrderStopKey":283946,"StopTypeKey":3,"StopTypeName":"Delivery","OrderDetailKey":226353,"StopAddrKey":1700,"StopTypeShortcode":"ST","StopName":"Total Terminals Int''l (TTI/Hanjin) Test 2","StopAddress":"Total Terminals Int''l (TTI/Hanjin) Test 2","AddressLine1":"Test 2","City":"Long Beach","State":"CA","ZipCode":"90813","Country":"USA","StopNumber":3,"LocationType":"Customer","IsFoundationStop":true,"OrderBy":3,"IsUpdate":true},"ReturnToData":{"OrderDetailStopKey":678064,"OrderStopKey":283948,"StopTypeKey":5,"StopTypeName":"Return","OrderDetailKey":226353,"StopAddrKey":30638,"StopTypeShortcode":"RT","StopName":"WBCT-ONLY USE","StopAddress":"WBCT-ONLY USE","AddressLine1":"1830 John S Gibson Blvd","City":"San Pedro","State":"CA","ZipCode":"90731","Country":"USA","StopNumber":5,"LocationType":"Port","IsFoundationStop":true,"OrderBy":5,"IsUpdate":true},"AFStopOffData":[{"OrderDetailStopKey":678065,"OrderStopKey":283945,"StopTypeKey":2,"StopTypeName":"Stop","OrderDetailKey":226353,"StopAddrKey":31139,"StopTypeShortcode":"AF","StopName":"Pier S - PREPULL","AddressLine1":"3400 NEW DOCK ST Long Beach CA USA 90802","City":"Long Beach","State":"CA","ZipCode":"90802","Country":"USA","StopNumber":2,"OrderBy":2,"IsUpdate":true}],"ATStopOffData":[{"OrderDetailStopKey":678066,"OrderStopKey":283947,"StopTypeKey":4,"StopTypeName":"Stop","OrderDetailKey":226353,"StopAddrKey":42296,"StopTypeShortcode":"AT","StopName":"JCT ALAMEDA","AddressLine1":"21900 S ALAMEDA ST","City":"Long Beach","State":"CA","ZipCode":"90801","Country":"USA","StopNumber":4,"OrderBy":4,"IsUpdate":true}]}',
 @IsDebug  BIT = 1,    
 @Status   BIT = 0 ,    
 @Reason   NVARCHAR(1000) = ''     
    
 exec Scheduler_InsertUpdateSchedules_V2 @UserKey,@JsonString,@IsDebug,@Status output, @Reason output    
 select @Reason,@Status    
    
*/    
CREATE PROCEDURE [dbo].[Scheduler_InsertUpdateSchedules_V2]    
(    
 @UserKey  INT=512,    
 @JsonString  NVARCHAR(MAX)=N'',    
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
   @CustRefNo VARCHAR(100) = '',@LFD DATETIME,@GnosisData NVARCHAR(MAX),    
   @ShipFromData  NVARCHAR(MAX),@ShipToData  NVARCHAR(MAX),@ReturnToData  NVARCHAR(MAX),@MBL NVARCHAR(50),@SenderInfo VARCHAR(300) = '',    
   @AFStopOffData NVARCHAR(MAX), @ATStopOffData NVARCHAR(MAX),@IsConfirm  BIT=0, @CSRKey INT=0,@JCTPaidDemurrage BIT=0  ,  
   @ConsigneeKey INT
   --@Consignee NVARCHAR(400)  
    
 SELECT @ContainerNo=ContainerNo,@OrderDetailKey = OrderDetailKey,@OrderTypeKey=OrderTypeKey,@PriorityKey=PriorityKey,    
     @BookingNo=BookingNo,@CustRefNo=CustRefNo,@MBL=MBL,@GnosisData=GnosisData,@ShipFromData=ShipFromData,    
     @ShipToData=ShipToData,@ReturnToData=ReturnToData,@AFStopOffData=AFStopOffData,    
     @ATStopOffData=ATStopOffData,@IsConfirm=IsConfirm, @CSRKey=CSRKey,@JCTPaidDemurrage=JCTPaidDemurrage,@SenderInfo=SenderInfo ,  
	 @ConsigneeKey=ConsigneeKey
  --@Consignee=Consignee  
 FROM OPENJSON(@JsonString, '$')    
 WITH(     
   ContainerNo				VARCHAR(20)		'$.ContainerNo',    
   OrderDetailKey			INT				'$.OrderDetailKey',    
   OrderTypeKey				INT				'$.OrderTypeKey',    
   PriorityKey				INT				'$.PriorityKey',    
   BookingNo				VARCHAR(100)	'$.BookingNo',    
   CustRefNo				VARCHAR(100)	'$.CustRefNo',       
   MBL						VARCHAR(100)	'$.MBL',    
   GnosisData				NVARCHAR(MAX)	'$.GnosisData' AS JSON,    
   ShipFromData				NVARCHAR(MAX)	'$.ShipFromData' AS JSON,    
   ShipToData				NVARCHAR(MAX)	'$.ShipToData' AS JSON,    
   ReturnToData				NVARCHAR(MAX)	'$.ReturnToData' AS JSON,    
   AFStopOffData			NVARCHAR(MAX)	'$.AFStopOffData' AS JSON,    
   ATStopOffData			NVARCHAR(MAX)	'$.ATStopOffData' AS JSON,    
   IsConfirm				BIT				'$.IsConfirm',    
   CSRKey					INT				'$.CsrKey',    
   JCTPaidDemurrage			BIT				'$.JCTPaidDemurrage',    
   SenderInfo				NVARCHAR(300)	'$.SenderInfo'  ,
   ConsigneeKey				INT				'$.ConsigneeKey'
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
	ConsigneeKey=@ConsigneeKey
  WHERE OrderDetailKey = @OrderDetailKey    
   
    
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
		ActualDeparture = ODs.ActualPickupDate,  
		ConfirmationNo = ODS.RefNo,  
		LastUpdateDate = GETDATE(),  
		UpdateUserKey = @UserKey  
	From Routes RT    WITH(NOLOCK)
	inner join OrderDetailStops ODS WITH(NOLOCK) on RT.routekey = ODS.FromRouteKey  
	WHERE ODS.OrderDetailKey = @OrderDetailKey  
	print 'upd - 1'  
  
	UPDATE RT  
	SET   
		DestinationAddrKey = ODs.StopAddrKey,  
		DeliveryDateFrom = ODS.ScheduleDeliveryDate ,  
		DeliveryDateTo = ODS.ScheduleDeliveryDateTo ,  
		LastUpdateDate = GETDATE(),  
		ActualArrival = ODS.ActualDeliveryDate,  
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
	  From Routes RT  WITH(NOLOCK)
	  inner join OrderDetailStops ODS WITH(NOLOCK) on RT.routekey = ODS.ToRouteKey  
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
  SET @Reason=error_message()--'Failed to save data';    
  ROLLBACK TRAN;    
 END CATCH    
END 
