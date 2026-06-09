


/*
declare @SiteId				varchar(50) = 'DHL',
		@DataKey			int = 3939,
		@Json				nvarchar(max) = '{"DataKey":3939,"FileProcessKey":30120,"originatorCode":"DMAL","receiverCode":"JCTD","workOrderNumber":"000015520","category":"","createdBy":null,"workOrderDate":"2024-03-11T11:16:00","houseAirWayBillNumber":"","shipmentReferenceNumber":"DH-279762-1","billOfLadingNumber":null,"vessel":"OOCL MALAYSIA","voyage":"054W","portOfLoading":null,"portOfDischarge":null,"eta":"0001-01-01T00:00:00","shipper":"DMAL","broker":null,"carrierCode":"MSCU Statistics Canada Canadian College Student Information System Course Codes","isAccepted":true,"RejectReasonCode":"","RejectMessage":"","IsProcessed":false,"SiteID":"DHL","ResponseType":"Reject","IsResponseSent":false,"ResponseSentDate":"0001-01-01T00:00:00","FileName":"DMAL-DMAL-JCTD-204-000015520-2024-03-11-11-17-46-796-927373509.EDI","TMS_OrderKey":0,"TMS_OrderNo":"Pending","TMS_OrderDate":"0001-01-01T00:00:00","ContainerList":[{"ContainerKey":3919,"equipmentNumber":null,"equipmentTypeCode":"40HC","pieceCount":0,"grossWeight":5000,"weightUOM":"Gross Weight","volume":0,"volumeUOM":null,"freightDescription":null,"isHazmat":"No","sealNumberList":"","StopList":[{"StopKey":11757,"stopType":"Ship From","stopName":"PACIFIC CONTAINER TERMINAL","stopNumber":1,"facilityCode":"SF","stopReferenceNumber":1,"address1":"1521 PIER J AVENUE","city":"LONG BEACH","state":"CA","country":null,"postalCode":"90802","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":20304,"TMS_DestinationAddrKey":0,"TMS_LegKey":46,"ScheduledDate":"0001-01-01T00:00:00","_selectedLeg":{"LegKey":46,"LegID":"Port To Consignee","FromLocation":"Port","ToLocation":"Customer","PickUpType":"Port"},"LegSelectedItems":[{"LegKey":46,"LegID":"Port To Consignee","FromLocation":"Port","ToLocation":"Customer","PickUpType":"Port"}],"_LocationList":[],"SourSelectedItems":[{"Name":"UNSPECIFIED","AddrKey":20304,"AddrName":"UNSPECIFIED","Address1":" .","Address2":"","City":"Long Beach","State":"CA","ZipCode":"90810","Country":"USA","Type":"PORT","NameFull":"UNSPECIFIED,  ., Long Beach, 90810"}]},{"StopKey":11758,"stopType":"Ship To","stopName":"CALMOSEPTINE INC","stopNumber":2,"facilityCode":"ST","stopReferenceNumber":2,"address1":"16602 BURKE LANE","city":"HUNTINGTON BEACH","state":"CA","country":null,"postalCode":"92647","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":0,"TMS_DestinationAddrKey":33181,"TMS_LegKey":46,"ScheduledDate":"0001-01-01T00:00:00","_selectedLeg":{"LegKey":46,"LegID":"Port To Consignee","FromLocation":"Port","ToLocation":"Customer","PickUpType":"Port"},"LegSelectedItems":[{"LegKey":46,"LegID":"Port To Consignee","FromLocation":"Port","ToLocation":"Customer","PickUpType":"Port"}],"_LocationList":[],"DestSelectedItems":[{"Name":"CALMOSEPTINE INC","AddrKey":33181,"AddrName":"CALMOSEPTINE INC","Address1":"16602 BURKE LANE","Address2":"-","City":"Huntington Beach","State":"CA","ZipCode":"92647","Country":"USA","Type":"Customer","NameFull":"CALMOSEPTINE INC, 16602 BURKE LANE, Huntington Beach, 92647"}]},{"StopKey":11759,"stopType":"Returned to","stopName":"LONG BEACH CONTAINER TERMINAL (LBCT) - PIER E FIRM","stopNumber":3,"facilityCode":"RT","stopReferenceNumber":3,"address1":"201 S. PICO AVE PIER E","city":"LONG BEACH","state":"CA","country":null,"postalCode":"90802","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":0,"TMS_DestinationAddrKey":20304,"TMS_LegKey":48,"ScheduledDate":"0001-01-01T00:00:00","_selectedLeg":{"LegKey":48,"LegID":"Consignee To Port","FromLocation":"Consignee","ToLocation":"Port","PickUpType":"Consignee"},"LegSelectedItems":[{"LegKey":48,"LegID":"Consignee To Port","FromLocation":"Consignee","ToLocation":"Port","PickUpType":"Consignee"}],"_LocationList":[],"DestSelectedItems":[{"Name":"UNSPECIFIED","AddrKey":20304,"AddrName":"UNSPECIFIED","Address1":" .","Address2":"","City":"Long Beach","State":"CA","ZipCode":"90810","Country":"USA","Type":"PORT","NameFull":"UNSPECIFIED,  ., Long Beach, 90810"}]}],"TMS_ContainerSizeKey":12,"TMSOrderDetailKey":0,"ContSelectedItems":[{"ContainerSizeKey":12,"Description":"40 HC"}]}],"TMS_CustKey":3170,"TMS_SourceAddrKey":29176,"TMS_DestinationAddrKey":31641,"TMS_OrderTypeKey":2,"TMS_BorkerKey":5,"TMS_CarrierKey":109,"TMS_CSRKey":41,"UserKey":"29","IsConfirmed":true,"ConfirmDate":"2024-03-11T10:32:30.493","ErrorLines":null,"L11Lines":[{"Description":null,"EDIDescription":"BookingNumber","RefData":"6379197980","RefEDIID":"BN"},{"Description":"DRAYAGE","EDIDescription":null,"RefData":"406.25","RefEDIID":"DRA"},{"Description":"FUEL SURCHARGE","EDIDescription":null,"RefData":"142.19","RefEDIID":"FUE"},{"Description":"CHASSIS RENTAL","EDIDescription":"ChromatographIdentifier","RefData":"15.00","RefEDIID":"CHR"},{"Description":null,"EDIDescription":"Bill&HoldInvoiceNumber","RefData":"LAXA08220","RefEDIID":"HB"}],"notes":null,"ScheduleFiles":null,"ActualFiles":null,"InvoiceFiles":null,"ProcessStatus":null,"ProcStatusDate":"0001-01-01T00:00:00","ProcStatusDataKey":0,"ProcworkOrderNumber":null,"ProcFileProcessKey":0,"IsArchived":false,"ArchiveDate":"0001-01-01T00:00:00","IsDuplicate":false,"IsUpdate":false,"IsCancel":false,"Consignee":null}',
		@UserKey			int = 29,
		@IsSaved			bit = 0 ,
		@Reason				varchar(500)='' ,
		@OrderKey			INT =0 ,
		@OrderNo			varchar(50) = '' ,
		@OrderDate			DateTime	= getdate()

Exec TMS_integration_InsertOrder_DHL @siteid, @DataKey, @Json, @UserKey, @IsSaved output, @Reason output, @OrderKey output, @OrderNo Output, @OrderDate output
Select @IsSaved, @Reason, @OrderKey,@OrderNo , @OrderDate
*/

