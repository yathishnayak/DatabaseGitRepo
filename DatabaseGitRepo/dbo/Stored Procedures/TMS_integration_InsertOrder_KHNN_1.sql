


/*
declare @SiteId				varchar(50) = 'KHNN',
		@DataKey			int = 1714,
		@Json				nvarchar(max) = '{"DataKey":1714,"FileProcessKey":40315,"originatorCode":"KHNN-CLT","receiverCode":"JCTD-LAX","workOrderNumber":"9052405300-01","category":"Export/Outbound Dray","createdBy":"704-359-5051","workOrderDate":"2024-05-09T16:38:00","houseAirWayBillNumber":null,"shipmentReferenceNumber":"9052405300-01","billOfLadingNumber":null,"vessel":"MSC TOKYO","voyage":"GA423W","portOfLoading":"USLGB","portOfDischarge":"MYTPP","eta":"2024-05-27T00:00:00","shipper":null,"broker":null,"carrierCode":"MSCU","isAccepted":true,"RejectReasonCode":"","RejectMessage":"","IsProcessed":false,"SiteID":"Khnn","ResponseType":"Accept","IsResponseSent":true,"ResponseSentDate":"2024-05-09T17:00:14.347","FileName":"createWorkOrder_9052405300-01_JCTD-LAX_KHNN-CLT_1135597003.xml","TMS_OrderKey":0,"TMS_OrderNo":"Pending","TMS_OrderDate":"0001-01-01T00:00:00","ContainerList":[{"ContainerKey":1714,"equipmentNumber":"KHNN0001714","equipmentTypeCode":4510,"pieceCount":1,"grossWeight":6000,"weightUOM":"KG","volume":0,"volumeUOM":null,"freightDescription":null,"isHazmat":"Resin  3907990100","sealNumberList":null,"StopList":[{"StopKey":7042,"stopType":"Pickup","stopName":"Total Terminals International","stopNumber":1,"facilityCode":0,"stopReferenceNumber":0,"address1":"301 Hanjin Rd","city":"Long Beach","state":"CA","country":"US","postalCode":"90802","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":20304,"TMS_DestinationAddrKey":0,"TMS_LegKey":45,"LegSelectedItems":[{"LegKey":45,"LegID":"Port To Shipper"}],"_selectedLeg":{"LegKey":45,"LegID":"Port To Shipper","FromLocation":"Port","ToLocation":"Shipper","PickUpType":"Port"},"SourSelectedItems":[{"AddrKey":20304,"NameFull":"UNSPECIFIED,  ., Long Beach, 90810"}],"_LocationList":[]},{"StopKey":7043,"stopType":"Live Load","stopName":"SMOOTH-BOR PLASTICS","stopNumber":2,"facilityCode":0,"stopReferenceNumber":0,"address1":"15 DOPPLER","city":"IRVINE","state":null,"country":"US","postalCode":"92618","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":34029,"TMS_DestinationAddrKey":0,"TMS_LegKey":45,"_selectedLeg":{"LegKey":45,"LegID":"Port To Shipper","FromLocation":"Port","ToLocation":"Shipper","PickUpType":"Port"},"SourSelectedItems":[{"AddrKey":34029,"NameFull":"SMOOTH BOR PLASTICS, 15 DOPPLER, Irvine, 92618"}],"_LocationList":[]},{"StopKey":7044,"stopType":"Return","stopName":"Total Terminals International","stopNumber":3,"facilityCode":0,"stopReferenceNumber":0,"address1":"301 Hanjin Rd","city":"Long Beach","state":"CA","country":"US","postalCode":"90802","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":0,"TMS_DestinationAddrKey":20304,"TMS_LegKey":13,"LegSelectedItems":[{"LegKey":13,"LegID":"Shipper To Port"}],"_selectedLeg":{"LegKey":13,"LegID":"Shipper To Port","FromLocation":"Shipper","ToLocation":"Port","PickUpType":"Shipper"},"DestSelectedItems":[{"AddrKey":20304,"NameFull":"UNSPECIFIED,  ., Long Beach, 90810"}],"_LocationList":[]}],"TMS_ContainerSizeKey":12,"TMSOrderDetailKey":0,"ContSelectedItems":[{"ContainerSizeKey":12,"Description":"40 HC"}]}],"TMS_CustKey":2155,"TMS_SourceAddrKey":21248,"TMS_DestinationAddrKey":34029,"TMS_OrderTypeKey":2,"TMS_BorkerKey":5,"TMS_CarrierKey":6,"TMS_CSRKey":50,"UserKey":"29","ScheduleFiles":null,"ActualFiles":null,"InvoiceFiles":null,"DocKey990":0,"DocKey997":0,"DocUploaded990":"0001-01-01T00:00:00","DocUploaded997":"0001-01-01T00:00:00","IsArchived":false,"ArchiveDate":"0001-01-01T00:00:00","BookingNo":"038VK1230243","TMS_MarketLocationKey":2}',
		@UserKey			int = 29,
		@IsSaved			bit = 0 ,
		@Reason				varchar(500)='' ,
		@OrderKey			INT =0 ,
		@OrderNo			varchar(50) = '' ,
		@OrderDate			DateTime	= '2020-01-01' 

Exec [TMS_integration_InsertOrder_KHNN] @siteid, @DataKey, @Json, @UserKey, @IsSaved output, @Reason output, @OrderKey output, @OrderNo Output, @OrderDate output
Select @IsSaved, @Reason, @OrderKey,@OrderNo , @OrderDate
*/
CREATE PROCEDURE [dbo].[TMS_integration_InsertOrder_KHNN]
(
	@SiteId				varchar(50),
	@DataKey			int,
	@Json				nvarchar(max),
	@UserKey			int = 0,
	@IsSaved			bit = 0 OUTPUT,
	@Reason				varchar(500)='' output,
	@OrderKey			INT =0 OUTPUT,
	@OrderNo			varchar(50) = '' output,
	@OrderDate			DateTime	= '2020-01-01' output
)
AS
BEGIN
    SET @OrderNo= Replace(REPLACE(@Orderno,'-',''),'.','')

	SET NOCOUNT ON
	SET FMTONLY OFF

	if(ISNULL(@Json,'') = '')
	Begin
		set @IsSaved = 0
		set @Reason = 'Data not found'
		return
	End
	if(ISNULL(@DataKey,0) = 0 OR ISNULL(@UserKey,0) = 0)
	Begin
		set @IsSaved = 0
		set @Reason = 'No Order/user Information'
		return
	end

	Begin Transaction
	Begin Try
		set @Json = replace(@Json, '0001-01-01T00:00:00','')
		create table #Header
		(
			DataKey					int,
			FileProcessKey			int,
			TMS_OrderKey			int,
			TMS_CustKey				int,
			TMS_SourceAddrKey		int,
			TMS_DestinationAddrKey	int,
			TMS_OrderTypeKey		int,
			TMS_BorkerKey			int,
			TMS_CarrierKey			int,
			TMS_CSRKey				int,
			shipmentReferenceNumber	varchar(100),
			billOfLadingNumber		varchar(100),
			workOrderNumber			varchar(100),
			workOrderDate			DateTime,
			ETADate					Datetime,
			ContainerList		nvarchar(max),
			vessel					varchar(100),
			TMS_MarketLocationKey	INT,
			BookingNo				varchar(50)
		)

		insert into #Header ( DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel, BookingNo,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate, TMS_MarketLocationKey )
		select DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel, BookingNo,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate , TMS_MarketLocationKey
		from OpenJson(@Json, '$')
		with (
			DataKey					int '$.DataKey',
			FileProcessKey			int '$.FileProcessKey',
			TMS_OrderKey			int	'$.TMS_OrderKey',
			TMS_CustKey				int '$.TMS_CustKey',
			TMS_SourceAddrKey		int '$.TMS_SourceAddrKey',
			TMS_DestinationAddrKey	int '$.TMS_DestinationAddrKey',
			TMS_OrderTypeKey		int	'$.TMS_OrderTypeKey',
			TMS_BorkerKey			int '$.TMS_BorkerKey',
			TMS_CarrierKey			int '$.TMS_CarrierKey',
			TMS_CSRKey				int '$.TMS_CSRKey',
			shipmentReferenceNumber	varchar(100) '$.shipmentReferenceNumber',
			billOfLadingNumber		varchar(100) '$.billOfLadingNumber',
			workOrderNumber			varchar(100) '$.workOrderNumber',
			workOrderDate			DateTime	 '$.workOrderDate',
			ETADate					Datetime	 '$.eta',
			vessel					varchar(100) '$.vessel',
			ContainerList		nvarchar(max)	 '$.ContainerList' as JSON,
			TMS_MarketLocationKey	INT			 '$.TMS_MarketLocationKey',
			BookingNo				varchar(50)	 '$.BookingNo'
		)
	
		declare @ContJson nvarchar(max) = '';
		select @ContJson = ContainerList from #Header

		if(isnull(@ContJson,'') <>'')
		Begin
			create table #container
			(
				ContainerKey			int,
				equipmentNumber			varchar(50),
				TMS_ContainerSizeKey	int,
				TMSOrderDetailKey		int,
				StopList			nvarchar(max) ,
				ContainerProperties		NVARCHAR(MAX) ,
				grossWeight				decimal(18,5),
				weightUOM				varchar(10),
				sealNumberList			varchar(100)
			)

			insert into #container (ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList, ContainerProperties,grossWeight,weightUOM, sealNumberList )
			select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList , ContainerProperties, grossWeight,weightUOM, sealNumberList
			from OpenJson(@ContJson,'$')
			With
			(
				ContainerKey			int				'$.ContainerKey',
				equipmentNumber			varchar(50)		'$.equipmentNumber',
				TMS_ContainerSizeKey	int				'$.TMS_ContainerSizeKey',
				TMSOrderDetailKey		int				'$.TMSOrderDetailKey',
				StopList				nvarchar(max)	'$.StopList' as JSON,
				ContainerProperties		nvarchar(max)	'$.ContainerProperties' as JSON,
				grossWeight				decimal(18,5)	'$.grossWeight',
				weightUOM				varchar(10)		'$.weightUOM',
				sealNumberList			varchar(100)	'$.sealNumberList'
			)
			--select * from #container

			create table #stops
			(
				ContainerKey			int,
				StopKey					int,
				stopType				varchar(50),
				TMS_RouteKey			int,
				TMS_SourceAddrKey		int,
				TMS_DestinationAddrKey	int,
				TMS_LegKey				int
			)

			CREATE TABLE #containerproperties
			(
				ContainerPropKey	INT,
				ContainerKey		INT,
				ContainerTypeKey	VARCHAR(50),
				TypeDescription		VARCHAR(100),
				IsSelected			BIT
			)


			declare @ContCnt	int = 0
			select @ContCnt = COUNT(1) from #container
			if(@ContCnt > 0)
			begin
				declare @StopList	nvarchar(max), 
					@ContainerKey	int
				declare myCursor CURSOR LOCAL
				For select StopList, ContainerKey from #container

				Open MyCursor
				Fetch next from MyCursor INTO @StopList, @ContainerKey
				while @@FETCH_STATUS = 0
				BEGIN
					insert into #stops (ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey)
					select @ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey
					from OpenJson(@StopList, '$')
					with (
						StopKey					int			'$.StopKey',
						stopType				varchar(50) '$.stopType',
						TMS_RouteKey			int			'$.TMS_RouteKey',
						TMS_SourceAddrKey		int			'$.TMS_SourceAddrKey',
						TMS_DestinationAddrKey	int			'$.TMS_DestinationAddrKey',
						TMS_LegKey				int			'$.TMS_LegKey'
					)
					Fetch next from MyCursor INTO @StopList, @ContainerKey
				END
				CLOSE myCursor
				deallocate myCursor

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

			end
		end
		declare @HeadCnt	int = 0,
				@ContainerCnt	int = 0,
				@StopCnt	int = 0

		select @HeadCnt = COUNT(1) from #Header
		select @ContainerCnt = COUNT(1) from #container
		Select @StopCnt = COUNT(1) from #stops

		if(@HeadCnt > 0 and @ContainerCnt > 0 and @StopCnt > 0)
		Begin

			-- ORDER HEADER INSERT ********************************************
			Declare 
				@CustKey		 int,
				@custID			 varchar(50),
				@BillToAddrKey   INT,
				@Csrkey			 INT=NULL,
				@SourceAddrkey	 INT,
				@DestAddrkey	 INT,
				@ReturnAddrkey	 INT= NULL,
				@OrderTypeKey	 SMALLINT,
				@Status			 SMALLINT=12,
				@BrokerKey		 int,
				@BrokerrefNo	 VARCHAR(100)=NULL,
				@CarrierKey		 INT=NULL,
				@VesselName		 VARCHAR(100)=NULL,
				@BillOfLading	 VARCHAR(100)=NULL,
				@BookingNo		 VARCHAR(100)=NULL,
				@Ach_Enabled	 SMALLINT=NULL,
				@Ach_Amount		 DECIMAL(18,2)=null,
				@PriorityKey	 SMALLINT=Null,
				@Comment		 VARCHAR(max)=NULL,
				@CreateUserkey	 INT,
				@ETADate		 DATETIME=NULL,
				@BaseRateAmount	 DECIMAL(18,2)
				


			DECLARE @NewCommentKeyOut INT
			DECLARE @NewOrderKeyOut   INT
			DECLARE @Ouput			  BIT
			DECLARE @CustomerKey	  INT
			DECLARE @OrderStausKey SMALLINT
			DECLARE @CreditLimt DECIMAL(18,2)
			DECLARE @HoldReasonKey SMALLINT
			DECLARE @ESTDATE DATETIME
			--*********************Time Zone to EST*********

			SET @OrderDate= ( SELECT dbo.EST_GetDateTime() )

			--SET @ESTDATE= ( SELECT dbo.EST_GetDateTime() )

			--**********************************************
			SET @HoldReasonKey= NULL

			Select @CustKey = TMS_CustKey from #Header
			Update Customer Set BillToAddrKey = AddrKey where CustKey = @CustKey and BillToAddrKey is null

			SELECT @CreditLimt=  ISNULL(CreditLimit,0), 
				@BillToAddrKey = BillToAddrKey,
				@Ach_Enabled= Ach_Required,
				@custID = CustID
			FROM dbo.Customer WHERE CustKey=@CustKey 

			SET @OrderStausKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='Open' )

			SET @CustomerKey = @CustKey

			IF @CreditLimt <= 0 AND ISNULL(@Ach_Amount,0)<=0 AND @Ach_Enabled = 1
			BEGIN
				SET @OrderStausKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='On Hold' )
				SET @HoldReasonKey= ( SELECT HoldReasonKey FROM Holdreason WHERE [Description]='Credit Hold' )
			END

			IF  @CreditLimt <= 0 AND ISNULL(@Ach_Amount,0)>0
			BEGIN
				SET @OrderStausKey = ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='Open' )
			END

			IF  @CreditLimt > 0  
			BEGIN
				SET @OrderStausKey= ( SELECT [Status] from dbo.OrderStatus WHERE [Description]='Open' )
			END
		
			IF @Csrkey=0 OR @Csrkey=''
			BEGIN
				SET @Csrkey=NULL
			END

			SET @Ouput=0

			Select @BrokerKey = TMS_BorkerKey from #Header
			IF @BrokerKey=0 
			BEGIN 
				SET @BrokerKey=NULL
			END

			DECLARE @CNT INT = 0
			SELECT @CNT = COUNT(1) 
			FROM 
			(select CustKey, OrderNo from OrderHeader where custkey = @CustKey 
			union all
			select CustKey,OrderNo  cnt from OrderHeader_Deleted where CustKey = @CustKey
			) A WHERE CustKey= @CustKey


			SET @CNT = ISNULL(@CNT,0) + 1
			
			SET @OrderNo = ltrim(rtrim(Left(@custID,5))) +  CONVERT(varchar, YEAR(@OrderDate)) +  
				convert(varchar, case when @cnt < 100 then 
					substring( CONVERT(VARCHAR,100 + @CNT),2,2)
					else CONVERT(VARCHAR,100 + @CNT) END)


			INSERT INTO dbo.OrderHeader(OrderNo, OrderDate,Csrkey, CustKey,   
						SourceAddrKey,  DestinationAddrKey,  ReturnAddrKey,
						OrderTypeKey, [Status], HoldReasonKey, 
						StatusDate, BrokerKey, BrokerRefNo, 
						CarrierKey, VesselName, BillOfLading, BookingNo, Ach_Enabled,Ach_Amount,
						[PriorityKey], CreateDate, CreateUserKey,
						BillToAddrKey,ETADate,BaseRateAmount, IntegrationWONo, MarketLocationKey, OrderSource)
			Select
						@OrderNo, @OrderDate, TMS_CSRKey,TMS_CustKey, 
						TMS_SourceAddrKey, TMS_DestinationAddrKey, null,
						TMS_OrderTypeKey, @OrderStausKey,@HoldReasonKey, 
						GETDATE(),TMS_BorkerKey, shipmentReferenceNumber, 
						TMS_CarrierKey, vessel, billOfLadingNumber, BookingNo, @Ach_Enabled,@Ach_Amount,
						@PriorityKey, GETDATE(), @CreateUserkey
						,@BillToAddrKey,ETADate,@BaseRateAmount, workOrderNumber, TMS_MarketLocationKey, 'EDI-KHNN'
			From #Header

			SET @NewOrderKeyOut =( SELECT SCOPE_IDENTITY() )

			insert into TMS_Integration_Header (SiteID, DataKey, WorkOrdernumber, WorKOrderDate, TMS_OrderKey)
			select @SiteId, @DataKey, workOrderNumber, workOrderDate, @NewOrderKeyOut
			from #Header
		
			IF ISNULL(LTRIM(RTRIM(@Comment)),'')<>''		
			BEGIN
				INSERT INTO dbo.Comment(Description,CreateDate,CreateUserKey)
				VALUES (@Comment, GETDATE(),@CreateUserkey)

				SET @NewCommentKeyOut= ( SELECT SCOPE_IDENTITY() )

				INSERT INTO dbo.OrderHeaderComments(OrderKey,CommentKey)
				VALUES (@NewOrderKeyOut, @NewCommentKeyOut);		
			END				
			
			SET @OrderKey= @NewOrderKeyOut
		end
	
		-- ORDER DETAIL CREATE **************************************************
		DECLARE 
			@NewOrderDetailKey	INT,
			@New_CommentKey		INT,
			@OrderDetailStatus  SMALLINT,
			@ContCount			int,
			@RTContainerKey		int, 
			@TMS_ContainerSizeKey	smallint, 
			@TMSOrderDetailKey	int,
			@ContainerNo		varchar(50),
			@ContainerId		varchar(100),
			@grossWeight		int,			
			@weightUOM			varchar(10),
			@sealNumberList		varchar(100)

		DECLARE ContCursor CURSOR LOCAL
		FOR Select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, grossWeight, weightUOM, sealNumberList 
		from #container

		Open ContCursor

		Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
			@grossWeight, @weightUOM, @sealNumberList

		while @@FETCH_STATUS = 0
		BEGIN
			SET @Comment= LTRIM(RTRIM(@Comment))
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			print @sealNumberList

			If(Isnull(@ContainerNo,'') = '')
			Begin
				declare @NoContCount int = 0
				select @NoContCount = count(1) from orderdetail where Containerno like 'JCTD%'
				SEt @ContainerNo = 'JCTD' + Right(convert(varchar(5), year(getdate())),2) + right(convert(varchar(5),100 + MONTH(Getdate())),2) + 
					right(convert(varchar(5),1000 + @NoContCount),3)
				update #container set equipmentNumber = @ContainerNo where ContainerKey = @ContainerKey
			End

			INSERT INTO dbo.OrderDetail(OrderKey,ContainerID,ContainerNo,ContainerSizeKey,
				Chassis,SealNo,[Weight],WeightUnit,
				[Status],StatusDate,CreateUserKey,SourceAddrKey,
				DestinationAddrKey,CreateDate, VesselETA) 
			SELECT  @Orderkey , @ContainerId,@Containerno , @TMS_ContainerSizeKey ,
				null,isnull(@sealNumberList,'NA'),@grossWeight, case when LTRIM(RTRIM(@weightUOM)) IN ('KG','Kilograms','Kilogram') then 2 else 1 end ,
				@OrderDetailStatus, GETDATE(),@CreateUserKey,@SourceAddrKey,
				@DestAddrKey,GETDATE(), @ETADate
   
			SET @NewOrderDetailKey= ( SELECT SCOPE_IDENTITY() ) 

			update OD set SourceAddrKey = OH.SourceAddrKey, DestinationAddrKey = OH.DestinationAddrKey
			from OrderDetail OD
			inner join OrderHeader OH on OD.orderkey = OH.OrderKey
			where OH.OrderKey = @OrderKey and OD.SourceAddrKey is null and OH.SourceAddrKey is not null

			update #container set TMSOrderDetailKey = @NewOrderDetailKey where ContainerKey = @RTContainerKey

			insert into TMS_Integration_Container (SiteID, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey)
			select @SiteId, @DataKey, ContainerKey, @ContainerNo, @NewOrderDetailKey
			from #container

			--IF ISNULL(LTRIM(RTRIM(@Comment)),'')<>''
			--BEGIN
			--	--***********************Update Container Type items****************
			--		EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@Comment,@CreateUserKey=@CreateUserKey
			--	--*****************************************************************			
			--END	

			-- SELECT * FROM #containerproperties
			DECLARE @TypeDesc VARCHAR(max) = '';
			SET @TypeDesc = (			SELECT DISTINCT 
					SUBSTRING(
						(
							SELECT ','+ST1.TypeDescription  AS [text()]
							FROM #containerproperties ST1
							WHERE ST1.ContainerKey = ST2.ContainerKey AND IsSelected = 1 AND ContainerKey = @RTContainerKey
							FOR XML PATH (''), TYPE
						).value('text()[1]','nvarchar(max)'), 2, 1000) TypeDescription
				FROM #containerproperties ST2 WHERE ContainerKey = @RTContainerKey) 

			SELECT @NewOrderDetailKey AS OrderDetailKey,@TypeDesc AS TypeDesc,@CreateUserKey AS UserKey 
			-- SELECT * INTO TESTCONTDATA FROM (SELECT @NewOrderDetailKey AS OrderDetailKey,@TypeDesc AS TypeDesc,@CreateUserKey AS UserKey) A
			IF ISNULL(LTRIM(RTRIM(@TypeDesc)),'')<>''
			BEGIN
	
				--***********************Update Container Type items****************
					EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@TypeDesc,@CreateUserKey=@CreateUserKey
				--*****************************************************************			
			END




			Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
				@grossWeight, @weightUOM, @sealNumberList
		end
		close ContCursor
		Deallocate ContCursor
		-- END OF CONTAINER CREATE *********************************
		
		-- ROUTES CREATE ********************************************
		Declare @StopKey					int,
				@stopType				varchar(50),
				@TMS_RouteKey			int,
				@TMS_SourceAddrKey		int,
				@TMS_DestinationAddrKey	int,
				@TMS_LegKey				int,
				@OrdDetailKey			int

		DECLARE RouteCursor CURSOR LOCAL
		FOR Select distinct StopKey, TMS_LegKey, TMSOrderDetailKey, S.ContainerKey, stopType
		from #container C
		inner join #stops S on C.ContainerKey = S.ContainerKey
		where stopType in ('Pickup', 'Live Load', 'Return')

		Open RouteCursor

		Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @stopType

		while @@FETCH_STATUS = 0
		BEGIN
			declare @RouteKey	int = 0, @PickStopKey	int, @DelStopKey	int
			SET @Comment= LTRIM(RTRIM(@Comment))
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			declare @RTSourceAddrKey	int,
					@RTDeliveryAddrKey	int
			if(@stopType = 'Pickup' OR @stopType = 'Live Load' )
			Begin
				select top 1 @RTSourceAddrKey = TMS_SourceAddrKey, @PickStopKey = StopKey 
					from #stops where ContainerKey = @ContainerKey 
					and stopType in ( 'Pickup' , 'Live Load')
					Order by StopKey 
			End
			if(@stopType = 'Delivery' OR @stopType = 'Live Unload' OR @stopType = 'Live Load')
			Begin
				select top 1 @RTDeliveryAddrKey = TMS_DestinationAddrKey, @DelStopKey = StopKey 
					from #stops where ContainerKey = @ContainerKey 
					and stopType in ( 'Delivery', 'Live Unload', 'Live Load')
					order by StopKey Desc

			End
			if(@stopType = 'Return')
			Begin

				select @RTDeliveryAddrKey = TMS_DestinationAddrKey
					from #stops where ContainerKey = @ContainerKey and stopType in ( 'Return' )

				update OrderHeader set ReturnAddrKey = @RTDeliveryAddrKey
				where OrderKey = @OrderKey

			End
			INSERT INTO [Routes]
			(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], [PickupDateFrom], [PickupDateTo],
				[DeliveryDateFrom],[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay],CutOffDate, 
				[SwitchTo], 
				[PortWaitingTimeFrom], [PortWaitingTimeTo], [CustomerWaitingTimeFrom], [CustomerWaitingTimeTo], 
				[FromLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
				[Status], [DriverKey], [ScheduledPickupDate], [ScheduledArrival], [ActualDeparture], [ActualArrival], 
				[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey
			)
			select 
				 @OrdDetailKey,@OrderKey,@TMS_LegKey,1,@RTSourceAddrKey,null,null,
				 null,null,NULL,null,null,null,
				 null,
				 NULL,NULL,NULL,NULL,
				 NULL,NULL,@RTDeliveryAddrKey,null,null,1,null,null,null,NULL,NULL,NULL,NULL,
				 @CreateUserKey,GETDATE(),NULL
			Set @RouteKey = SCOPE_IDENTITY()

			

			Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @stopType
		end

		close RouteCursor
		Deallocate RouteCursor
		-- END OF ROUTES CREATE **************************************

		Commit Transaction

		set @IsSaved = 1
		set @Reason = 'Saved Successfully'

		SET @Ouput=1
		SELECT @Ouput AS Result
	End Try
	Begin Catch
		Set @Reason = ERROR_MESSAGE()
		print @reason
		Rollback Transaction
		Set @Ouput = 0
		
	End Catch
END

