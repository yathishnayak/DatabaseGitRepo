/**
declare @UserKey      INT=512,
	@JSONString   NVARCHAR(MAX)='{"OrderKeyList":"104419:104421:138160:138165:138160","OrderDetailKeys":"","OrderTypeKey":0,"OrderTypeDescription":"","MarketLocationKey":0,"MarketLocation":"","PickupAddrKey":0,"DeliveryAddrKey":0,"Properties":"WKND","Consignee":"","BrokerRefNo":"","BillofLading":""}',
	@JSONOutput   NVARCHAR(MAX) = '',
	@Status       BIT = 0 ,
	@Reason       VARCHAR(1000) = ''

	exec [Order_BulkUpdate] @UserKey,@JSONString,@JSONOutput output,@Status output,@Reason output
	select @Status AS Status, @Reason AS Reason
	**/
CREATE PROCEDURE [dbo].[Order_BulkUpdate]
(
	@UserKey      INT=512,
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

	DECLARE @OrderKeys	VARCHAR(300), @CsrKey	INT=0, @USerName VARCHAR(100),@Consignee NVARCHAR(100)='', @ConsigneeKey INT=0,
			@OrderType INT=0, @Properties NVARCHAR(100)='',@BrokerRef NVARCHAR(100)='',@BillofLading NVARCHAR(100)='',
			@MarketLocationKey INT=0, @PickupAddrKey	INT=0, @DeliveryAddrKey	INT=0,@OrderDetailKeys NVARCHAR(300), @ContainertpeKeys NVARCHAR(300),
			@CommentKey INT, @Comment VARCHAR(500)='', @OrderDetailKey INT, @ContainerNo VARCHAR(20)='', @StopName NVARCHAR(100),
			@SenderInfo NVARCHAR(300)='',@Comments NVARCHAR(1000)

	SELECT @OrderKeys = OrderKeys, @CsrKey = CsrKey,@Consignee=Consignee,@ConsigneeKey=ConsigneeKey, @OrderType=OrderTypeKey,
		   @ContainertpeKeys=Properties,@BrokerRef=BrokerRefNo,@BillofLading=BillofLading,@MarketLocationKey=MarketLocationKey,
		   @PickupAddrKey=PickupAddrKey,@DeliveryAddrKey=DeliveryAddrKey,@OrderDetailKeys=OrderDetailKeys,--,@ContainertpeKeys=ContainertpeKeys
		   @SenderInfo=SenderInfo
	FROM OPENJSON(@JSONString,'$')
    WITH (
			OrderKeys			VARCHAR(300)	'$.OrderKeyList',
			CsrKey				INT				'$.CsrKey',
			Consignee			NVARCHAR(100)	'$.Consignee',
			ConsigneeKey		INT				'$.ConsigneeKey',
			OrderTypeKey		INT				'$.OrderTypeKey',
			Properties			NVARCHAR(300)	'$.Properties',
			BrokerRefNo			NVARCHAR(100)	'$.BrokerRefNo',
			BillofLading		NVARCHAR(100)	'$.BillofLading',
			MarketLocationKey	INT				'$.MarketLocationKey',
			PickupAddrKey		INT				'$.PickupAddrKey',
			DeliveryAddrKey		INT				'$.DeliveryAddrKey',
			OrderDetailKeys		NVARCHAR(300)	'$.OrderDetailKeys',
			SenderInfo			NVARCHAR(300)	'$.SenderInfo'
			--ContainertpeKeys	NVARCHAR(300)	'$.ContainertpeKeys'
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

	INSERT INTO #OrderDetailKeys(OrderDetailKey)
	SELECT OrderDetailKey from OrderDetail where orderkey in(select orderkey from #OrderKeys)

	CREATE TABLE #ContainerTypeKeys
	(
		ContainerTypeKey	INT,
		ContainerTypes		NVARCHAR(300)
	)
	IF(LEN(ISNULL(@ContainertpeKeys,'')) <>'')
	BEGIN
		INSERT INTO #ContainerTypeKeys(ContainerTypes)
		SELECT VALUE FROM dbo.Fn_SplitParamCol(@ContainertpeKeys)

		UPDATE CTT SET ContainerTypeKey=CT.ContainerTypeKey
		FROM ContainerTypes CT
		INNER JOIN #ContainerTypeKeys CTT ON CTT.ContainerTypes=CT.TypeDescription OR CTT.ContainerTypes= CT.ShortCode
	END

	
	--select * from #OrderKeys
	--select * from #OrderDetailKeys
	--select * from #ContainerTypeKeys
	--Select @BillofLading
	SELECT @USerName = ISNULL(UserName,'') FROM [User] WHERE UserKey = @UserKey
	--Order header update
	UPDATE OH 
	SET CsrKey=CASE WHEN ISNULL(@CsrKey,0)<>0 THEN @CsrKey ELSE CsrKey END, 
		--Consignee=CASE WHEN ISNULL(@Consignee,'')<>'' THEN @Consignee ELSE Consignee END,
		ConsigneeKey=CASE WHEN ISNULL(@ConsigneeKey,0)<>0 THEN @ConsigneeKey ELSE ConsigneeKey END,
		OrderTypeKey=CASE WHEN ISNULL(@OrderType,0)<>0 THEN @OrderType ELSE OrderTypeKey END,
		BrokerRefNo=CASE WHEN ISNULL(@BrokerRef,'')<>'' THEN @BrokerRef ELSE BrokerRefNo END,
		BillofLading=CASE WHEN ISNULL(@BillofLading,'')<>'' THEN @BillofLading ELSE BillOfLading END,
		MarketLocationKey=CASE WHEN ISNULL(@MarketLocationKey,0)<>0 THEN @MarketLocationKey ELSE MarketLocationKey END,
		SenderInfo=CASE WHEN ISNULL(@SenderInfo,'')<>'' THEN @SenderInfo ELSE SenderInfo END
	FROM OrderHeader OH
	INNER JOIN #OrderKeys OK ON (OK.Orderkey=OH.OrderKey)
	--Order detail Update
	UPDATE OD 
	SET --Consignee=CASE WHEN ISNULL(@Consignee,'')<>'' THEN @Consignee ELSE Consignee END,
		ConsigneeKey=CASE WHEN ISNULL(@ConsigneeKey,0)<>0 THEN @ConsigneeKey ELSE ConsigneeKey END,
		OrderTypeKey=CASE WHEN ISNULL(@OrderType,0)<>0 THEN @OrderType ELSE OrderTypeKey END,
		CustRefNo=CASE WHEN ISNULL(@BrokerRef,'')<>'' THEN @BrokerRef ELSE CustRefNo END,
		CSRKey=CASE WHEN ISNULL(@CsrKey,0)<>0 THEN @CsrKey ELSE CsrKey END,
		SenderInfo=CASE WHEN ISNULL(@SenderInfo,'')<>'' THEN @SenderInfo ELSE SenderInfo END,
		SourceAddrKey=CASE WHEN ISNULL(@PickupAddrKey,'')<>'' THEN @PickupAddrKey ELSE SourceAddrKey END,
		DestinationAddrKey=CASE WHEN ISNULL(@DeliveryAddrKey,'')<>'' THEN @DeliveryAddrKey ELSE DestinationAddrKey END
	FROM OrderDetail OD
	INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey=OD.OrderDetailKey)

	IF(ISNULL(@PickupAddrKey,0)<>0)
	BEGIN
		SELECT @StopName=AddrName FROM [Address] WHERE AddrKey=@PickupAddrKey
		--Order Stops update
		UPDATE OS SET OS.StopAddrKey=@PickupAddrKey,StopName=@StopName
			FROM OrderStops OS
			INNER JOIN #OrderKeys OK ON (OK.Orderkey=OS.OrderKey)
		WHERE StopTypeKey=1	
		--Order detail Stops update
		UPDATE OS SET OS.StopAddrKey=@PickupAddrKey,StopName=@StopName
			FROM OrderDetailStops OS
			INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey=OS.OrderDetailKey)
			INNER JOIN OrderDetail OD ON OD.OrderDetailKey=OK.OrderDetailKey 
			INNER JOIN OrderHeader OH ON (OH.Orderkey=OD.OrderKey AND Oh.OrderTypeKey=OD.OrderTypeKey)
		WHERE StopTypeKey=1	
	END

	IF(ISNULL(@DeliveryAddrKey,0)<>0)
	BEGIN
		SELECT @StopName=AddrName FROM [Address] WHERE AddrKey=@DeliveryAddrKey
		--Order Stops update
		UPDATE OS SET OS.StopAddrKey=@DeliveryAddrKey,StopName=@StopName
			FROM OrderStops OS
			INNER JOIN #OrderKeys OK ON (OK.Orderkey=OS.OrderKey)
		WHERE StopTypeKey=3	
		--Order detail Stops update
		UPDATE OS SET OS.StopAddrKey=@DeliveryAddrKey,StopName=@StopName
			FROM OrderDetailStops OS
			INNER JOIN #OrderDetailKeys OK ON (OK.OrderDetailKey=OS.OrderDetailKey)
			INNER JOIN OrderDetail OD ON OD.OrderDetailKey=OK.OrderDetailKey 
			INNER JOIN OrderHeader OH ON (OH.Orderkey=OD.OrderKey AND Oh.OrderTypeKey=OD.OrderTypeKey)
		WHERE StopTypeKey=3	
	END	

	DECLARE @PropertiesCount INT =0, @OrderDetailkeysCount INT=0;
	SET @PropertiesCount=(SELECT Count(1) FROM #ContainerTypeKeys)
	SET @OrderDetailkeysCount = (SELECT COUNT(1) FROM #OrderDetailKeys)

	IF(@PropertiesCount>0 AND @OrderDetailkeysCount>0)
	BEGIN
		DELETE FROM ContainerTypesLink WHERE OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys)

		--Select * from #ContainerTypeKeys

		INSERT INTO ContainerTypesLink
		(OrderDetailKey,ContainerTypeKey, CommentKey,IsSelected)
		SELECT OT.OrderDetailKey,CT.ContainerTypeKey,0,1 FROM #OrderDetailKeys OT
		INNER JOIN #ContainerTypeKeys CT ON 1=1
	END

	SELECT ROW_NUMBER() OVER (ORDER BY OrderKey) AS RowNum, OrderKey 
	AS TempOrderKey INTO #AuditTemp FROM #OrderKeys;


	SELECT @Comments = 
			CASE WHEN ISNULL(@CsrKey,0)=0  THEN '' ELSE 'CSR Changed ,' end+
			CASE WHEN ISNULL(@ConsigneeKey,0)=0 THEN '' ELSE 'Consignee Changed ,' end+
			CASE WHEN ISNULL(@OrderType,0)=0 THEN '' ELSE  'Order Type Changed ,'end+
			CASE WHEN ISNULL(@ContainertpeKeys,'')=''  THEN '' ELSE 'Properties Changed ,'end+
			CASE WHEN ISNULL(@BrokerRef,'')='' THEN '' ELSE 'BrokerRef Changed ,'end+
			CASE WHEN ISNULL(@BillofLading,'')=''  THEN '' ELSE 'BillOfLading Changed ,'end+
			CASE WHEN ISNULL(@MarketLocationKey,'')=''  THEN '' ELSE 'MarketLocation Changed ,'end+
			CASE WHEN ISNULL(@PickupAddrKey,0)=0 THEN '' ELSE 'Pickup Address Changed ,'end+
			CASE WHEN ISNULL(@DeliveryAddrKey,0)=0 THEN '' ELSE 'Delivery Address Changed ,'end+
			CASE WHEN ISNULL(@SenderInfo,'')='' THEN '' ELSE 'Sender Info Changed ,' end
			

	DECLARE @LogCounter INT = 1, @TempOrderKey INT,@OrderNo VARCHAR(50)  ;
	WHILE @LogCounter <= (SELECT COUNT(*) FROM #AuditTemp)
	BEGIN
	SELECT @TempOrderKey = TempOrderKey FROM #AuditTemp WHERE RowNum = @LogCounter;

	SELECT @OrderNo = OrderNo FROM OrderHeader WHERE OrderKey = @TempOrderKey
 
	INSERT INTO AuditLogDetail(DateCreated, CreateUser, RefType, RefId, RefKey, CommentType, Comments)
	VALUES (GETDATE(), @UserName, 'Order', @OrderNo, @TempOrderKey, 'Text', @Comments);

	SET @LogCounter += 1;
	END

	SET @Status=1;
	SET @Reason='Success';
END

			