CREATE PROCEDURE [dbo].[TMS_integration_InsertOrder_DHL]
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
			notes				nvarchar(max),
			Consignee			varchar(100),
			TMS_MarketLocationKey	INT
		)

		insert into #Header ( DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate,
			ErrorLine,L11Lines, notes, Consignee, TMS_MarketLocationKey )
		select DataKey, FileProcessKey, TMS_OrderKey, TMS_CustKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, 
			TMS_OrderTypeKey, TMS_BorkerKey, TMS_CarrierKey, ContainerList, TMS_CSRKey,vessel,
			shipmentReferenceNumber, billOfLadingNumber, workOrderNumber, workOrderDate, ETADate ,
			ErrorLine,L11Lines, notes, Consignee, TMS_MarketLocationKey
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
			notes				nvarchar(max)	'$.notes' as JSON,
			Consignee				varchar(100)	'$.Consignee',
			TMS_MarketLocationKey	INT				'$.TMS_MarketLocationKey'
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
				StopList,ContainerProperties, grossWeight,weightUOM, sealNumberList )
			select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList , ContainerProperties, grossWeight,weightUOM, sealNumberList
			from OpenJson(@ContJson,'$')
			With
			(
				ContainerKey			int			'$.ContainerKey',
				equipmentNumber			varchar(50)	'$.equipmentNumber',
				TMS_ContainerSizeKey	int			'$.TMS_ContainerSizeKey',
				TMSOrderDetailKey		int			'$.TMSOrderDetailKey',
				StopList				nvarchar(max) '$.StopList' as JSON,
				ContainerProperties		nvarchar(max)	'$.ContainerProperties' as JSON,
				grossWeight				decimal(18,5)			'$.grossWeight',
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
				stopNumber				int
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
					insert into #stops (ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey,stopNumber)
					select @ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey,stopNumber
					from OpenJson(@StopList, '$')
					with (
						StopKey					int			'$.StopKey',
						stopType				varchar(50) '$.stopType',
						TMS_RouteKey			int			'$.TMS_RouteKey',
						TMS_SourceAddrKey		int			'$.TMS_SourceAddrKey',
						TMS_DestinationAddrKey	int			'$.TMS_DestinationAddrKey',
						TMS_LegKey				int			'$.TMS_LegKey',
						stopNumber				int			'$.stopNumber'
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
		--select * from #stops

		--declare @retToCnt int = 0
		--select @retToCnt = COUNT(1) from #stops where stopType = 'Returned to'
		--if(@retToCnt > 0)
		--Begin
			
		--	update #stops set StopKey = StopKey + 1 where stopType = 'Returned to'

		--	insert into #stops (ContainerKey, StopKey, stopType, TMS_RouteKey, TMS_SourceAddrKey, TMS_DestinationAddrKey, TMS_LegKey)
		--	select ContainerKey,  StopKey + 1, 'Ship From', TMS_RouteKey, TMS_DestinationAddrKey, 0, 
		--			(Select TMS_LegKey from #stops where stopType = 'Returned to') as TMS_LegKey
		--	from #stops 
		--	where StopKey = 2
		--	--select * from #stops order by StopKey
		--end
		
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

		create table #L11Lines
		(
			RefData			varchar(50),
			RefEDIID		varchar(50),
			Description		varchar(100),
			EDIDescription	varchar(500)
		)

		if(ISNULL(@L11Line,'') <> '')
		begin
			insert into #L11Lines (RefData, RefEDIID, Description)
			select RefData, RefEDIID , Description
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

			Select @BookingNo = RefData from #L11Lines where RefEDIID = 'BN'

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

			SEt @CreateUserkey = @UserKey

			INSERT INTO dbo.OrderHeader(OrderNo, OrderDate,Csrkey, CustKey,   
						SourceAddrKey,  DestinationAddrKey,  ReturnAddrKey,
						OrderTypeKey, [Status], HoldReasonKey, Consignee,
						StatusDate, BrokerKey, BrokerRefNo, 
						CarrierKey, VesselName, BillOfLading, BookingNo, Ach_Enabled,Ach_Amount,
						[PriorityKey], CreateDate, CreateUserKey,
						BillToAddrKey,ETADate,BaseRateAmount, MarketLocationKey, OrderSource)
			Select
						@OrderNo, @OrderDate, TMS_CSRKey,TMS_CustKey, 
						TMS_SourceAddrKey, TMS_DestinationAddrKey, null,
						TMS_OrderTypeKey, @OrderStausKey,@HoldReasonKey, Consignee,
						GETDATE(),TMS_BorkerKey, shipmentReferenceNumber, 
						TMS_CarrierKey, vessel, billOfLadingNumber, isnull(@BookingNo,workOrderNumber), @Ach_Enabled,@Ach_Amount,
						@PriorityKey, GETDATE(), @CreateUserkey
						,@BillToAddrKey,ETADate,@BaseRateAmount, TMS_MarketLocationKey, 'EDI-DHL'
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
				null,@sealNumberList,@grossWeight, case when LTRIM(RTRIM(@weightUOM)) IN ('KG','Kilograms','Kilogram') then 2 else 1 end ,
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
				@stopNumber				INT

		DECLARE RouteCursor CURSOR LOCAL
		FOR Select distinct StopKey, TMS_LegKey, TMSOrderDetailKey, S.ContainerKey, stopNumber, stopType
		from #container C
		inner join #stops S on C.ContainerKey = S.ContainerKey
		where stopType in ('Ship From', 'Returned Pickup')
		order by StopKey

		Open RouteCursor
		set @ErrorLocation = 'Route'
		Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @stopNumber, @stopType

		while @@FETCH_STATUS = 0
		BEGIN
			declare @RouteKey	int = 0, @PickStopKey	int, @DelStopKey	int
			SET @Comment= LTRIM(RTRIM(@Comment))
			SET @OrderDetailStatus= (  SELECT CASE WHEN [Status]=8 THEN 11 ELSE 1 END  FROM dbo.OrderHeader WHERE OrderKey= @Orderkey )
			declare @RTSourceAddrKey	int,
					@RTDeliveryAddrKey	int
			select @RTSourceAddrKey = TMS_SourceAddrKey, @PickStopKey = StopKey 
				from #stops 
				where ContainerKey = @ContainerKey and stopType in ( 'Ship From', 'Returned Pickup') and stopNumber = @stopNumber

			select @RTDeliveryAddrKey = TMS_DestinationAddrKey, @DelStopKey = StopKey 
				from #stops 
				where ContainerKey = @ContainerKey and stopType in ( 'Ship To', 'Returned To') and stopNumber = @stopNumber + 1

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
				 @OrdDetailKey,@OrderKey,@TMS_LegKey,CASE WHEN @stopType = 'Ship From' THEN 1 ELSE 2 END,@RTSourceAddrKey,null,null,
				 null,null,NULL,null,null,null,
				 null,
				 NULL,NULL,NULL,NULL,
				 NULL,NULL,@RTDeliveryAddrKey,null,null,1,null,null,null,NULL,NULL,NULL,NULL,
				 @CreateUserKey,GETDATE(),NULL
			Set @RouteKey = SCOPE_IDENTITY()

			--select @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			--select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

			insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			select @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			
			insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey )
			select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

			Fetch Next from RouteCursor into @StopKey, @TMS_LegKey, @OrdDetailKey, @ContainerKey, @stopNumber, @stopType
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
		
		Set @Ouput = 0
		Set @Reason = ERROR_MESSAGE()
		print @Reason
	End Catch
END

