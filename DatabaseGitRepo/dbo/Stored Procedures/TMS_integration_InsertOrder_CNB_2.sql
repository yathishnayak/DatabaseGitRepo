

/*

declare @SiteId				VARCHAR(50) = 'CNB',
		@DataKey			INT = 1,
		@Json				NVARCHAR(MAX) = '{"DataKey":1,"FileProcessKey":43429,"originatorCode":"EDRAY          ","receiverCode":"JCTD           ","workOrderNumber":"3063469-HMMU6564409-1--IMP","category":"Import","createdBy":null,"workOrderDate":"2024-05-16T16:48:00","houseAirWayBillNumber":"","shipmentReferenceNumber":"3063469-HMMU6564409","billOfLadingNumber":"HDMUSGNM33873200","vessel":"NYK RIGEL","voyage":"073W","portOfLoading":null,"portOfDischarge":null,"eta":"0001-01-01T00:00:00","shipper":"EDRAY          ","broker":null,"carrierCode":"JCTD","isAccepted":true,"RejectReasonCode":"","RejectMessage":"","IsProcessed":false,"SiteID":"CNB","ResponseType":"Reject","IsResponseSent":false,"ResponseSentDate":"0001-01-01T00:00:00","FileName":"EDRAY_204_JCTD_3063469-HMMU6564409-1--IMP_20240516_164839099.edi","TMS_OrderKey":0,"TMS_OrderNo":"Pending","TMS_OrderDate":"0001-01-01T00:00:00","ContainerList":[{"ContainerKey":1,"equipmentNumber":"HMMU6564409","equipmentTypeCode":"44G1","pieceCount":0,"grossWeight":7655.5,"weightUOM":"Kilograms","volume":0.0,"volumeUOM":null,"freightDescription":null,"isHazmat":"false","IsOverWeight":null,"IsHot":null,"sealNumberList":"230118031","StopList":[{"StopKey":1,"stopType":"Ship From","stopName":"Trapac-LAX Terminal","stopNumber":1,"facilityCode":"SF","stopReferenceNumber":1,"address1":"630 West Harry Bridges Blvd.","city":"Wilmington","state":"CA","country":"US","postalCode":"90744","ScheduledDateTime":"2024-07-10T17:18:00","IsScheduleSent":true,"ActualDateTime":"2024-07-09T06:08:28.717","IsActualSent":true,"TMS_RouteKey":442850,"TMS_SourceAddrKey":21466,"TMS_DestinationAddrKey":24388,"TMS_LegKey":2,"ScheduledDate":"0001-01-01T00:00:00"},{"StopKey":2,"stopType":"Ship To","stopName":"444 EUROMARKET DESIGNS INC.","stopNumber":2,"facilityCode":"ST","stopReferenceNumber":2,"address1":"6800 Valley View St.","city":"Buena Park","state":"CA","country":"US","postalCode":"90620","ScheduledDateTime":"2024-07-11T17:18:00","IsScheduleSent":true,"ActualDateTime":"2024-07-09T06:08:36.433","IsActualSent":true,"TMS_RouteKey":442850,"TMS_SourceAddrKey":21466,"TMS_DestinationAddrKey":24388,"TMS_LegKey":2,"ScheduledDate":"0001-01-01T00:00:00"},{"StopKey":3,"stopType":"Returned To","stopName":"Trapac-LAX Terminal","stopNumber":3,"facilityCode":"RT","stopReferenceNumber":3,"address1":"630 West Harry Bridges Blvd.","city":"Wilmington","state":"CA","country":"US","postalCode":"90744","ScheduledDateTime":"2024-07-10T17:17:00","IsScheduleSent":true,"ActualDateTime":"2024-07-10T06:08:36.433","IsActualSent":true,"TMS_RouteKey":442851,"TMS_SourceAddrKey":24388,"TMS_DestinationAddrKey":21466,"TMS_LegKey":19,"ScheduledDate":"0001-01-01T00:00:00"}],"ContainerProperties":null,"TMS_ContainerSizeKey":5,"TMSOrderDetailKey":0}],"L11Lines":[{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"HDMUSGNM33873200","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"Trapac-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"073W","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063469-HMMU6564409-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"NYK RIGEL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"Carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"MEDUF2480483","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"TTI-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"416N","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063468-TTNU5510371-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"MAERSK ALGOL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"MEDUF2480483","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"TTI-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"416N","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063468-TTNU5510371-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"MAERSK ALGOL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"MEDUF2480483","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"TTI-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"416N","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063468-TTNU5510371-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"MAERSK ALGOL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"MEDUF2480483","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"TTI-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"416N","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063468-TTNU5510371-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"MAERSK ALGOL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"HDMUSGNM33873200","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"Trapac-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"073W","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063469-HMMU6564409-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"NYK RIGEL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"Carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"HDMUSGNM33873200","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"Trapac-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"073W","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063469-HMMU6564409-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"NYK RIGEL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"Carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"HDMUSGNM33873200","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"Trapac-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"073W","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063469-HMMU6564409-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"NYK RIGEL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"Carmichael","RefEDIID":"WT"},{"Description":null,"EDIDescription":"BillofLadingNumber","RefData":"HDMUSGNM33873200","RefEDIID":"BM"},{"Description":null,"EDIDescription":"DownstreamShipperContractNumber","RefData":"Trapac-LAX Terminal","RefEDIID":"DT"},{"Description":null,"EDIDescription":"VoyageNumber","RefData":"073W","RefEDIID":"V3"},{"Description":null,"EDIDescription":"WorkOrderNumber","RefData":"3063469-HMMU6564409-1--IMP","RefEDIID":"WO"},{"Description":null,"EDIDescription":"Vessel","RefData":"NYK RIGEL","RefEDIID":"WU"},{"Description":null,"EDIDescription":"InternalCustomerNumber","RefData":"LSP","RefEDIID":"IT"},{"Description":null,"EDIDescription":"OfficeSymbol","RefData":"LAX","RefEDIID":"KU"},{"Description":null,"EDIDescription":"Broker''sReferenceNumber","RefData":"Carmichael","RefEDIID":"WT"}],"TMS_CustKey":2867,"TMS_SourceAddrKey":21466,"TMS_DestinationAddrKey":24388,"TMS_OrderTypeKey":1,"TMS_BorkerKey":6,"TMS_CarrierKey":101,"TMS_CSRKey":53,"UserKey":714,"SenderDetails":null,"TMS_MarketLocationKey":2,"Consignee":null,"OrderNo":null}',
		@UserKey			INT = 714,
		@IsSaved			BIT = 0 ,
		@Reason				VARCHAR(500)='' ,
		@OrderKey			INT =0 ,
		@OrderNo			VARCHAR(50) = '' ,
		@OrderDate			DATETIME	= '2024-01-15' 

Exec [TMS_integration_InsertOrder_CNB] @siteid, @DataKey, @Json, @UserKey, @IsSaved OUTPUT, @Reason OUTPUT, @OrderKey OUTPUT, @OrderNo Output, @OrderDate OUTPUT
Select @IsSaved, @Reason, @OrderKey,@OrderNo , @OrderDate
*/
CREATE PROCEDURE [dbo].[TMS_integration_InsertOrder_CNB]
(
	@SiteId				VARCHAR(50),
	@DataKey			INT,
	@Json				NVARCHAR(MAX),
	@UserKey			INT = 0,
	@IsSaved			BIT = 0 OUTPUT,
	@Reason				VARCHAR(500)='' OUTPUT,
	@OrderKey			INT =0 OUTPUT,
	@OrderNo			VARCHAR(50) = '' OUTPUT,
	@OrderDate			DATETIME	= '2020-01-01' OUTPUT
)
AS
BEGIN
    SET @OrderNo= REPLACE(REPLACE(@Orderno,'-',''),'.','')

	SET NOCOUNT ON
	SET FMTONLY OFF


	--INSERT INTO TESTDATA
	--SELECT @DataKey, @Json

	IF(ISNULL(@Json,'') = '')
	BEGIN
		SET @IsSaved = 0
		SET @Reason = 'Data not found'
		RETURN
	END
	IF(ISNULL(@DataKey,0) = 0 OR ISNULL(@UserKey,0) = 0)
	BEGIN
		SET @IsSaved = 0
		SET @Reason = 'No Order/user Information'
		RETURN
	END
	DECLARE @ErrorLocation	VARCHAR(50) = ''

	BEGIN Transaction
	BEGIN Try
		SEt @Json = replace(@Json, '0001-01-01T00:00:00','')
		create table #Header
		(
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
			ETADate					Datetime,
			ContainerList		NVARCHAR(MAX),
			vessel					VARCHAR(100),
			ErrorLine			NVARCHAR(MAX),
			L11Lines			NVARCHAR(MAX),
			notes				NVARCHAR(MAX), 
			Consignee			VARCHAR(100),
			TMS_MarketLocationKey	INT
		)

		insert into #Header ( DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate,
			ErrorLine,L11Lines, notes, Consignee, TMS_MarketLocationKey  )
		select DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate ,
			ErrorLine,L11Lines, notes, Consignee, TMS_MarketLocationKey 
		from OpenJson(@Json, '$')
		with (
			DataKey					INT '$.DataKey',
			FileProcessKey			INT '$.FileProcessKey',
			TMS_OrderKey			INT	'$.TMS_OrderKey',
			TMS_CustKey				INT '$.TMS_CustKey',
			TMS_SourceAddrKey		INT '$.TMS_SourceAddrKey',
			TMS_DestinationAddrKey	INT '$.TMS_DestinationAddrKey',
			TMS_OrderTypeKey		INT	'$.TMS_OrderTypeKey',
			TMS_BorkerKey			INT '$.TMS_BorkerKey',
			TMS_CarrierKey			INT '$.TMS_CarrierKey',
			TMS_CSRKey				INT '$.TMS_CSRKey',
			shipmentReferenceNumber	VARCHAR(100) '$.shipmentReferenceNumber',
			billOfLadingNumber		VARCHAR(100) '$.billOfLadingNumber',
			workOrderNumber			VARCHAR(100) '$.workOrderNumber',
			workOrderDate			DATETIME	 '$.workOrderDate',
			ETADate					Datetime	 '$.eta',
			vessel					VARCHAR(100) '$.vessel',
			ContainerList		NVARCHAR(MAX)	'$.ContainerList' as JSON,
			ErrorLine			NVARCHAR(MAX)	'$.ErrorLines' as JSON,
			L11Lines			NVARCHAR(MAX)	'$.L11Lines' as JSON,
			notes				NVARCHAR(MAX)	'$.notes' as JSON,
			Consignee			VARCHAR(100)	'$.Consignee',
			TMS_MarketLocationKey	INT				'$.TMS_MarketLocationKey'
		)
	
		declare @ContJson NVARCHAR(MAX) = '';
		select @ContJson = ContainerList from #Header

		IF(isnull(@ContJson,'') <>'')
		BEGIN
			create table #container
			(
				ContainerKey			INT,
				equipmentNumber			VARCHAR(50),
				TMS_ContainerSizeKey	INT,
				TMSOrderDetailKey		INT,
				StopList				NVARCHAR(MAX) ,
				ContainerProperties		NVARCHAR(MAX) ,
				grossWeight				decimal(18,5),
				weightUOM				VARCHAR(10),
				sealNumberList			VARCHAR(100),
				HazMatInfo				VARCHAR(100)
			)

			insert into #container (ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList, ContainerProperties, grossWeight,weightUOM, sealNumberList, HazMatInfo )
			select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList , ContainerProperties, grossWeight,weightUOM, sealNumberList, HazMatInfo
			from OpenJson(@ContJson,'$')
			With
			(
				ContainerKey			INT				'$.ContainerKey',
				equipmentNumber			VARCHAR(50)		'$.equipmentNumber',
				TMS_ContainerSizeKey	INT				'$.TMS_ContainerSizeKey',
				TMSOrderDetailKey		INT				'$.TMSOrderDetailKey',
				StopList				NVARCHAR(MAX)	'$.StopList' as JSON,
				ContainerProperties		NVARCHAR(MAX)	'$.ContainerProperties' as JSON,
				grossWeight				decimal(18,5)	'$.grossWeight',
				weightUOM				VARCHAR(10)		'$.weightUOM',
				sealNumberList			VARCHAR(100)	'$.sealNumberList',
				HazMatInfo				VARCHAR(100)	'$.isHazmat'
			)
			--select * from #container

			create table #stops
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

			Create Table #Comments
			(
				CommentLine				VARCHAR(5000)
			)

			declare @ContCnt	INT = 0
			select @ContCnt = COUNT(1) from #container
			IF(@ContCnt > 0)
			begin
				declare @StopList	NVARCHAR(MAX), 
					@ContainerKey	INT
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
						StopKey					INT			'$.StopKey',
						stopType				VARCHAR(50) '$.stopType',
						TMS_RouteKey			INT			'$.TMS_RouteKey',
						TMS_SourceAddrKey		INT			'$.TMS_SourceAddrKey',
						TMS_DestinationAddrKey	INT			'$.TMS_DestinationAddrKey',
						TMS_LegKey				INT			'$.TMS_LegKey',
						ScheduledDate			DATETIME	'$.ScheduledDate'
					)
					Fetch next from MyCursor INTO @StopList, @ContainerKey
				END
				CLOSE myCursor
				deallocate myCursor

				declare @ContainerProperties	NVARCHAR(MAX) 

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
		END
		select * from #stops

		declare @retToCnt INT = 0
		select @retToCnt = COUNT(1) from #stops where stopType = 'Returned to'
		IF(@retToCnt > 0)
		BEGIN
			
			update #stops SET StopKey = StopKey + 1 where stopType = 'Returned to'

			insert into #stops (ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey, ScheduledDate)
			select ContainerKey,  StopKey + 1, 'Ship From', TMS_RouteKey, TMS_DestinationAddrKey, 0, 
					(Select TMS_LegKey from #stops where stopType = 'Returned to') as TMS_LegKey, ScheduledDate
			from #stops 
			where StopKey = 2
			--select * from #stops order by StopKey
		END
		
		DECLARE @ErrorLine NVARCHAR(MAX) = '',
				@L11Line	NVARCHAR(MAX) = '',
				@Notes		NVARCHAR(MAX) = ''

		select @ErrorLine = A.ErrorLine,
				@L11Line = A.L11Lines,
				@Notes = A.notes
		from #Header A

		IF(ISNULL(@ErrorLine,'') <> '')
		begin
			insert into #Comments(CommentLine)
			select ErrorLine
			from OpenJson(@ErrorLine, '$')
			With
			(
				ErrorLine	VARCHAR(1000) '$.ErrorLine'
			)
			--select * from #Comments
		END

		IF(ISNULL(@L11Line,'') <> '')
		begin
			insert into #Comments(CommentLine)
			select RefEDIID + ' : ' + Description + ' = ' + RefData
			from OpenJson(@L11Line, '$')
			With
			(
				RefEDIID	VARCHAR(50) '$.RefEDIID',
				Description	VARCHAR(500) '$.Description',
				RefData	VARCHAR(50) '$.RefData'
			)
			--select * from #Comments
		END

		create table #L11Lines
		(
			RefData			VARCHAR(50),
			RefEDIID		VARCHAR(50),
			Description		VARCHAR(100),
			EDIDescription	VARCHAR(500)
		)

		IF(ISNULL(@L11Line,'') <> '')
		begin
			insert into #L11Lines (RefData, RefEDIID, Description)
			select RefData, RefEDIID , Description
			from OpenJson(@L11Line, '$')
			With
			(
				RefEDIID	VARCHAR(50) '$.RefEDIID',
				Description	VARCHAR(500) '$.Description',
				RefData	VARCHAR(50) '$.RefData'
			)
			--select * from #Comments
		END
		

		IF(ISNULL(@Notes,'') <> '')
		begin
			insert into #Comments(CommentLine)
			select NoteLine
			from OpenJson(@Notes, '$')
			With
			(
				NoteLine	VARCHAR(5000) '$.NoteLine'
			)
			--select * from #Comments
		END

		declare @HeadCnt	INT = 0,
				@ContainerCnt	INT = 0,
				@StopCnt	INT = 0

		select @HeadCnt = COUNT(1) from #Header
		select @ContainerCnt = COUNT(1) from #container
		Select @StopCnt = COUNT(1) from #stops



		IF(@HeadCnt > 0 and @ContainerCnt > 0 and @StopCnt > 0)
		BEGIN

			-- ORDER HEADER INSERT ********************************************
			DECLARE 
				@CustKey		 INT,
				@custID			 VARCHAR(50),
				@BillToAddrKey   INT,
				@Csrkey			 INT=NULL,
				@SourceAddrkey	 INT,
				@DestAddrkey	 INT,
				@ReturnAddrkey	 INT= NULL,
				@OrderTypeKey	 SMALLINT,
				@Status			 SMALLINT=12,
				@BrokerKey		 INT,
				@BrokerrefNo	 VARCHAR(100)=NULL,
				@CarrierKey		 INT=NULL,
				@VesselName		 VARCHAR(100)=NULL,
				@BillOfLading	 VARCHAR(100)=NULL,
				@BookingNo		 VARCHAR(100)=NULL,
				@Ach_Enabled	 SMALLINT=NULL,
				@Ach_Amount		 DECIMAL(18,2)=null,
				@PriorityKey	 SMALLINT=Null,
				@Comment		 VARCHAR(MAX)=NULL,
				@CreateUserkey	 INT,
				@ETADate		 DATETIME=NULL,
				@BaseRateAmount	 DECIMAL(18,2),
				@HazComment		 VARCHAR(100) = null
				


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

			DECLARE @OrderType VARCHAR(20)

			SET @OrderType = (SELECT OrderType FROM Integration_JCB.dbo.CNB_Header A
							INNER JOIN OrderHeader OH ON A.TMS_OrderKey = OH.OrderKey
							INNER JOIN OrderType OT ON OH.OrderTypeKey = OT.OrderTypeKey
							WHERE A.DataKey = @Datakey)

			IF(@OrderType = 'Export')
				BEGIN
					Select @BookingNo = RefData from #L11Lines where RefEDIID = 'BN'
				END
			ELSE
				BEGIN
					SET @BookingNo = NULL
				END

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
			
			SET @OrderNo = ltrim(rtrim(Left(@custID,5))) +  CONVERT(VARCHAR, YEAR(@OrderDate)) +  
				convert(VARCHAR, case when @cnt < 100 then 
					substring( CONVERT(VARCHAR,100 + @CNT),2,2)
					else CONVERT(VARCHAR,100 + @CNT) END)


			INSERT INTO dbo.OrderHeader(OrderNo, OrderDate,Csrkey, CustKey,   
						SourceAddrKey,  DestinationAddrKey,  ReturnAddrKey,
						OrderTypeKey, [Status], HoldReasonKey, Consignee,
						StatusDate, BrokerKey, BrokerRefNo, 
						CarrierKey, VesselName, BillOfLading, BookingNo, Ach_Enabled,Ach_Amount,
						[PriorityKey], CreateDate, CreateUserKey,
						BillToAddrKey,ETADate,BaseRateAmount, MarketLocationKey, OrderSource )
			Select
						@OrderNo, @OrderDate, TMS_CSRKey,TMS_CustKey, 
						TMS_SourceAddrKey, TMS_DestinationAddrKey, null,
						TMS_OrderTypeKey, @OrderStausKey,@HoldReasonKey, Consignee,
						GETDATE(),TMS_BorkerKey, shipmentReferenceNumber, 
						TMS_CarrierKey, vessel, billOfLadingNumber
						, CASE WHEN  @OrderType = 'Export' THEN  isnull(@BookingNo,workOrderNumber) ELSE '' END
						, @Ach_Enabled,@Ach_Amount,
						@PriorityKey, GETDATE(), @UserKey
						,@BillToAddrKey,ETADate,@BaseRateAmount , TMS_MarketLocationKey,'CNB'
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
		END
	
		-- ORDER DETAIL CREATE **************************************************
		DECLARE 
			@NewOrderDetailKey	INT,
			@New_CommentKey		INT,
			@OrderDetailStatus  SMALLINT,
			@ContCount			INT,
			@RTContainerKey		INT, 
			@TMS_ContainerSizeKey	smallint, 
			@TMSOrderDetailKey	INT,
			@ContainerNo		VARCHAR(50),
			@ContainerId		VARCHAR(100),
			@grossWeight		INT,			
			@weightUOM			VARCHAR(10),
			@sealNumberList		VARCHAR(100),
			@HazMatInfo			VARCHAR(100)

		DECLARE ContCursor CURSOR LOCAL
		FOR Select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, grossWeight, weightUOM, sealNumberList, HazMatInfo 
		from #container

		Open ContCursor
		SET @ErrorLocation = 'Container'
		Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
			@grossWeight, @weightUOM, @sealNumberList, @HazMatInfo

		while @@FETCH_STATUS = 0
		BEGIN
			SET @Comment= LTRIM(RTRIM(@Comment))

			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			print @sealNumberList

			If(Isnull(@ContainerNo,'') = '')
			BEGIN
				declare @NoContCount INT = 0
				select @NoContCount = count(1) from orderdetail where Containerno like 'JCTD%'
				SEt @ContainerNo = 'JCTD' + Right(convert(VARCHAR(5), year(getdate())),2) + right(convert(VARCHAR(5),100 + MONTH(Getdate())),2) + 
					right(convert(VARCHAR(5),1000 + @NoContCount),3)
				update #container SET equipmentNumber = @ContainerNo where ContainerKey = @ContainerKey
			END

			INSERT INTO dbo.OrderDetail(OrderKey,ContainerID,ContainerNo,ContainerSizeKey,
				Chassis,SealNo,[Weight],WeightUnit,
				[Status],StatusDate,CreateUserKey,SourceAddrKey,
				DestinationAddrKey,CreateDate, VesselETA) 
			SELECT  @Orderkey , @ContainerId,isnull(@Containerno,@OrderNo) , @TMS_ContainerSizeKey ,
				null,@sealNumberList,@grossWeight, case when LTRIM(RTRIM(@weightUOM)) IN ('KG','Kilograms','Kilogram') then 2 else 1 END ,
				@OrderDetailStatus, GETDATE(),@UserKey,@SourceAddrKey,
				@DestAddrKey,GETDATE(), @ETADate
   
			SET @NewOrderDetailKey= ( SELECT SCOPE_IDENTITY() ) 

			update OD SET SourceAddrKey = OH.SourceAddrKey, DestinationAddrKey = OH.DestinationAddrKey
			from OrderDetail OD
			inner join OrderHeader OH on OD.orderkey = OH.OrderKey
			where OH.OrderKey = @OrderKey and OD.SourceAddrKey is null and OH.SourceAddrKey is not null

			update #container SET TMSOrderDetailKey = @NewOrderDetailKey where ContainerKey = @RTContainerKey

			insert into TMS_Integration_Container (SiteID, DataKey, ContainerKey, ContainerNo, TMS_OrderDetailKey)
			select @SiteId, @DataKey, ContainerKey, @ContainerNo, @NewOrderDetailKey
			from #container

			--IF(isnull(@HazMatInfo ,'') = 'true' )
			--BEGIN
			--	Set @HazComment = 'Hazard'
			--END


			SELECT * FROM #containerproperties
			DECLARE @TypeDesc VARCHAR(MAX) = '';
			SET @TypeDesc = (			SELECT DISTINCT 
					SUBSTRING(
						(
							SELECT ','+ST1.TypeDescription  AS [text()]
							FROM #containerproperties ST1
							WHERE ST1.ContainerKey = ST2.ContainerKey AND IsSelected = 1 AND ContainerKey = @RTContainerKey
							FOR XML PATH (''), TYPE
						).value('text()[1]','NVARCHAR(MAX)'), 2, 1000) TypeDescription
				FROM #containerproperties ST2 WHERE ContainerKey = @RTContainerKey) 

			--IF ISNULL(LTRIM(RTRIM(@HazComment)),'')<>''
			--BEGIN
			--	--***********************Update Container Type items****************
			--		EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@HazComment,@CreateUserKey=@CreateUserKey
			--	--*****************************************************************			
			--END	


			SELECT @NewOrderDetailKey AS OrderDetailKey,@TypeDesc AS TypeDesc,@CreateUserKey AS UserKey 
			-- SELECT * INTO TESTCONTDATA FROM (SELECT @NewOrderDetailKey AS OrderDetailKey,@TypeDesc AS TypeDesc,@CreateUserKey AS UserKey) A
			IF ISNULL(LTRIM(RTRIM(@TypeDesc)),'')<>''
			BEGIN
				
				--***********************Update Container Type items****************
					EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@TypeDesc,@CreateUserKey=@CreateUserKey
				--*****************************************************************			
			END



			Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
				@grossWeight, @weightUOM, @sealNumberList,  @HazMatInfo
		END
		close ContCursor
		Deallocate ContCursor
		SET @ErrorLocation = ''
		-- END OF CONTAINER CREATE *********************************
		
		-- ROUTES CREATE ********************************************



		DECLARE @StopKey					INT,
				@stopType				VARCHAR(50),
				@TMS_RouteKey			INT,
				@TMS_SourceAddrKey		INT,
				@TMS_DestinationAddrKey	INT,
				@TMS_LegKey				INT,
				@OrdDetailKey			INT,
				@ContainerNo1			VARCHAR(20),
				@LegID					VARCHAR(100)

		DECLARE RouteCursor CURSOR LOCAL
		FOR Select distinct StopKey, TMS_LegKey, TMSOrderDetailKey, S.ContainerKey, C.equipmentNumber
		from #container C
		inner join #stops S on C.ContainerKey = S.ContainerKey
		where stopType in ('Ship From')
		order by StopKey

		Open RouteCursor
		SET @ErrorLocation = 'Route'
		Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @ContainerNo1

		while @@FETCH_STATUS = 0
		BEGIN
			declare @RouteKey	INT = 0, @PickStopKey	INT, @DelStopKey	INT
			SET @Comment= LTRIM(RTRIM(@Comment))
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			declare @RTSourceAddrKey	INT,
					@RTDeliveryAddrKey	INT,
					@SchPickup			DATETIME,
					@SchDeliv			DATETIME
			
			SELECT 'stopkey....', @StopKey
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
				[OdometerAtSource], [OdometerAtDestination], CreateUserKey,CreateDate,ChassisKey , LastUpdateDate
				--,ScheduledDeparture, ScheduledArrival, ScheduledPickupDate, PickupDateFrom, DeliveryDateFrom
			)
			select 
				 @OrdDetailKey,@OrderKey,@TMS_LegKey,1,@RTSourceAddrKey,
				 null,NULL,null,null,null,
				 null,
				 NULL,NULL,NULL,NULL,
				 NULL,NULL,@RTDeliveryAddrKey,null,null,
				 1,null, NULL,NULL,
				 NULL,NULL, @UserKey,GETDATE(),NULL , Getdate()
				 --,@SchPickup, @SchDeliv, @SchPickup, @SchPickup, @SchDeliv
			Set @RouteKey = SCOPE_IDENTITY()

			SELECT * FROM Routes WHERE Orderkey = @OrderKey

			select @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

			insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			select @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			
			insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

			SET @comment = ''
			print @TMS_LEgKey
			print @SchPickup
			print @SchDeliv

				Select @Comment = isnull(@ContainerNo1,@OrderNo) + ' - ' + L.LegID + 
					case when @SchPickup is null then '' else   ' : Scheduled Pickup date : '  + 
					convert(VARCHAR, @SchPickup, 101) + ' ' + left(convert(VARCHAR, @SchPickup, 108),5) END
					+ Case when @SchDeliv is null then '' else ' Scheduled Delivery Date : ' + 
					convert(VARCHAR, @SchDeliv, 101) + ' ' + left(convert(VARCHAR, @SchDeliv, 108),5) END 
				from Leg L 
				where L.LegKey = @TMS_LegKey
				print '----'
				print @comment
				INSERT INTO dbo.Comment(Description,CreateDate,CreateUserKey)
				VALUES (@Comment, GETDATE(),@UserKey)

				SET @NewCommentKeyOut= ( SELECT SCOPE_IDENTITY() )

				INSERT INTO dbo.OrderDetailComments(OrderDetailKey,CommentKey)
				VALUES (@OrdDetailKey, @NewCommentKeyOut);	
			Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @ContainerNo1
		END

		close RouteCursor
		Deallocate RouteCursor
		SET @ErrorLocation = ''
		-- END OF ROUTES CREATE **************************************
		
		--- Start of Comment Lines insert
		declare @CurComment	VARCHAR(5000) = '',
			    @CommentKey	INT

		declare CommentCursor CURSOR LOCAL 
		for select CommentLine from #Comments
		open CommentCursor
		fetch next from CommentCursor into @CurComment
		While (@@FETCH_STATUS = 0)
		BEGIN
			insert into Comment (Description, CreateDate, CreateUserKey)
			select @CurComment, GETDATE(), @UserKey
			SET @CommentKey = SCOPE_IDENTITY()

			insert into OrderDetailComments(OrderDetailKey, CommentKey)
			select @OrdDetailKey, @CommentKey

			fetch next from CommentCursor into @CurComment
		END
		close CommentCursor
		Deallocate CommentCursor
		--- END of Comment lines insert

		Commit Transaction

		
		SET @IsSaved = 1
		SET @Reason = 'Saved Successfully'
	
	END Try
	BEGIN Catch
		Rollback Transaction
		print error_line()
		Set @Ouput = 0
		Set @Reason = ERROR_MESSAGE()
		print @Reason
	END Catch
END
