
/*
declare @SiteId				varchar(50) = 'FLEXPORT',
		@DataKey			int = 1675,
		@Json				nvarchar(max) = '
{"DataKey":1675,"FileProcessKey":3905,"originatorCode":"FLEXPORT       ","receiverCode":"IPGL           ","workOrderNumber":"000002327","category":"Export","createdBy":null,"workOrderDate":"2023-10-11T16:46:00","houseAirWayBillNumber":"","shipmentReferenceNumber":"FLEX-2303209A-5476226","billOfLadingNumber":null,"vessel":"MOL CREATION","voyage":"089W","portOfLoading":"USLAX","portOfDischarge":"CNSHG","eta":"2023-11-12T12:00:00","shipper":"FLEXPORT       ","broker":null,"carrierCode":"ONE- Ocean Network Express","isAccepted":true,"RejectReasonCode":"","RejectMessage":"","IsProcessed":false,"SiteID":"flexport","ResponseType":"Reject","IsResponseSent":false,"ResponseSentDate":"0001-01-01T00:00:00","FileName":"204_IPGL_1eb127737153f14beae44b9f7feb2e57_20231011164618-2023-10-11T16-46-18Z.edi","TMS_OrderKey":0,"TMS_OrderNo":"Pending","TMS_OrderDate":"0001-01-01T00:00:00","ContainerList":[{"ContainerKey":1675,"equipmentNumber":null,"equipmentTypeCode":"42G0","pieceCount":0,"grossWeight":55401,"weightUOM":"Kilograms","volume":0,"volumeUOM":null,"freightDescription":null,"isHazmat":null,"sealNumberList":"","StopList":[{"StopKey":3349,"stopType":"Ship From","stopName":"Junction Collaborative Transports(PLEASE USE Junction Cargo ","stopNumber":1,"facilityCode":"SF","stopReferenceNumber":1,"address1":"100 W VICTORIA ST FIRMS-","city":"Long Beach","state":"CA","country":"US","postalCode":"90805","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":18873,"TMS_DestinationAddrKey":0,"TMS_LegKey":11,"ScheduledDate":"2023-10-11T01:00:00","_selectedLeg":{"LegKey":11,"LegID":"Yard To Port","FromLocation":"Yard","ToLocation":"Port","PickUpType":"Yard"},"LegSelectedItems":[{"LegKey":11,"LegID":"Yard To Port","FromLocation":"Yard","ToLocation":"Port","PickUpType":"Yard"}],"_LocationList":[],"SourSelectedItems":[{"Name":"JCT-Arnold","AddrKey":18873,"AddrName":"JCT-Arnold","Address1":"JCT Arnold Yard, Arnold Ctr Rd","Address2":" ","City":"Long Beach","State":"California","ZipCode":"90805","Country":"   ","Type":"Yard","NameFull":"JCT-Arnold, JCT Arnold Yard, Arnold Ctr Rd, Long Beach, 90805"}]},{"StopKey":3350,"stopType":"Ship To","stopName":"Los Angeles, CA","stopNumber":2,"facilityCode":"ST","stopReferenceNumber":2,"address1":"Los Angeles, CA FIRMS-","city":"Los Angeles","state":"CA","country":"US","postalCode":"00000","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":0,"TMS_DestinationAddrKey":24042,"TMS_LegKey":11,"ScheduledDate":"2023-10-12T02:00:00","_selectedLeg":{"LegKey":11,"LegID":"Yard To Port","FromLocation":"Yard","ToLocation":"Port","PickUpType":"Yard"},"LegSelectedItems":[{"LegKey":11,"LegID":"Yard To Port","FromLocation":"Yard","ToLocation":"Port","PickUpType":"Yard"}],"_LocationList":[],"DestSelectedItems":[{"Name":"Los Angeles County Department ","AddrKey":24042,"AddrName":"Los Angeles County Department ","Address1":"21415-21615, Plummer St..","Address2":"","City":"CHATSWORTH","State":"","ZipCode":"","Country":"   ","Type":"PORT","NameFull":"Los Angeles County Department , 21415-21615, Plummer St.., CHATSWORTH, "}]}],"TMS_ContainerSizeKey":15,"TMSOrderDetailKey":0,"ContSelectedItems":[{"ContainerSizeKey":15,"Description":"40 STD"}]}],"TMS_CustKey":1966,"TMS_SourceAddrKey":20168,"TMS_DestinationAddrKey":24042,"TMS_OrderTypeKey":2,"TMS_BorkerKey":5,"TMS_CarrierKey":101,"TMS_CSRKey":53,"UserKey":"29","IsConfirmed":true,"ConfirmDate":"2023-10-11T10:26:20.823","ErrorLines":null,"L11Lines":[{"Description":"1eb127737153f14beae44b9f7feb2e57","EDIDescription":"MutuallyDefined","RefData":"ZZ","RefEDIID":"ZZ"},{"Description":null,"EDIDescription":"OfferGroup","RefData":"Delivery Order","RefEDIID":"OK"}],"notes":[{"NoteLine":"FLEX-2303209A-2"},{"NoteLine":"CRD- PORT CUT- 10/13 RICDDD203800 Truck BOL- 3209398 and 3210465"}],"ScheduleFiles":null,"ActualFiles":null,"InvoiceFiles":null,"ProcessStatus":null,"ProcStatusDate":"0001-01-01T00:00:00","ProcStatusDataKey":0,"ProcworkOrderNumber":null,"ProcFileProcessKey":0,"IsArchived":false,"ArchiveDate":"0001-01-01T00:00:00"}',
		@UserKey			int = 29,
		@IsSaved			bit = 0 ,
		@Reason				varchar(500)='' ,
		@OrderKey			INT =0 ,
		@OrderNo			varchar(50) = '' ,
		@OrderDate			DateTime	= '2020-01-01' 

Exec [TMS_integration_InsertOrder_Flexport_shiva] @siteid, @DataKey, @Json, @UserKey, @IsSaved output, @Reason output, @OrderKey output, @OrderNo Output, @OrderDate output
Select @IsSaved, @Reason, @OrderKey,@OrderNo , @OrderDate
*/
CREATE PROCEDURE [dbo].[TMS_integration_InsertOrder_Flexport_shiva]
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
	Declare @ErrorLocation	varchar(50) = ''

	Begin Transaction
	Begin Try
		SEt @Json = replace(@Json, '0001-01-01T00:00:00','')
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
			ErrorLine			nvarchar(max),
			L11Lines			nvarchar(max),
			notes				nvarchar(max)
		)

		insert into #Header ( DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate,
			ErrorLine,L11Lines, notes )
		select DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate ,
			ErrorLine,L11Lines, notes
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
			ContainerList		nvarchar(max)	'$.ContainerList' as JSON,
			ErrorLine			nvarchar(max)	'$.ErrorLines' as JSON,
			L11Lines			nvarchar(max)	'$.L11Lines' as JSON,
			notes				nvarchar(max)	'$.notes' as JSON
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
				grossWeight				decimal(18,5),
				weightUOM				varchar(10),
				sealNumberList			varchar(100)
			)

			insert into #container (ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList, grossWeight,weightUOM, sealNumberList )
			select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList , grossWeight,weightUOM, sealNumberList
			from OpenJson(@ContJson,'$')
			With
			(
				ContainerKey			int			'$.ContainerKey',
				equipmentNumber			varchar(50)	'$.equipmentNumber',
				TMS_ContainerSizeKey	int			'$.TMS_ContainerSizeKey',
				TMSOrderDetailKey		int			'$.TMSOrderDetailKey',
				StopList				nvarchar(max) '$.StopList' as JSON,
				grossWeight				decimal(18,5) '$.grossWeight',
				weightUOM				varchar(10) '$.weightUOM',
				sealNumberList			varchar(100) '$.sealNumberList'
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
				TMS_LegKey				int,
				ScheduledDate			DateTime
			)

			Create Table #Comments
			(
				CommentLine				varchar(5000)
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
					insert into #stops (ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey, ScheduledDate)
					select @ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey, ScheduledDate
					from OpenJson(@StopList, '$')
					with (
						StopKey					int			'$.StopKey',
						stopType				varchar(50) '$.stopType',
						TMS_RouteKey			int			'$.TMS_RouteKey',
						TMS_SourceAddrKey		int			'$.TMS_SourceAddrKey',
						TMS_DestinationAddrKey	int			'$.TMS_DestinationAddrKey',
						TMS_LegKey				int			'$.TMS_LegKey',
						ScheduledDate			DateTime	'$.ScheduledDate'
					)
					Fetch next from MyCursor INTO @StopList, @ContainerKey
				END
				CLOSE myCursor
				deallocate myCursor
			end
		end
		--select * from #stops

		declare @retToCnt int = 0
		select @retToCnt = COUNT(1) from #stops where stopType = 'Returned to'
		if(@retToCnt > 0)
		Begin
			
			update #stops set StopKey = StopKey + 1 where stopType = 'Returned to'

			insert into #stops (ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey, ScheduledDate)
			select ContainerKey,  StopKey + 1, 'Ship From', TMS_RouteKey, TMS_DestinationAddrKey, 0, 
					(Select TMS_LegKey from #stops where stopType = 'Returned to') as TMS_LegKey, ScheduledDate
			from #stops 
			where StopKey = 2
			--select * from #stops order by StopKey
		end
		
		Declare @ErrorLine nvarchar(max) = '',
				@L11Line	nvarchar(max) = '',
				@Notes		nvarchar(max) = ''

		select @ErrorLine = A.ErrorLine,
				@L11Line = A.L11Lines,
				@Notes = A.notes
		from #Header A

		if(ISNULL(@ErrorLine,'') <> '')
		begin
			insert into #Comments(CommentLine)
			select ErrorLine
			from OpenJson(@ErrorLine, '$')
			With
			(
				ErrorLine	varchar(1000) '$.ErrorLine'
			)
			--select * from #Comments
		end

		if(ISNULL(@L11Line,'') <> '')
		begin
			insert into #Comments(CommentLine)
			select RefEDIID + ' : ' + Description + ' = ' + RefData
			from OpenJson(@L11Line, '$')
			With
			(
				RefEDIID	varchar(50) '$.RefEDIID',
				Description	varchar(500) '$.Description',
				RefData	varchar(50) '$.RefData'
			)
			--select * from #Comments
		end

		if(ISNULL(@Notes,'') <> '')
		begin
			insert into #Comments(CommentLine)
			select NoteLine
			from OpenJson(@Notes, '$')
			With
			(
				NoteLine	varchar(5000) '$.NoteLine'
			)
			--select * from #Comments
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
						BillToAddrKey,ETADate,BaseRateAmount)
			Select
						@OrderNo, @OrderDate, TMS_CSRKey,TMS_CustKey, 
						TMS_SourceAddrKey, TMS_DestinationAddrKey, null,
						TMS_OrderTypeKey, @OrderStausKey,@HoldReasonKey, 
						GETDATE(),TMS_BorkerKey, shipmentReferenceNumber, 
						TMS_CarrierKey, vessel, billOfLadingNumber, workOrderNumber, @Ach_Enabled,@Ach_Amount,
						@PriorityKey, GETDATE(), @CreateUserkey
						,@BillToAddrKey,ETADate,@BaseRateAmount
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
		set @ErrorLocation = 'Container'
		Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
			@grossWeight, @weightUOM, @sealNumberList

		while @@FETCH_STATUS = 0
		BEGIN
			SET @Comment= LTRIM(RTRIM(@Comment))
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			print @sealNumberList

			INSERT INTO dbo.OrderDetail(OrderKey,ContainerID,ContainerNo,ContainerSizeKey,
				Chassis,SealNo,[Weight],WeightUnit,
				[Status],StatusDate,CreateUserKey,SourceAddrKey,
				DestinationAddrKey,CreateDate, VesselETA) 
			SELECT  @Orderkey , @ContainerId,isnull(@Containerno,@OrderNo) , @TMS_ContainerSizeKey ,
				null,@sealNumberList,@grossWeight, case when @weightUOM = 'KG' then 1 else 2 end ,
				@OrderDetailStatus, GETDATE(),@CreateUserKey,@SourceAddrKey,
				@DestAddrKey,GETDATE(), @ETADate
   
			SET @NewOrderDetailKey= ( SELECT SCOPE_IDENTITY() ) 

			update OD set SourceAddrKey = OH.SourceAddrKey, DestinationAddrKey = OH.DestinationAddrKey
			from OrderDetail OD
			inner join OrderHeader OH on OD.orderkey = OH.OrderKey
			where OH.OrderKey = @OrderKey and OD.SourceAddrKey is null and OH.SourceAddrKey is not null

			update #container set TMSOrderDetailKey = @NewOrderDetailKey where ContainerKey = @RTContainerKey

			insert into TMS_Integration_Container (SiteID, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey)
			select @SiteId, @DataKey, ContainerKey, isnull(equipmentNumber,@OrderNo), @NewOrderDetailKey
			from #container

			IF ISNULL(LTRIM(RTRIM(@Comment)),'')<>''
			BEGIN
				--***********************Update Container Type items****************
					EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@Comment,@CreateUserKey=@CreateUserKey
				--*****************************************************************			
			END	
			Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
				@grossWeight, @weightUOM, @sealNumberList
		end
		close ContCursor
		Deallocate ContCursor
		set @ErrorLocation = ''
		-- END OF CONTAINER CREATE *********************************
		
		-- ROUTES CREATE ********************************************



		Declare @StopKey					int,
				@stopType				varchar(50),
				@TMS_RouteKey			int,
				@TMS_SourceAddrKey		int,
				@TMS_DestinationAddrKey	int,
				@TMS_LegKey				int,
				@OrdDetailKey			int,
				@ContainerNo1			varchar(20),
				@LegID					varchar(100)

		DECLARE RouteCursor CURSOR LOCAL
		FOR Select distinct StopKey, TMS_LegKey, TMSOrderDetailKey, S.ContainerKey, C.equipmentNumber
		from #container C
		inner join #stops S on C.ContainerKey = S.ContainerKey
		where stopType in ('Ship From')
		order by StopKey

		Open RouteCursor
		set @ErrorLocation = 'Route'
		Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @ContainerNo1

		while @@FETCH_STATUS = 0
		BEGIN
			declare @RouteKey	int = 0, @PickStopKey	int, @DelStopKey	int
			SET @Comment= LTRIM(RTRIM(@Comment))
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			declare @RTSourceAddrKey	int,
					@RTDeliveryAddrKey	int,
					@SchPickup			DateTime,
					@SchDeliv			DateTime

			select @RTSourceAddrKey = TMS_SourceAddrKey, @PickStopKey = StopKey , @SchPickup = ScheduledDate
				from #stops 
				where ContainerKey = @ContainerKey and stopType in ( 'Ship From') and StopKey = @StopKey

			select @RTDeliveryAddrKey = TMS_DestinationAddrKey, @DelStopKey = StopKey , @SchDeliv = ScheduledDate
				from #stops 
				where ContainerKey = @ContainerKey and stopType in ( 'Ship To', 'Returned To') and StopKey = @StopKey + 1

			INSERT INTO [Routes]
			(	[OrderDetailKey], [OrderKey], [LegKey],LegNo, [SourceAddrKey], 
				[DeliveryDateTo], [AppointmentNo], [ConfirmationNo], [LastFreeDay],CutOffDate, 
				[SwitchTo], 
				[PortWaitingTimeFrom], [PortWaitingTimeTo], [CustomerWaitingTimeFrom], [CustomerWaitingTimeTo], 
				[FromLocation], [ToLocation], [DestinationAddrKey], [EstimatedDistanceInMiles], [EstimatedTravelTime], 
				[Status], [DriverKey], [ActualDeparture], [ActualArrival], 
				[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey 
				--,ScheduledDeparture, ScheduledArrival, ScheduledPickupDate, PickupDateFrom, DeliveryDateFrom
			)
			select 
				 @OrdDetailKey,@OrderKey,@TMS_LegKey,1,@RTSourceAddrKey,
				 null,NULL,null,null,null,
				 null,
				 NULL,NULL,NULL,NULL,
				 NULL,NULL,@RTDeliveryAddrKey,null,null,
				 1,null, NULL,NULL,
				 NULL,NULL, @CreateUserKey,GETDATE(),NULL 
				 --,@SchPickup, @SchDeliv, @SchPickup, @SchPickup, @SchDeliv
			Set @RouteKey = SCOPE_IDENTITY()

			--select @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			--select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

			insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			select @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			
			insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

			set @comment = ''
			print @TMS_LEgKey
			print @SchPickup
			print @SchDeliv

				Select @Comment = isnull(@ContainerNo1,@OrderNo) + ' - ' + L.LegID + 
					case when @SchPickup is null then '' else   ' : Scheduled Pickup date : '  + 
					convert(varchar, @SchPickup, 101) + ' ' + left(convert(varchar, @SchPickup, 108),5) end
					+ Case when @SchDeliv is null then '' else ' Scheduled Delivery Date : ' + 
					convert(varchar, @SchDeliv, 101) + ' ' + left(convert(varchar, @SchDeliv, 108),5) end 
				from Leg L 
				where L.LegKey = @TMS_LegKey
				print '----'
				print @comment
				INSERT INTO dbo.Comment(Description,CreateDate,CreateUserKey)
				VALUES (@Comment, GETDATE(),@CreateUserkey)

				SET @NewCommentKeyOut= ( SELECT SCOPE_IDENTITY() )

				INSERT INTO dbo.OrderDetailComments(OrderDetailKey,CommentKey)
				VALUES (@OrdDetailKey, @NewCommentKeyOut);	
			Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @ContainerNo1
		end

		close RouteCursor
		Deallocate RouteCursor
		set @ErrorLocation = ''
		-- END OF ROUTES CREATE **************************************
		
		--- Start of Comment Lines insert
		declare @CurComment	varchar(5000) = '',
			    @CommentKey	int

		declare CommentCursor CURSOR LOCAL 
		for select CommentLine from #Comments
		open CommentCursor
		fetch next from CommentCursor into @CurComment
		While (@@FETCH_STATUS = 0)
		Begin
			insert into Comment (Description, CreateDate, CreateUserKey)
			select @CurComment, GETDATE(), @UserKey
			set @CommentKey = SCOPE_IDENTITY()

			insert into OrderDetailComments(OrderDetailKey, CommentKey)
			select @OrdDetailKey, @CommentKey

			fetch next from CommentCursor into @CurComment
		end
		close CommentCursor
		Deallocate CommentCursor
		--- End of Comment lines insert

		Commit Transaction

		
		set @IsSaved = 1
		set @Reason = 'Saved Successfully'
	
	End Try
	Begin Catch
		Rollback Transaction
		print error_line()
		Set @Ouput = 0
		Set @Reason = ERROR_MESSAGE()
		print @Reason
	End Catch
END
