/**
DECLARE @UserKey  INT=953,
	@JSONString   NVARCHAR(MAX)='{"ContainerNoList":"","OrderDetailKeys":"177830:177942","Properties":"","Consignee":"","BrokerRefNo":"","LFD":null,"BillofLading":"","AvailableDate":"2025-07-03T15:48","Size_Type":0,"HoldNote":"","PUDelayedCodeKEy":"","PrepullDelayedCodeKEy":""}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = ''

	EXEC [Scheduler_BulkUpdate] @UserKey,@JSONString,@JSONOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT
	SELECT @Status, @Reason
	**/

CREATE PROCEDURE [dbo].[Scheduler_BulkUpdate]
(
	@UserKey      INT=953,
	@JSONString   NVARCHAR(MAX)='',
	@JSONOutput   NVARCHAR(MAX) = '' OUTPUT,
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;
	
	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter missing';
	END

	DECLARE @OrderKeys	VARCHAR(300),@CsrKey INT=0, @USerName VARCHAR(100),
			--@Consignee NVARCHAR(100)='',
			@ConsigneeKey INT,
			@Properties NVARCHAR(100)='',@BrokerRef NVARCHAR(100)='',@BOL NVARCHAR(100)='',
			@MarketLocationKey INT=0, @PickupAddrKey	INT=0, @DeliveryAddrKey	INT=0,@OrderDetailKeys NVARCHAR(300), @ContainertpeKeys NVARCHAR(300),
			@CommentKey INT, @Comment VARCHAR(500)='', @OrderDetailKey INT, @ContainerNo VARCHAR(20)='', 
			@StopName NVARCHAR(100),@AvailableDate DATETIME= null, @LFD NVARCHAR(100),@Size_Type INT,
			@HoldNote NVARCHAR(300),@SchedulePickup DATETIME='' ,@ScheduleDelivery DATETIME='',
			@PUDelayedCodeKEy NVARCHAR(300)='',@PrepullDelayedCodeKEy NVARCHAR(300),
			@SchedulePickUpDate NVARCHAR(100) = '',
			@SchedulePickUpDateTo NVARCHAR(100) = '',
			@ScheduleDeliveryDate NVARCHAR(100) = '',
			@ScheduleDeliveryDateTo NVARCHAR(100) = '',
			@Comments NVARCHAR(1000) = ''

	SELECT @OrderKeys = OrderKeys, @CsrKey = CsrKey,
			@ConsigneeKey=ConsigneeKey,
			--@Consignee=Consignee,
		   @ContainertpeKeys=Properties,@BrokerRef=BrokerRefNo,@BOL=BillofLading,@MarketLocationKey=MarketLocationKey,
		   @PickupAddrKey=PickupAddrKey,@DeliveryAddrKey=DeliveryAddrKey,@OrderDetailKeys=OrderDetailKeys,
		   @AvailableDate=CONVERT(DATETIME2, LEFT(AvailableDate, 16) + ':00', 126), @LFD=LFD, @Size_Type=Size_Type, 
		   @HoldNote=HoldNote,@PUDelayedCodeKEy=PUDelayedCodeKEy,@PrepullDelayedCodeKEy=PrepullDelayedCodeKEy,
		   @SchedulePickUpDate=SchedulePickUpDate,
		   @SchedulePickUpDateTo = SchedulePickUpDateTo,
		   @ScheduleDeliveryDate= ScheduleDeliveryDate,
		   @ScheduleDeliveryDateTo = ScheduleDeliveryDateTo
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderKeys				VARCHAR(300)	'$.OrderKeyList',
			CsrKey					INT				'$.CsrKey',
			--Consignee				NVARCHAR(100)	'$.Consignee',
			ConsigneeKey			INT				'$.ConsigneeKey',
			Properties				NVARCHAR(100)	'$.Properties',
			BrokerRefNo				NVARCHAR(100)	'$.BrokerRefNo',
			BillofLading			NVARCHAR(100)	'$.BillofLading',
			MarketLocationKey		INT				'$.MarketLocationKey',
			PickupAddrKey			INT				'$.PickupAddrKey',
			DeliveryAddrKey			INT				'$.DeliveryAddrKey',
			OrderDetailKeys			NVARCHAR(300)	'$.OrderDetailKeys',
			AvailableDate			NVARCHAR(100)	'$.AvailableDate',
			LFD						NVARCHAR(100)	'$.LFD',
			Size_Type				INT				'$.Size_Type',
			HoldNote				NVARCHAR(300)   '$.HoldNote',
			PUDelayedCodeKEy		NVARCHAR(300)   '$.PUDelayedCodeKey',
			PrepullDelayedCodeKEy   NVARCHAR(300)	'$.PrepullDelayedCodeKey',
			SchedulePickUpDate		NVARCHAR(100)	'$.SchedulePickUpDate',
			SchedulePickUpDateTo	NVARCHAR(100)	'$.SchedulePickUpDateTo',
			ScheduleDeliveryDate	NVARCHAR(100)	'$.ScheduleDeliveryDate',
			ScheduleDeliveryDateTo	NVARCHAR(100)	'$.ScheduleDeliveryDateTo'
		)
				
	CREATE TABLE #OrderKeys
	(
		OrderKey	INT
	)

	IF(LEN(ISNULL(@OrderKeys,'')) > 0)
	BEGIN
		INSERT INTO #OrderKeys(OrderKey)
		SELECT VALUE FROM dbo.Fn_SplitParamCol(@OrderKeys)
	END

	CREATE TABLE #OrderDetailKeys
	(
		OrderDetailKey	INT
	)
	IF(LEN(ISNULL(@OrderDetailKeys,'')) > 0)
	BEGIN
		INSERT INTO #OrderDetailKeys(OrderDetailKey)
		SELECT VALUE FROM dbo.Fn_SplitParamCol(@OrderDetailKeys)
	END

	CREATE TABLE #tmpOrderDetailKeys2
			(
				SLNo		INT,
				OrderDetailKey		int
			)
		INSERT INTO #tmpOrderDetailKeys2(SLNo,OrderDetailKey)
		SELECT ROW_NUMBER() OVER(ORDER BY OrderDetailKey),OrderDetailKey FROM #OrderDetailKeys

	CREATE TABLE #ContainerTypeKeys
	(
		ContainerTypeKey	INT,
		ContainerTypes		NVARCHAR(100)
	)
	IF(LEN(ISNULL(@ContainertpeKeys,'')) <>'')
	BEGIN
		INSERT INTO #ContainerTypeKeys(ContainerTypes)
		SELECT VALUE FROM dbo.Fn_SplitParamCol(@ContainertpeKeys)

		UPDATE CTT SET ContainerTypeKey=CT.ContainerTypeKey
		FROM ContainerTypes CT 
		INNER JOIN #ContainerTypeKeys CTT ON CTT.ContainerTypes=CT.TypeDescription OR CTT.ContainerTypes=CT.ShortCode
	END

	--select * from #OrderDetailKeys
	--select * from #ContainerTypeKeys
	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey

	UPDATE OH
	SET	BillofLading=CASE WHEN ISNULL(@BOL,'')<>'' THEN @BOL ELSE BillOfLading END
	FROM OrderHeader OH 
	INNER JOIN #OrderKeys OK ON (OK.OrderKey=OH.OrderKey )

	UPDATE OD 
	SET CsrKey=CASE WHEN ISNULL(@CsrKey,0)<>0 THEN @CsrKey ELSE CsrKey END,
		ConsigneeKey=CASE WHEN ISNULL(@ConsigneeKey,0)<>0 THEN @ConsigneeKey ELSE ConsigneeKey END,
		--Consignee=CASE WHEN ISNULL(@Consignee,'')<>'' THEN @Consignee ELSE Consignee END,
		CustRefNo=CASE WHEN ISNULL(@BrokerRef,'')<>'' THEN @BrokerRef ELSE CustRefNo END-- custref = brokerref
	  --MarketLocationKey=CASE WHEN ISNULL(@MarketLocationKey,0)<>0 THEN @MarketLocationKey ELSE MarketLocationKey END,
	    --PrepullDelayedCodeKEy=CASE WHEN ISNULL(@PrepullDelayedCodeKEy,0)<>0 THEN @PrepullDelayedCodeKEy ELSE PrepullDelayedCodeKEy END,
	    --PUDelayedCodeKEy=CASE WHEN ISNULL(@PUDelayedCodeKEy,0)<>0 THEN @PUDelayedCodeKEy ELSE PUDelayedCodeKEy END
	FROM OrderDetail OD 
	INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey=OD.OrderDetailKey)

	print @LFD
	SET @LFD = Replace(@LFD,'T', ' ');
	print 'After Replace'
	Print @LFD

	--SET @AvailableDate = REPLACE(@AvailableDate, 'T', ' '); --Converting to datetime
	--print @AvailableDate;

	UPDATE GD 
	SET AvailableDate=CASE WHEN ISNULL(@AvailableDate,'')<>'' THEN @AvailableDate ELSE AvailableDate END,
		--LFD=CASE WHEN ISNULL(LFD,'')<>'' THEN REPLACE(@LFD,'T',' ') ELSE LFD END,
		LFD=CASE WHEN ISNULL(@LFD,'')<>'' THEN @LFD ELSE LFD END,
		LFDChangedByUser=CASE WHEN ISNULL(@LFD,'')<>'' THEN 1 ELSE LFDChangedByUser END,
		Size_Type =CASE WHEN ISNULL(@Size_Type,0)<> 0 THEN @Size_Type ELSE Size_Type END,
		HoldNote=CASE WHEN ISNULL(@HoldNote,'')<>'' THEN @HoldNote ELSE HoldNote END
	FROM Container_GnosisData GD 
	INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey=GD.OrderDetailKey)

	--IF(ISNULL(@PickupAddrKey,0)<>0)
	--BEGIN
	--	SELECT @StopName=AddrName FROM [Address] WHERE AddrKey=@PickupAddrKey
	--	--Order Stops update
	--	UPDATE OS SET OS.StopAddrKey=@PickupAddrKey,StopName=@StopName
	--		FROM OrderStops OS
	--		INNER JOIN #OrderKeys OK ON (OK.Orderkey=OS.OrderKey)
	--	WHERE StopTypeKey=1	
	--	--Order detail Stops update
	--	UPDATE OS SET OS.StopAddrKey=@PickupAddrKey,StopName=@StopName
	--		FROM OrderDetailStops OS
	--		INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey=OS.OrderDetailKey)
	--	WHERE StopTypeKey=1	
	--END

	--IF(ISNULL(@DeliveryAddrKey,0)<>0)
	--BEGIN
	--	SELECT @StopName=AddrName FROM [Address] WHERE AddrKey=@DeliveryAddrKey
	--	--Order Stops update
	--	UPDATE OS SET OS.StopAddrKey=@DeliveryAddrKey,StopName=@StopName
	--		FROM OrderStops OS
	--		INNER JOIN #OrderKeys OK ON (OK.Orderkey=OS.OrderKey)
	--	WHERE StopTypeKey=3	
	--	--Order detail Stops update
	--	UPDATE OS SET OS.StopAddrKey=@PickupAddrKey,StopName=@StopName
	--		FROM OrderDetailStops OS
	--		INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey=OS.OrderDetailKey)
	--	WHERE StopTypeKey=3	
	--END	

	DECLARE @PropertiesCount INT =0, @OrderDetailkeysCount INT=0;
	SET @PropertiesCount=(SELECT Count(1) FROM #ContainerTypeKeys)
	SET @OrderDetailkeysCount = (SELECT COUNT(1) FROM #OrderDetailKeys)

	IF(@PropertiesCount>0 AND @OrderDetailkeysCount>0)
	BEGIN
		DELETE FROM ContainerTypesLink WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys)

		INSERT INTO ContainerTypesLink
		(OrderDetailKey,ContainerTypeKey, CommentKey,IsSelected)
		SELECT OT.OrderDetailKey,CT.ContainerTypeKey,0,1 FROM #OrderDetailKeys OT
		INNER JOIN #ContainerTypeKeys CT ON 1=1
		WHERE CT.ContainerTypeKey IS NOT NULL  --added to avoid null value insertion

	END
	--select 'PUDelayedCodeKoy',@PUDelayedCodeKEy
	IF(ISNULL(@PUDelayedCodeKEy,'')<>'')
	BEGIN
		DECLARE @Counter INT=1, @ReasonCodeJson NVARCHAR(MAX)='', @TempOrderDetailKey INT=0;
		SET @PUDelayedCodeKEy=REPLACE(@PUDelayedCodeKEy,'[','"');
		SET @PUDelayedCodeKEy=REPLACE(@PUDelayedCodeKEy,']','"')
		SET @PUDelayedCodeKEy=REPLACE(@PUDelayedCodeKEy,',',':')
		select @PUDelayedCodeKEy
		CREATE TABLE #tmpOrderDetailKeys
			(
				SLNo		INT,
				OrderDetailKey		int
			)
		INSERT INTO #tmpOrderDetailKeys(SLNo,OrderDetailKey)
		SELECT ROW_NUMBER() OVER(ORDER BY OrderDetailKey),OrderDetailKey FROM #OrderDetailKeys
		select '#tmpOrderDetailKeys',* from #tmpOrderDetailKeys
		select '#OrderDetailKeys',* from #OrderDetailKeys
		SELECT @OrderDetailkeysCount=COUNT(1) FROM #tmpOrderDetailKeys
		WHILE(@Counter<=@OrderDetailkeysCount)
		BEGIN
			SELECt @TempOrderDetailKey=OrderDetailKey FROM #tmpOrderDetailKeys WHERE SLNo=@Counter
			SET @ReasonCodeJson='{"OrderDetailKey":'+CAST(@TempOrderDetailKey AS VARCHAR)+',"CodeKey":'+@PUDelayedCodeKEy+',"Code":"","IsNew":true}'
			select '@ReasonCodeJson', @ReasonCodeJson
			exec InsertUpdate_PUScheduleDelayCode @UserKey,@ReasonCodeJson,@Status output,@Reason output
			SET @Counter=@Counter+1;
		END
	END
	--select '@PrepullDelayedCodeKEy', @PrepullDelayedCodeKEy
	IF(ISNULL(@PrepullDelayedCodeKEy,'')<>'')
	BEGIN
		DECLARE @Counter2 INT=1, @ReasonCodeJson2 NVARCHAR(MAX)='', @TempOrderDetailKey2 INT=0;
		SET @PrepullDelayedCodeKEy=REPLACE(@PrepullDelayedCodeKEy,'[','"');
		SET @PrepullDelayedCodeKEy=REPLACE(@PrepullDelayedCodeKEy,']','"')
		SET @PrepullDelayedCodeKEy=REPLACE(@PrepullDelayedCodeKEy,',',':')
		--select @PrepullDelayedCodeKEy
		
		--select '#tmpOrderDetailKeys2',* from #tmpOrderDetailKeys2
		--select '#OrderDetailKeys',* from #OrderDetailKeys
		SELECT @OrderDetailkeysCount=COUNT(1) FROM #tmpOrderDetailKeys2
		WHILE(@Counter2<=@OrderDetailkeysCount)
		BEGIN
			SELECt @TempOrderDetailKey2=OrderDetailKey FROM #tmpOrderDetailKeys2 WHERE SLNo=@Counter2
			SET @ReasonCodeJson2='{"OrderDetailKey":'+CAST(@TempOrderDetailKey2 AS VARCHAR)+',"CodeKey":'+@PrepullDelayedCodeKEy+',"Code":"","IsNew":true}'
			select '@ReasonCodeJson2', @ReasonCodeJson2
			exec InsertUpdate_PrePullReasonCodes @UserKey,@ReasonCodeJson2,@Status output,@Reason output
			SET @Counter2=@Counter2+1;
		END
	END

	UPDATE ODS
	SET 
		SchedulePickUpDate = CASE 
								WHEN ODS.StopTypeKey = 1 AND ISNULL(@SchedulePickUpDate, '') <> '' 
								THEN @SchedulePickUpDate 
								ELSE SchedulePickUpDate 
							 END,
		SchedulePickUpDateTo = CASE 
								WHEN ODS.StopTypeKey = 1 AND ISNULL(@SchedulePickUpDateTo, '') <> '' 
								THEN @SchedulePickUpDateTo
								ELSE SchedulePickUpDateTo 
							 END,
		ScheduleDeliveryDate = CASE 
								WHEN ODS.StopTypeKey = 3 AND ISNULL(@ScheduleDeliveryDate, '') <> '' 
								THEN @ScheduleDeliveryDate 
								ELSE ScheduleDeliveryDate 
							  END,
		ScheduleDeliveryDateTo = CASE 
								WHEN ODS.StopTypeKey = 3 AND ISNULL(@ScheduleDeliveryDateTo, '') <> '' 
								THEN @ScheduleDeliveryDateTo
								ELSE ScheduleDeliveryDateTo 
							  END
	FROM OrderDetailStops ODS 
	INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey = ODS.OrderDetailKey);

	SELECT @Comments = 
			CASE WHEN ISNULL(@CsrKey,0)=0  THEN '' ELSE 'CSR Changed ,'end+
			CASE WHEN ISNULL(@ConsigneeKey,0)=0 THEN '' ELSE 'Consignee Changed ,'end+
			CASE WHEN ISNULL(@ContainertpeKeys,'')=''  THEN '' ELSE 'Properties Changed ,'end+
			--CASE WHEN ISNULL(@Properties,'')=''  THEN '' ELSE 'Properties Changed ,'+
			CASE WHEN ISNULL(@BrokerRef,'')='' THEN '' ELSE 'BrokerRef Changed ,'end+
			CASE WHEN ISNULL(@SchedulePickUpDate,'')='' THEN '' ELSE 'Schedule PickUp Date From Changed ,'end+
			CASE WHEN ISNULL(@SchedulePickUpDateTo,'')='' THEN '' ELSE 'Schedule PickUp Date To Changed ,'end+
			CASE WHEN ISNULL(@ScheduleDeliveryDate,'')='' THEN '' ELSE 'Schedule Delivery Date From Changed ,'end+
			CASE WHEN ISNULL(@ScheduleDeliveryDate,'')=''  THEN  '' ELSE 'Schedule Delivery Date To Changed ,'end+
			CASE WHEN ISNULL(@AvailableDate,'')='' THEN '' ELSE 'Available Date Changed,'end+
			CASE WHEN ISNULL(@LFD,'')='' THEN '' ELSE 'LFD Changed ,'end+
			CASE WHEN ISNULL(@Size_Type,0)=0 THEN '' ELSE 'Container Size/Type Changed ,'end+
			CASE WHEN ISNULL(@HoldNote,'')='' THEN '' ELSE 'Hold Note Changed,'end
			--CASE WHEN ISNULL(@PUDelayedCodeKEy,'')='' THEN '' ELSE 'PUDelayedCode Changed ,'end+
			--CASE WHEN ISNULL(@PrepullDelayedCodeKEy,'')='' THEN '' ELSE 'PrepullDelayedCode Changed ,'end
	
		DECLARE @LogCounter INT = 1
		WHILE(@LogCounter <= @OrderDetailkeysCount)
		BEGIN
		SELECT 
				@OrderDetailKey = TMPL.OrderDetailKey,@ContainerNo = ODL.ContainerNo
				FROM #tmpOrderDetailKeys2 TMPL
				INNER JOIN OrderDetail ODL WITH (NOLOCK) ON TMPL.OrderDetailKey = ODL.OrderDetailKey
				WHERE TMPL.SLNo = @LogCounter;

		INSERT INTO AuditLogDetail 
		(DateCreated, CreateUser, RefType, RefId, RefKey, CommentType, Comments)
		SELECT GETDATE(), @USerName, 'Container', @ContainerNo, @OrderDetailKey, 'Text', @Comments;

		SET @LogCounter = @LogCounter + 1;
END

	SET @Status=1;
	SET @Reason='Success';
	
END

