

/*
DECLARE @SiteId				VARCHAR(50) = 'Melrose',
		@DataKey			int = -1,
		@Json				nVARCHAR(max) =  '[{"DataKey":-1,"FileProcessKey":0,"originatorCode":null,"receiverCode":null,"workOrderNumber":null,"category":null,"createdBy":null,"workOrderDate":"0001-01-01T00:00:00","houseAirWayBillNumber":null,"shipmentReferenceNumber":null,"billOfLadingNumber":null,"vessel":null,"voyage":null,"portOfLoading":null,"portOfDischarge":null,"eta":"0001-01-01T00:00:00","shipper":null,"broker":null,"carrierCode":null,"isAccepted":false,"RejectReasonCode":null,"RejectMessage":null,"IsProcessed":false,"SiteID":"Melrose","ResponseType":null,"IsResponseSent":false,"ResponseSentDate":"0001-01-01T00:00:00","FileName":null,"TMS_OrderKey":0,"TMS_OrderNo":null,"TMS_OrderDate":"0001-01-01T00:00:00","ContainerList":null,"L11Lines":null,"TMS_CustKey":0,"TMS_SourceAddrKey":0,"TMS_DestinationAddrKey":0,"TMS_OrderTypeKey":0,"TMS_BorkerKey":0,"TMS_CarrierKey":0,"TMS_CSRKey":0,"UserKey":0,"SenderDetails":null,"TMS_MarketLocationKey":0,"Consignee":null,"OrderNo":null}]',
		@UserKey			int = 0,
		@IsSaved			bit = 0 ,
		@Reason				VARCHAR(500)='' ,
		@OrderKey			INT =0 ,
		@OrderNo			VARCHAR(50) = '' ,
		@OrderDate			DateTime	= '2020-01-01' 

Exec [TMS_integration_INSERTOrder_Melrose] @siteid, @DataKey, @Json, @UserKey, @IsSaved output, @Reason output, @OrderKey output, @OrderNo Output, @OrderDate output
SELECT @IsSaved, @Reason, @OrderKey,@OrderNo , @OrderDate
*/
CREATE ProcEDURE [dbo].[TMS_integration_InsertOrder_Melrose]
(
	@SiteId				VARCHAR(50),
	@DataKey			INT,
	@Json				NVARCHAR(MAX),
	@UserKey			INT = 0,
	@IsSaved			BIT = 0						OUTPUT,
	@Reason				VARCHAR(500)=''				OUTPUT,
	@OrderKey			INT =0						OUTPUT,
	@OrderNo			VARCHAR(50) = ''			OUTPUT,
	@OrderDate			DATETIME	= '2020-01-01'	OUTPUT
)
AS
BEGIN
    SET @OrderNo= REPLACE(REPLACE(@Orderno,'-',''),'.','')

	-- SELECT 'Test'

	INSERT INTO MelroseJsonData_Delete
	SELECT @DataKey,@Json,'TMS_integration_InsertOrder_Melrose'

	IF(@@SERVERNAME = 'JCTDEV')
		BEGIN
			SET @Json = REPLACE(REPLACE(@Json,'Melrose_ContainerList','ContainerList'),'Melrose_StopList','StopList')
		END

	DECLARE @Output	 BIT

	SET NOCOUNT ON
	SET FMTONLY OFF

	-- SET @OrderDate = 'aaaaaaa'

	IF(ISNULL(@Json,'') = '')
		BEGIN
			SET @IsSaved = 0
			SET @Reason = 'Data not found'
			RETURN
		END

	IF(@DataKey = -1)
		BEGIN
			SET @OrderDate =  '2020-01-01'
			-- EXEC Integration_JCB.dbo.Melrose_OrderDataAlert
			RETURN
		END


	IF(ISNULL(@DataKey,0) = 0 OR ISNULL(@UserKey,0) = 0)
	BEGIN
		SET @IsSaved = 0
		SET @Reason = 'No Order/user Information'
		RETURN
	END
	DECLARE @ErrorLocation	VARCHAR(50) = ''
	
		SET @Json = REPLACE(@Json, '0001-01-01T00:00:00','')
		CREATE TABLE #Header
		(
			SL						INT,
			DataKey					INT,
			FileProcessKey			INT,
			TMS_OrderKey			INT,
			TMS_CustKey				INT,
			TMS_SourceAddrKey		INT,
			TMS_DestinationAddrKey	INT,
			TMS_OrderTypeKey		INT,
			TMS_BorkerKey			INT,
			TMS_CarrierKey			INT,
			TMS_CSRKey				INT,
			shipmentReferenceNumber	VARCHAR(100),
			billOfLadingNumber		VARCHAR(100),
			workOrderNumber			VARCHAR(100),
			workOrderDate			DATETIME,
			ETADate					DATETIME,
			ContainerList			NVARCHAR(MAX),
			vessel					VARCHAR(100),
			ErrorLine				NVARCHAR(MAX),
			L11Lines				NVARCHAR(MAX),
			notes					NVARCHAR(MAX), 
			Consignee				VARCHAR(100),
			SENDer					VARCHAR(100),
			TMS_MarketLocationKey	INT,
			OrderNo					VARCHAR(50),
			BookingNo				VARCHAR(50)
		)

		INSERT INTO #Header ( SL,DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate,
			-- ErrorLine,L11Lines, notes, 
			Consignee, SENDer,TMS_MarketLocationKey,OrderNo, BookingNo)
		SELECT ROW_NUMBER() OVER (ORDER BY Datakey), DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate ,
			-- ErrorLine,L11Lines, notes, 
			Consignee, SENDer, TMS_MarketLocationKey, OrderNo, BookingNo
		FROM OPENJSON(@Json, '$')
		with (
			DataKey					INT				'$.DataKey',
			FileProcessKey			INT				'$.FileProcessKey',
			TMS_OrderKey			INT				'$.TMS_OrderKey',
			TMS_CustKey				INT				'$.TMS_CustKey',
			TMS_SourceAddrKey		INT				'$.TMS_SourceAddrKey',
			TMS_DestinationAddrKey	INT				'$.TMS_DestinationAddrKey',
			TMS_OrderTypeKey		INT				'$.TMS_OrderTypeKey',
			TMS_BorkerKey			INT				'$.TMS_BorkerKey',
			TMS_CarrierKey			INT				'$.TMS_CarrierKey',
			TMS_CSRKey				INT				'$.TMS_CSRKey',
			shipmentReferenceNumber	VARCHAR(100)	'$.shipmentReferenceNumber',
			billOfLadingNumber		VARCHAR(100)	'$.billOfLadingNumber',
			workOrderNumber			VARCHAR(100)	'$.workOrderNumber',
			workOrderDate			DATETIME		'$.workOrderDate',
			ETADate					DATETIME		'$.eta',
			vessel					VARCHAR(100)	'$.vessel',
			ContainerList			NVARCHAR(MAX)	'$.ContainerList' as JSON,
			--ErrorLine				NVARCHAR(MAX)	'$.ErrorLines' as JSON,
			--L11Lines				NVARCHAR(MAX)	'$.L11Lines' as JSON,
			--notes					NVARCHAR(MAX)	'$.notes' as JSON,
			Consignee				VARCHAR(100)	'$.Consignee',
			SENDer					VARCHAR(100)	'$.SENDerDetails',
			TMS_MarketLocationKey	INT				'$.TMS_MarketLocationKey',
			OrderNo					VARCHAR(50)		'$.OrderNo',
			BookingNo				VARCHAR(50)		'$.BookingNo'
		)
		

		SELECT * FROM #header
		
		DECLARE		@CustKey			int,
					@custID				VARCHAR(50),
					@BillToAddrKey		INT,
					@CreditLimt			DECIMAL(18,2),
					@Ach_Enabled		SMALLINT=NULL,
					@OrderStausKey		INT,
					@NewOrderKeyOut		INT,
					@HoldReasonKey		INT,
					@Ach_Amount			DECIMAL(18,2)=null,
					@BookingNo			VARCHAR(100)=NULL,
					@PriorityKey		SMALLINT=Null,
					@BaseRateAmount		DECIMAL(18,2),
					@SourceAddrKey		INT,
					@DestAddrkey		INT,
					@ETADate			DATETIME=NULL,
					@CreateUserkey	 INT




		DECLARE @i INT = 1 , @n INT = (SELECT COUNT(*) FROM #Header)

		DECLARE @ContJson nVARCHAR(max) = '';

		CREATE TABLE #container
			(
				ContainerKey			int,
				equipmentNumber			VARCHAR(50),
				TMS_ContainerSizeKey	int,
				TMSOrderDetailKey		int,
				StopList				NVARCHAR(max) ,
				ContainerProperties		NVARCHAR(MAX) ,
				grossWeight				decimal(18,5),
				weightUOM				VARCHAR(10),
				sealNumberList			VARCHAR(100),
				OrderKey				INT,
				DataKey					INT,
				IsOverWeight			VARCHAR(20),
				IsHazmat				VARCHAR(20),
				IsHot					VARCHAR(20),
				equipmentTypeCode		VARCHAR(20)
			)


			CREATE TABLE #stops
					(
						ContainerKey			INT,
						StopKey					INT,
						stopType				VARCHAR(50),
						TMS_RouteKey			INT,
						TMS_SourceAddrKey		INT,
						TMS_DestinationAddrKey	INT,
						TMS_LegKey				INT,
						ScheduledDate			DATETIME
					)
			
			CREATE TABLE #containerproperties
			(
				ContainerPropKey	INT,
				ContainerKey		INT,
				ContainerTypeKey	VARCHAR(50),
				TypeDescription		VARCHAR(100),
				IsSelected			BIT
			)

			DECLARE 
			@NewOrderDetailKey	INT,
			@New_CommentKey		INT,
			@OrderDetailStatus  SMALLINT,
			@ContCount			int,
			@RTContainerKey		int, 
			@TMS_ContainerSizeKey	smallint, 
			@TMSOrderDetailKey	int,
			@ContainerNo		VARCHAR(50),
			@ContainerId		VARCHAR(100),
			@grossWeight		int,			
			@weightUOM			VARCHAR(10),
			@sealNumberList		VARCHAR(100),
			@IsHazmat			VARCHAR(20),
			@IsOverWeight		VARCHAR(20),
			@ISHot				VARCHAR(20),
			@equipmentTypeCode	VARCHAR(20)
		


		DECLARE @CNT INT = 0

		WHILE(@i <= @n)
			BEGIN
				


				
		SELECT @CustKey = TMS_CustKey FROM #Header WHERE SL = @i

		SELECT @CustKey
		
		SELECT @CreditLimt=  ISNULL(CreditLimit,0), 
				@BillToAddrKey = BillToAddrKey,
				@Ach_Enabled= Ach_Required,
				@custID = CustID
			FROM dbo.Customer WHERE CustKey=@CustKey 

		
		
		
		SELECT @CNT = COUNT(1) 
		FROM 
		(SELECT CustKey,OrderNo  FROM OrderHeader WITH(NOLOCK)  WHERE custkey = @CustKey 
		UNION ALL
		SELECT CustKey,OrderNo  cnt FROM OrderHeader_Deleted WITH(NOLOCK) WHERE CustKey = @CustKey
		) A WHERE CustKey= @CustKey
		
	SET @OrderStausKey= ( SELECT [Status] FROM dbo.OrderStatus WITH(NOLOCK) WHERE [Description]='Open' )
		
		
	SET @CNT = ISNULL(@CNT,0) + 1

	

	SET @OrderDate= ( SELECT dbo.EST_GetDateTime() )

	SELECT 'OrderNo',@CNT,@custID, @OrderDate
		
		SET @OrderNo = ltrim(rtrim(Left(@custID,5))) +  CONVERT(VARCHAR, YEAR(@OrderDate)) +  
			convert(VARCHAR, CASE WHEN @cnt < 100 THEN 
				SUBSTRING( CONVERT(VARCHAR,100 + @CNT),2,2)
				else CONVERT(VARCHAR,100 + @CNT) END)
		
		SET @dataKey = (SELECT datakey from #header where sl = @i)

		DECLARE @SalesPersonKey INT = 0, @CSRKey INT = 0, @CSRManagerKey INT = 0
		SELECt @SalesPersonKey = SalesPersonKey,@CSRKey = CSRKey,@CSRManagerKey = CSRManagerKey  FROM Customer WHERE CustKey = @Custkey 


		-- SELECT * FROM #Header
		INSERT INTO dbo.OrderHeader(OrderNo, OrderDate,Csrkey, CustKey,   
					SourceAddrKey,  DestinationAddrKey,  RETURNAddrKey,
					OrderTypeKey, [Status], HoldReasonKey, Consignee,
					StatusDate, BrokerKey, BrokerRefNo, PurchaseOrder,
					CarrierKey, VesselName, BillOfLading, BookingNo, Ach_Enabled,Ach_Amount,
					[PriorityKey], CREATEDate, CREATEUserKey,
					BillToAddrKey,ETADate,BaseRateAmount, SENDerInfo, MarketLocationKey, SalesPersonKey,CSRManagerKey, OrderSource )
		SELECT
					@OrderNo, @OrderDate, CASE WHEN TMS_CSRKey = 0 THEN @CSRKey ELSE TMS_CSRKey END,TMS_CustKey, 
					NULL TMS_SourceAddrKey, NULL TMS_DestinationAddrKey, null,
					TMS_OrderTypeKey, @OrderStausKey,@HoldReasonKey, Consignee,
					GETDATE(),NULL TMS_BorkerKey, shipmentReferenceNumber, OrderNo,
					--TMS_CarrierKey, vessel, billOfLadingNumber, isnull(@BookingNo,workOrderNumber), @Ach_Enabled,@Ach_Amount,
					TMS_CarrierKey, vessel, billOfLadingNumber
					--, CASE WHEN TMS_OrderTypeKey = 2 THEN BookingNo ELSE  '' END
					, BookingNo
					, @Ach_Enabled,@Ach_Amount,
					@PriorityKey, GETDATE(), @UserKey
					,@BillToAddrKey,ETADate,@BaseRateAmount, SENDer , TMS_MarketLocationKey, @SalesPersonKey,@CSRManagerKey, 'Melrose'
		FROM		#Header  H
		WHERE		Sl = @i
		
		

		SET @NewOrderKeyOut =( SELECT SCOPE_IDENTITY() )

		SET @OrderKey= @NewOrderKeyOut

		--UPDATE OrderHeader SET  CsrKey = CASE WHEN ISNULL(CsrKey,0) = 0 THEN  @CSRKey ELSE CsrKey END  
		--FROM OrderHeader 
		--WHERE Orderkey = @orderkey

		UPDATE Integration_JCB.dbo.Melrose_Header SET  TMS_Orderkey = @OrderKey, TMS_OrderNo = @OrderNo, TMS_OrderDate  = @OrderDate
		WHERE DataKey = @DataKey 

		--SELECT		OH.BookingNo , H.BookingNo
		UPDATE		OH SET BookingNo = CASE WHEN H.category = 'export' THEN H.BookingNo ELSE '' END
		FROM		OrderHeader OH
		INNER JOIN	Integration_JCB.dbo.Melrose_Header H ON OH.OrderKey = H.TMS_OrderKey
		WHERE		ISNULL(H.BookingNo,'') <> '' AND ISNULL(OH.BookingNo,'')  = ''
					AND OrderKey = @OrderKey AND ISNULL(@OrderKey,0) > 0

		DECLARE @RecordCNT INT = (SELECT COUNT(*) FROM TMS_Integration_Header WHERE SiteID = @SiteId AND DataKey = @DataKey )

		IF(ISNULL(@RecordCNT,0) = 0)
		BEGIN
			INSERT INTO TMS_Integration_Header (SiteID, DataKey, WorkOrdernumber, WorKOrderDate, TMS_OrderKey)
			SELECT @SiteId, @dataKey, workOrderNumber, workOrderDate, @NewOrderKeyOut
			FROM #Header  WHERE Sl = @i
		END
		
		SELECT * FROM #Header



				SELECT @ContJson = ContainerList FROM #Header WHERE Sl = @i

				-- SELECT @ContJson
				IF(1 = 1)
				BEGIN
					
					INSERT INTO #container (ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, equipmentTypeCode,
						StopList, ContainerProperties,grossWeight,weightUOM, sealNumberList, OrderKey, Datakey,IsHazmat,IsOverWeight,IsHot )
					SELECT ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, equipmentTypeCode,
						StopList , ContainerProperties,grossWeight,weightUOM, sealNumberList, @OrderKey, @dataKey,IsHazmat,IsOverWeight,IsHot
					FROM OPENJSON(@ContJson,'$')
					With
					(
						ContainerKey			int				'$.ContainerKey',
						equipmentNumber			VARCHAR(50)		'$.equipmentNumber',
						TMS_ContainerSizeKey	int				'$.TMS_ContainerSizeKey',
						TMSOrderDetailKey		int				'$.TMSOrderDetailKey',
						StopList				nVARCHAR(max)	'$.StopList' as JSON,
						ContainerProperties		nvarchar(max)	'$.ContainerProperties' as JSON,
						grossWeight				decimal(18,5)	'$.grossWeight',
						weightUOM				VARCHAR(10)		'$.weightUOM',
						sealNumberList			VARCHAR(100)	'$.sealNumberList',
						isHazmat				VARCHAR(20)		'$.isHazmat',
						IsOverWeight			VARCHAR(20)		'$.IsOverWeight',
						IsHot					VARCHAR(20)		'$.IsHot',
						equipmentTypeCode		VARCHAR(100)	'$.equipmentTypeCode'
					)
					SELECT * FROM #container
									
					
				END
				SET @i = @i + 1
		END


		DECLARE @ContCnt	int = 0
			SELECT @ContCnt = COUNT(1) FROM #container
			IF(@ContCnt > 0)
			BEGIN
				DECLARE @StopList	nVARCHAR(max), 
					@ContainerKey	int
				DECLARE myCursor CURSOR LOCAL
				For SELECT StopList, ContainerKey FROM #container

				Open MyCursor
				Fetch next FROM MyCursor INTO @StopList, @ContainerKey
				while @@FETCH_STATUS = 0
				BEGIN
					INSERT INTO #stops (ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey, ScheduledDate)
					SELECT @ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey, ScheduledDate
					FROM OPENJSON(@StopList, '$')
					with (
						StopKey					int			'$.StopKey',
						stopType				VARCHAR(50) '$.stopType',
						TMS_RouteKey			int			'$.TMS_RouteKey',
						TMS_SourceAddrKey		int			'$.TMS_SourceAddrKey',
						TMS_DestinationAddrKey	int			'$.TMS_DestinationAddrKey',
						TMS_LegKey				int			'$.TMS_LegKey',
						ScheduledDate			DateTime	'$.ScheduledDate'
					)
					Fetch next FROM MyCursor INTO @StopList, @ContainerKey
				END
				CLOSE myCursor
				deallocate myCursor


				SELECT   ContainerProperties, ContainerKey from #container
				
				declare @ContainerProperties	nvarchar(max) 

				declare ContmyCursor CURSOR LOCAL
				For select ContainerProperties, ContainerKey from #container

				Open ContmyCursor
				Fetch next from ContmyCursor INTO @ContainerProperties, @ContainerKey
				while @@FETCH_STATUS = 0
				BEGIN
					insert into #containerproperties (ContainerKey,ContainerTypeKey,TypeDescription,IsSelected)
					select @ContainerKey, ContainerTypeKey,TypeDescription,IsSelected
					from OpenJson(@ContainerProperties, '$')
					with (
						ContainerTypeKey		INT			'$.ContainerTypeKey',
						TypeDescription			VARCHAR(50) '$.TypeDescription',
						IsSelected				BIT			'$.IsSelected'
					)
					Fetch next from ContmyCursor INTO @ContainerProperties, @ContainerKey
				END
				CLOSE ContmyCursor
				deallocate ContmyCursor



			END
	Select 1
	SELECT 'Container',* FROM #container
	SELECt 2
	SELECT 'Stops',* FROM #Stops

		DECLARE ContCursor CURSOR LOCAL
		FOR SELECT ContainerKey, equipmentNumber, equipmentTypeCode, TMS_ContainerSizeKey, TMSOrderDetailKey, grossWeight, weightUOM, sealNumberList, OrderKey, Datakey, IsHazmat,IsOverWeight,IsHot
		FROM #container

		Open ContCursor
		SET @ErrorLocation = 'Container'
		Fetch Next FROM ContCursor INTO @RTContainerKey, @ContainerNo, @equipmentTypeCode,  @TMS_ContainerSizeKey, @TMSOrderDetailKey ,
			@grossWeight, @weightUOM, @sealNumberList , @orderKey, @datakey , @IsHazmat,@IsOverWeight,@IsHot

		while @@FETCH_STATUS = 0
		BEGIN
			-- SELECt 'OD',  @orderKey
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			print @sealNumberList

			IF(Isnull(@ContainerNo,'') = '')
			BEGIN
				DECLARE @NoContCount int = 0
				SELECT @NoContCount = count(1) FROM orderdetail WHERE Containerno like 'JCTD%'
				SET @ContainerNo = 'JCTD' + Right(convert(VARCHAR(5), year(getdate())),2) + right(convert(VARCHAR(5),100 + MONTH(Getdate())),2) + 
					right(convert(VARCHAR(5),1000 + @NoContCount),3)
				update #container SET equipmentNumber = @ContainerNo WHERE ContainerKey = @ContainerKey
			END

			SET @TMS_ContainerSizeKey = (SELECT TOP 1 ContainerSizeKey FROM Containersize WHERE REPLACE(LTRIM(RTRIM([Description])),' ','') = REPLACE(LTRIM(RTRIM(@equipmentTypeCode)),' ','') )
			SET @TMS_ContainerSizeKey = ISNULL(@TMS_ContainerSizeKey,0)

			IF(@TMS_ContainerSizeKey = 0)
				BEGIN
					INSERT INTO Containersize
								(Description,WarehouseSizeMap)
					SELECT		@equipmentTypeCode, LEFT(@equipmentTypeCode,0)

					SET @TMS_ContainerSizeKey = @@IDENTITY
				END

			DECLARE @CustRefNo VARCHAR(50) = (SELECT BrokerRefNo FROM OrderHeader WHERE OrderKey = @OrderKey )

			DECLARE @OrderTypeKey	INT = 2

			IF(Isnull(@ContainerNo,'') = 'UNKNOWN')
			BEGIN
				exec ContainerNo_AutoGen @CustKey ,@OrderTypeKey ,@UserKey, @ContainerNo OUTPUT
				update #container SET equipmentNumber = @ContainerNo WHERE ContainerKey = @ContainerKey
			END

			INSERT INTO dbo.OrderDetail(OrderKey,ContainerID,ContainerNo,ContainerSizeKey, CustRefNo,
				Chassis,SealNo,[Weight],WeightUnit,
				[Status],StatusDate,CREATEUserKey,SourceAddrKey,
				DestinationAddrKey,CREATEDate, VesselETA,IsOverWeight,IsHazardus) 
			SELECT  @Orderkey , @ContainerId,@Containerno , @TMS_ContainerSizeKey ,@CustRefNo,
				null,ISNULL(@sealNumberList,''),@grossWeight, CASE WHEN LTRIM(RTRIM(@weightUOM)) IN ('KG','Kilograms','Kilogram') THEN 2 else 1 END ,
				@OrderDetailStatus, GETDATE(),@UserKey,@SourceAddrKey,
				@DestAddrKey,GETDATE(), @ETADate, @IsOverWeight,@IsHazmat
   
			SET @NewOrderDetailKey= ( SELECT SCOPE_IDENTITY() ) 

			UPDATE OD SET SourceAddrKey = OH.SourceAddrKey, DestinationAddrKey = OH.DestinationAddrKey
			FROM OrderDetail OD
			inner join OrderHeader OH on OD.orderkey = OH.OrderKey
			WHERE OH.OrderKey = @OrderKey and OD.SourceAddrKey is null and OH.SourceAddrKey is not null

			UPDATE OD SET BookingNo = OH.BookingNo
			FROM OrderDetail OD
			inner join OrderHeader OH on OD.orderkey = OH.OrderKey
			WHERE OH.OrderKey = @OrderKey and ISNULL(OH.BookingNo,'') <> ''

			UPDATE #container SET TMSOrderDetailKey = @NewOrderDetailKey WHERE ContainerKey = @RTContainerKey

			INSERT INTO TMS_Integration_Container (SiteID, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey)
			SELECT @SiteId, DataKey, ContainerKey, @ContainerNo, @NewOrderDetailKey
			FROM #container WHERE ContainerKey = @RTContainerKey


			DECLARE @Priority VARCHAR(20) = ''

			
			SELECT		TOP 1 @Priority = IsHot 
			FROM		#container  A
			WHERE		DataKey = @DataKey 


			UPDATE		A
			SET			PriorityKey = CASE WHEN @Priority = 'false' THEN 3 ELSE 1 END
			FROm		OrderHeader A
			WHERE		OrderKey = @OrderKey 


			SELECT * FROM #containerproperties
			DECLARE @TypeDesc VARCHAR(max) = '';
			SET @TypeDesc = (			SELECT DISTINCT 
					SUBSTRING(
						(
							SELECT ','+ST1.TypeDescription  AS [text()]
							FROM #containerproperties ST1
							WHERE ST1.ContainerKey = ST2.ContainerKey AND IsSelected = 1 AND ContainerKey = @RTContainerKey
							FOR XML PATH (''), TYPE
						).value('text()[1]','nvarchar(max)'), 2, 1000) TypeDescription
				FROM #containerproperties ST2 WHERE ContainerKey = @RTContainerKey ) 
			
			SELECT @NewOrderDetailKey AS OrderDetailKey,@TypeDesc AS TypeDesc,@CreateUserKey AS UserKey 

			IF ISNULL(LTRIM(RTRIM(@TypeDesc)),'')<>''
			BEGIN				
				--***********************Update Container Type items****************
					EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@TypeDesc,@CreateUserKey=@CreateUserKey
				--*****************************************************************			
			END


			/*
			DECLARE @Remarks  VARCHAR(500) = '', @CommentKey INT = 0, @ContainerTypeKey_Haz INT = 0, @ContainerTypeKey_OverWt INT = 0

			--SET @IsHazmat = 'true'
			--SET @IsOverWeight = 'true'

			IF(@IsHazmat = 'true')
				BEGIN
					SET @Remarks = 'Hazard,'
					SET @ContainerTypeKey_Haz = 1
				END

			IF(@IsOverWeight = 'true')
				BEGIN
					SET @Remarks = @Remarks + 'Over weight,'
					SET @ContainerTypeKey_OverWt = 2
				END
			
			IF(@Remarks <> '')
				BEGIN
					INSERT INTO Comment (Description,CreateDate,CreateUserKey,isDeleted)
					SELECT @Remarks,GETDATE(),@UserKey,0
					SET @CommentKey = @@IDENTITY

					INSERT INTO OrderDetailComments(OrderDetailKey,CommentKey)
					SELECT @NewOrderDetailKey, @CommentKey
				END
			IF(@ContainerTypeKey_Haz = 1)
				BEGIN
					INSERT INTO ContainerTypesLink (OrderDetailKey,CommentKey,ContainerTypeKey,IsSelected)
					SELECT @NewOrderDetailKey,@CommentKey,@ContainerTypeKey_Haz,1					
				END

			IF(@ContainerTypeKey_OverWt = 2)
				BEGIN
					INSERT INTO ContainerTypesLink (OrderDetailKey,CommentKey,ContainerTypeKey,IsSelected)
					SELECT @NewOrderDetailKey,@CommentKey,@ContainerTypeKey_OverWt,1
				END
			*/

			Fetch Next FROM ContCursor INTO @RTContainerKey, @ContainerNo,@equipmentTypeCode, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
				@grossWeight, @weightUOM, @sealNumberList, @orderkey, @datakey,@IsHazmat,@IsOverWeight,@IsHot

		END
		close ContCursor
		Deallocate ContCursor


		DECLARE @StopKey				INT,
				@stopType				VARCHAR(50),
				@TMS_RouteKey			INT,
				@TMS_SourceAddrKey		INT,
				@TMS_DestinationAddrKey	INT,
				@TMS_LegKey				INT,
				@OrdDetailKey			INT,
				@ContainerNo1			VARCHAR(20),
				@LegID					VARCHAR(100)
		

		--SELECT * FROM #container
		--SELECT * FROM #stops

		DECLARE RouteCursor CURSOR LOCAL
		FOR SELECT distinct StopKey, 1 TMS_LegKey, TMSOrderDetailKey, S.ContainerKey, C.equipmentNumber, OrderKey, Datakey
		FROM #container C
		inner join #stops S on C.ContainerKey = S.ContainerKey
		WHERE stopType in ('Ship FROM')
		order by StopKey

		/*
		Open RouteCursor
		SET @ErrorLocation = 'Route'
		Fetch Next FROM RouteCursor INTO @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @ContainerNo1, @OrderKey, @Datakey

		while @@FETCH_STATUS = 0
		BEGIN
			DECLARE @RouteKey	int = 0, @PickStopKey	int, @DelStopKey	int
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			DECLARE @RTSourceAddrKey	int,
					@RTDeliveryAddrKey	int,
					@SchPickup			DateTime,
					@SchDeliv			DateTime

			SELECT @RTSourceAddrKey = TMS_SourceAddrKey, @PickStopKey = StopKey , @SchPickup = ScheduledDate
				FROM #stops 
				WHERE ContainerKey = @ContainerKey and stopType in ( 'Ship FROM') and StopKey = @StopKey

			SELECT @RTDeliveryAddrKey = TMS_DestinationAddrKey, @DelStopKey = StopKey , @SchDeliv = ScheduledDate
				FROM #stops 
				WHERE ContainerKey = @ContainerKey and stopType in ( 'Ship To', 'RETURNed To') and StopKey = @StopKey + 1

			INSERT INTO [Routes]
			(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], 
				[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay],CutOffDate, 
				[SwitchTo], 
				[PortWaitingTimeFROM], [PortWaitingTimeTo], [CustomerWaitingTimeFROM], [CustomerWaitingTimeTo], 
				[FROMLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
				[Status], [DriverKey], [ActualDeparture], [ActualArrival], 
				[OdometerAtSource], [OdometerAtDestination], CREATEUserKey,CREATEDate,ChassisKey , LastUpdateDate
				--,ScheduledDeparture, ScheduledArrival, ScheduledPickupDate, PickupDateFROM, DeliveryDateFROM
			)
			SELECT 
				 @OrdDetailKey,@OrderKey,@TMS_LegKey,1,@RTSourceAddrKey,
				 null,NULL,null,null,null,
				 null,
				 NULL,NULL,NULL,NULL,
				 NULL,NULL,@RTDeliveryAddrKey,null,null,
				 1,null, NULL,NULL,
				 NULL,NULL, @UserKey,GETDATE(),NULL , Getdate()
				 --,@SchPickup, @SchDeliv, @SchPickup, @SchPickup, @SchDeliv
			SET @RouteKey = SCOPE_IDENTITY()

			--SELECT @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			--SELECT @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

			INSERT INTO TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			SELECT @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			
			INSERT INTO TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			SELECT @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey
	
			Fetch Next FROM RouteCursor INTO @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @ContainerNo1, @OrderKey, @Datakey
		END

		close RouteCursor
		Deallocate RouteCursor
		*/

		DECLARE @JsonData NVARCHAR(MAX)
		SET @JsonData = (SELECT  Datakey AS Datakey FROM #Header FOR JSON PATH)

		SELECt @JsonData

		EXEC TMS_integration_PickupDropAddressUpdate_Melrose @JsonData
	
		-- EXEC Integration_JCB.dbo.Melrose_OrderDataAlert

END

 
