/*

 declare @UserKey		INT=952,
	@JsonString		VARCHAR(MAX)='{"OrderDetailStopKey":1110114,"OrderStopKey":208508,"StopTypeKey":1,"StopTypeName":"Pickup","OrderDetailKey":178020,"StopAddrKey":35000,"StopTypeShortcode":"SF","StopName":" 3 RIVERS","StopAddress":" 3 RIVERS","AddressLine1":" 2300 W WILLOW ST ","AddressLine2":" ","City":"Long Beach","State":"CA","ZipCode":"90805","Country":"USA","StopNumber":1,"LocationType":"Port","SchedulePickupDate":"2025-05-06","SchedulePickupUserKey":486,"SchedulePickupSetDateTime":"2025-05-09T05:48:06.403","DropOrLiveSetUserKey":486,"DropOrLiveSetDatetime":"2025-05-09T05:48:06.403","IsFoundationStop":true,"OrderBy":1,"UpdateDate":"2025-05-09T05:48:06.403","UpdateUserName":"Reethika R","DryRunPortSetDateTime":"2025-05-09T05:48:06.403","DryRunPortSetUserKey":486,"BobtailSetDateTime":"2025-05-09T05:48:06.403","BobtailSetUserKey":486,"EmptySetDateTime":"2025-05-09T05:48:06.403","EmptySetUserKey":486,"StreetSturnSetDateTime":"2025-05-09T05:48:06.403","StreetSturnSetUserKey":486,"ChassisSplitSetDateTime":"2025-05-09T05:48:06.403","ChassisSplitSetUserKey":486,"IsScheduleDeliveryDateExist":false,"IsUpdate":true,"SchedulePickupToDate":"2025-05-06","SchedulePickupFromTime":"05:05","SchedulePickupToTime":"05:05","IsPastSchedulePickup":true,"IsPastScheduleDelivery":false,"IsActualDeliveryDateExist":false,"IsDryRunPortMarked":false,"IsDryRunCustomerMarked":false,"ShowStopDetails":false,"IsActualDeliveryEditable":true,"IsActualPickupEditable":true,"IsDryRunPort":true}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 

	exec [Scheduler_InsertUpdateStops] @UserKey,@JsonString,@IsDebug,@Status output, @Reason output
	select @Reason,@Status

	*/

CREATE PROCEDURE [dbo].[Scheduler_InsertUpdateStops]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
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

	DECLARE @StopName	VARCHAR(100)='',
			@StopTypeKey INT,
			@OrderDetailKey		int
	
	SELECT
	OrderDetailKey		,
	OrderDetailStopKey	,
	StopTypeShortcode	,
	StopTypeKey			,
	StopAddrKey			,
	StopName			,
	StopNo				,
	LocationType		,
	RefNo				,
	SchedulePickUp,ScheduleDelivery,ActualPickUp,ActualDelivery,
	DropOrLive, SchedulePickupToDate, ScheduleDeliverToDate,
	SchedulePickupFromTime,SchedulePickupToTime,
	ScheduleDeliveryFromTime,ScheduleDeliveryToTime,Is247Pickup,Is247Delivery,
	IsDryRunPort,IsDryRunCustomer,IsBobtail	,IsEmptyReady,IsStreetTurn,IsChassisSplit
	INTO #tempstopsdata
	FROM OPENJSON(@JsonString, '$')
	WITH (
			OrderDetailKey			INT				'$.OrderDetailKey',
			OrderDetailStopKey		BIGINT			'$.OrderDetailStopKey',
			StopTypeShortcode		Varchar(5)		'$.StopTypeShortcode',
			StopTypeKey				INT				'$.StopTypeKey',
			StopAddrKey				INT				'$.StopAddrKey',
			StopName				VARCHAR(100)	'$.StopName',
			StopNo					INT				'$.StopNumber',
			LocationType			VARCHAR(100)	'$.LocationType',
			RefNo					VARCHAR(50)		'$.RefNo',
			SchedulePickUp			DATETIME		'$.SchedulePickupDate',
			ScheduleDelivery		DATETIME		'$.ScheduleDeliverDate',			
			ActualPickUp			DATETIME		'$.ActualPickupDate',
			ActualDelivery			DATETIME		'$.ActualDeliveryDate',
			DropOrLive				BIT				'$.DropOrLive',
			SchedulePickupToDate	DATETIME		'$.SchedulePickupToDate',
			ScheduleDeliverToDate	DATETIME		'$.ScheduleDeliverToDate',
			SchedulePickupFromTime	DATETIME		'$.SchedulePickupFromTime',
			SchedulePickupToTime	DATETIME		'$.SchedulePickupToTime',
			ScheduleDeliveryFromTime DATETIME		'$.ScheduleDeliveryFromTime',
			ScheduleDeliveryToTime	DATETIME		'$.ScheduleDeliveryToTime',
			Is247Pickup				BIT				'$.Is247Pickup',
			Is247Delivery			BIT				'$.Is247Delivery',
			IsDryRunPort			BIT				'$.IsDryRunPort',
			IsDryRunCustomer		BIT				'$.IsDryRunCustomer',
			IsBobtail				BIT				'$.IsBobTail',
			IsEmptyReady			BIT				'$.IsEmpty',
			IsStreetTurn			BIT				'$.IsStreetTurn',
			IsChassisSplit			BIT				'$.IsChassisSplit'
		 )

	--SELECT @StopTypeName=StopTypeName FROM StopsMaster WHERE StopTypeKey=(SELECT TOP 1 StopTypeKey FROM #tempstopsdata)
	
	SELECT @StopTypeKey = StopTypeKey from StopsMaster where StopTypeShortcode=(SELECT TOP 1 StopTypeShortcode FROM #tempstopsdata)

	Select @StopName = Addrname from Address where AddrKey = (SELECT TOP 1 StopAddrKey FROM #tempstopsdata)

	SElect @OrderDetailKey = OrderDetailKey from #tempstopsdata

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
	--	FETCH NEXT FROM Cur_AddrName
	--	INTO @StopName

		IF(@IsDebug = 1)
		BEGIN
			SELECT * FROM #tempstopsdata
			SELECT @StopName StopName
		END

		--WHILE @@Fetch_status = 0
		--BEGIN

			--UPDATE #tempstopsdata SET SchedulePickUp=CASE WHEN SchedulePickUp IS NULL THEN 
			--						  CAST(SchedulePickUp AS datetime) + CAST(SchedulePickupFromTime AS datetime) ELSE SchedulePickUp END,
			--						  SchedulePickupToDate=CASE WHEN SchedulePickupToDate IS NULL THEN 
			--						  CAST(SchedulePickupToDate AS datetime) + CAST(SchedulePickupToTime AS datetime) ELSE SchedulePickupToDate END,
			--						  ScheduleDelivery=CASE WHEN ScheduleDelivery IS NULL THEN
			--						  CAST(ScheduleDelivery AS datetime) + CAST(ScheduleDeliveryFromTime AS datetime) ELSE ScheduleDelivery END,
			--						  ScheduleDeliverToDate=CASE WHEN ScheduleDeliverToDate IS NULL THEN
			--						  CAST(ScheduleDeliverToDate AS datetime) + CAST(ScheduleDeliveryToTime AS datetime) ELSE ScheduleDeliverToDate END

			UPDATE #tempstopsdata SET --SchedulePickUp=CASE WHEN SchedulePickUp IS NULL THEN CAST(SchedulePickUp AS datetime) + CAST(SchedulePickupFromTime AS datetime) ELSE SchedulePickUp END,
							--SchedulePickupToDate=CASE WHEN SchedulePickupToDate IS NULL THEN CAST(SchedulePickupToDate AS datetime) + CAST(SchedulePickupToTime AS datetime) ELSE SchedulePickupToDate END,
							SchedulePickUp=DATEADD(MINUTE, 
											 DATEPART(HOUR, SchedulePickupFromTime) * 60 + DATEPART(MINUTE, SchedulePickupFromTime), 
											 CAST(CONVERT(DATE, SchedulePickUp) AS DATETIME)),
							SchedulePickupToDate=DATEADD(MINUTE, 
											 DATEPART(HOUR, SchedulePickupToTime) * 60 + DATEPART(MINUTE, SchedulePickupToTime), 
											 CAST(CONVERT(DATE, SchedulePickUp) AS DATETIME)),
							ScheduleDelivery=DATEADD(MINUTE, 
											 DATEPART(HOUR, ScheduleDeliveryFromTime) * 60 + DATEPART(MINUTE, ScheduleDeliveryFromTime), 
											 CAST(CONVERT(DATE, ScheduleDelivery) AS DATETIME)),
											 --Update ScheduleDeliverToDate column
							ScheduleDeliverToDate=	DATEADD(MINUTE, 
													DATEPART(HOUR, ScheduleDeliveryToTime) * 60 + DATEPART(MINUTE, ScheduleDeliveryToTime), 
													CAST(CONVERT(DATE, ScheduleDelivery) AS DATETIME))

			INSERT INTO  OrderDetailStops
						(OrderDetailKey,StopTypeKey,StopName,StopAddrKey,StopNumber,LocationType,RefNo,
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
						 Is247Delivery,Is247DeliveryMarkedBy,Is247DeliveryMarkedDate
						 )
			SELECT		 OrderDetailKey,@StopTypeKey,StopName,StopAddrKey,StopNo,LocationType,RefNo,
						 SchedulePickUp, case when SchedulePickUp is null then null else @UserKey end,
							case when SchedulePickUp is null then null else GETDATE() end,
						 REPLACE(ActualPickUp,'T',' ') , case when ActualPickUp is null then null else @UserKey end,
							case when ActualPickUp is null then null else GETDATE() end,
						 ScheduleDelivery, case when ScheduleDelivery is null then null else @UserKey end,
							case when ScheduleDelivery is null then null else GETDATE() end,
						 REPLACE(ActualDelivery,'T',' ') , case when ActualDelivery is null then null else @UserKey end,
							case when ActualDelivery is null then null else GETDATE() end,
						 DropOrLive,case when isnull(DropOrLive,0) = 0  then null else @UserKey end ,
							case when isnull(DropOrLive,0) = 0  then null else GETDATE() end,
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
							case when isnull(Is247Delivery,0) = 0  then null else GETDATE() end
			FROM		 #tempstopsdata 
			WHERE ISNULL(OrderDetailStopKey,0) = 0

			UPDATE	OD
			SET		StopTypeKey=@StopTypeKey,StopName=TD.StopName,StopAddrKey=TD.StopAddrKey,StopNumber=TD.StopNo,
					LocationType=TD.LocationType,RefNo=TD.RefNo,
					SchedulePickupDate=TD.SchedulePickUp,
					SchedulePickupUserKey=case when TD.SchedulePickUp is null then null else @UserKey end,
					SchedulePickupSetDateTime=case when Td.SchedulePickUp is null then null else GETDATE() end ,

					SchedulePickupDateTo=TD.SchedulePickupToDate,
					SchedulePickupToUserKey = case when TD.SchedulePickupToDate is null then null else @UserKey end,
					SchedulePickupToSetDateTime = case when TD.SchedulePickupToDate is null then null else GETDATE() end,

					ActualPickupDate=REPLACE(TD.ActualPickUp,'T',' '),
					ActualPickupUserKey=case when TD.ActualPickUp is null then null else @UserKey end,
					ActualPickupSetDateTime= case when TD.ActualPickUp is null then null else GETDATE() end , 

					ScheduleDeliveryDate=TD.ScheduleDelivery, 
					ScheduleDeliveryUserKey=case when TD.ScheduleDelivery is null then null else @UserKey end,
					ScheduleDeliverySetDateTime=case when TD.ScheduleDelivery is null then null else GETDATE() end ,

					ScheduleDeliveryDateTo=TD.ScheduleDeliverToDate,
					ScheduleDeliveryToUserKey = case when TD.ScheduleDeliverToDate is null then null else @UserKey end,
					ScheduleDeliveryToSetDateTime = case when TD.ScheduleDeliverToDate is null then null else GETDATE() end,

					ActualDeliveryDate=REPLACE(TD.ActualDelivery,'T',' '),
					ActualDeliveryUserKey=case when TD.ActualDelivery is null then null else @UserKey end,
					ActualDeliverySetDateTime=case when TD.ActualDelivery is null then null else GETDATE() end ,

					DropOrLive=TD.DropOrLive, 
					DropOrLiveSetDatetime=Case when isnull(TD.DropOrLive,0) = 0 then null else GETDATE() end,
					DropOrLiveSetUserKey=Case when isnull(TD.DropOrLive,0) = 0 then null else @UserKey end ,

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
					Is247DeliveryMarkedDate=case when isnull(TD.Is247Delivery ,0) = 0 then null else GETDATE() end
			FROM	OrderDetailStops OD 
			INNER JOIN	#tempstopsdata TD ON OD.OrderDetailStopKey = TD.OrderDetailStopKey

	--	END
	--END
	--CLOSE Cur_AddrName
	--DEALLOCATE Cur_AddrName
	Declare @DryRunCount	int = 0
	Select @DryRunCount = Count(1) from #tempstopsdata where isnull(IsDryRunPort,0) = 1 OR ISNULL(IsDryRunCustomer,0) = 1
	if(@DryRunCount > 0)
	Begin
			INSERT INTO  OrderDetailStops
						(OrderDetailKey,StopTypeKey,StopName,StopAddrKey,LocationType,
						 DropOrLive,DropOrLiveSetUserKey, DropOrLiveSetDatetime,
						 CreateDate,CreateUserKey
						 )
			SELECT		 OrderDetailKey,@StopTypeKey,StopName,StopAddrKey,LocationType,
						 DropOrLive,case when isnull(DropOrLive,0) = 0  then null else @UserKey end ,
							case when isnull(DropOrLive,0) = 0  then null else GETDATE() end,
						 GETDATE(),@UserKey
			FROM		 #tempstopsdata 
			WHERE		 isnull(IsDryRunPort,0) = 1 OR ISNULL(IsDryRunCustomer,0) = 1

			if((select @@ROWCOUNT ) > 0 )
			Begin
				update A set StopNumber = B.NewStopNumber
				from OrderDetailStops A
				inner join (
					select ROW_NUMBER() Over (Order by OrderDetailKey, SM.StoptypeKey) as NewStopNumber, SM.StopTypeShortcode, OrderDetailStopKey
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
	Exec [RoutesAndStopsLinking] @OrderDetailKey, 0
	DROP TABLE #tempstopsdata
END
