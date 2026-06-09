

/*
DECLARE @SiteId				VARCHAR(50) = 'Melrose',
		@DataKey			int = 353,
		@Json				nVARCHAR(max) =  '{"DataKey":353,"FileProcessKey":49654,"originatorCode":"Melrose","receiverCode":null,"workOrderNumber":"BORD00222560","category":"import","createdBy":null,"workOrderDate":"2024-06-26T07:00:00Z","houseAirWayBillNumber":null,"shipmentReferenceNumber":"BORD00222560","billOfLadingNumber":"MEDUWC339373","vessel":null,"voyage":null,"portOfLoading":null,"portOfDischarge":"long beach","eta":"0001-01-01T00:00:00","shipper":"Westset Logistics (JCT)","broker":null,"carrierCode":null,"isAccepted":true,"RejectReasonCode":null,"RejectMessage":null,"IsProcessed":false,"SiteID":"melrose","ResponseType":null,"IsResponseSent":false,"ResponseSentDate":"0001-01-01T00:00:00","FileName":null,"TMS_OrderKey":0,"TMS_OrderNo":null,"TMS_OrderDate":"2024-06-26T16:28:40.723Z","ContainerList":[{"ContainerKey":425,"equipmentNumber":"MSMU2586089","equipmentTypeCode":"22GP","pieceCount":0,"grossWeight":19152.0,"weightUOM":"kg","volume":0.0,"volumeUOM":null,"freightDescription":null,"isHazmat":"false","IsOverWeight":null,"IsHot":null,"sealNumberList":null,"StopList":[{"StopKey":849,"stopType":"Ship From","stopName":"Total Terminals International - TTI (Z952)","stopNumber":1,"facilityCode":"SF","stopReferenceNumber":1,"address1":"301 Mediterranean Way","city":"Long Beach","state":"CA","country":"US","postalCode":"90802","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":37245,"TMS_DestinationAddrKey":0,"TMS_LegKey":2,"ScheduledDate":"0001-01-01T00:00:00"},{"StopKey":850,"stopType":"Ship To","stopName":null,"stopNumber":2,"facilityCode":"ST","stopReferenceNumber":2,"address1":"210 E Lambert Rd","city":"Fullerton","state":"CA","country":"US","postalCode":"92835","ScheduledDateTime":"0001-01-01T00:00:00","IsScheduleSent":false,"ActualDateTime":"0001-01-01T00:00:00","IsActualSent":false,"TMS_RouteKey":0,"TMS_SourceAddrKey":37245,"TMS_DestinationAddrKey":30985,"TMS_LegKey":2,"ScheduledDate":"0001-01-01T00:00:00"}],"ContainerProperties":[{"ContainerPropKey":3801,"ContainerKey":425,"ContainerTypeKey":1,"TypeDescription":"Hazard","IsSelected":false},{"ContainerPropKey":3805,"ContainerKey":425,"ContainerTypeKey":2,"TypeDescription":"Over weight","IsSelected":false},{"ContainerPropKey":3809,"ContainerKey":425,"ContainerTypeKey":3,"TypeDescription":"Triaxle","IsSelected":true},{"ContainerPropKey":3813,"ContainerKey":425,"ContainerTypeKey":4,"TypeDescription":"Needs to be scaled","IsSelected":false},{"ContainerPropKey":3817,"ContainerKey":425,"ContainerTypeKey":5,"TypeDescription":"Weekend delivery","IsSelected":false},{"ContainerPropKey":3821,"ContainerKey":425,"ContainerTypeKey":6,"TypeDescription":"Transload","IsSelected":false},{"ContainerPropKey":3825,"ContainerKey":425,"ContainerTypeKey":7,"TypeDescription":"Genset","IsSelected":false},{"ContainerPropKey":3829,"ContainerKey":425,"ContainerTypeKey":8,"TypeDescription":"Permit","IsSelected":false},{"ContainerPropKey":3833,"ContainerKey":425,"ContainerTypeKey":9,"TypeDescription":"OTR","IsSelected":false}],"TMS_ContainerSizeKey":9,"TMSOrderDetailKey":0}],"L11Lines":null,"TMS_CustKey":3265,"TMS_SourceAddrKey":37245,"TMS_DestinationAddrKey":30985,"TMS_OrderTypeKey":1,"TMS_BorkerKey":6,"TMS_CarrierKey":101,"TMS_CSRKey":56,"UserKey":714,"SenderDetails":"","TMS_MarketLocationKey":2,"Consignee":null,"OrderNo":null}',
		@UserKey			int = 714,
		@IsSaved			bit = 0 ,
		@Reason				VARCHAR(500)='' ,
		@OrderKey			INT =0 ,
		@OrderNo			VARCHAR(50) = '' ,
		@OrderDate			DateTime	= '2020-01-01' 

Exec [TMS_integration_InsertOrder_MelroseTest] @siteid, @DataKey, @Json, @UserKey, @IsSaved output, @Reason output, @OrderKey output, @OrderNo Output, @OrderDate output
Select @IsSaved, @Reason, @OrderKey,@OrderNo , @OrderDate
*/
CREATE PROCEDURE [dbo].[TMS_integration_InsertOrder_MelroseTest]
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


	--INSERT INTO TESTDATA
	--SELECT @DataKey, @Json

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
			ErrorLine,L11Lines, notes, Consignee, TMS_MarketLocationKey  )
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
			Consignee			varchar(100)	'$.Consignee',
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
				sealNumberList			varchar(100),
				HazMatInfo				varchar(100)
			)

			insert into #container (ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList,ContainerProperties, grossWeight,weightUOM, sealNumberList, HazMatInfo )
			select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, 
				StopList ,ContainerProperties, grossWeight,weightUOM, sealNumberList, HazMatInfo
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
				sealNumberList			varchar(100)	'$.sealNumberList',
				HazMatInfo				varchar(100)	'$.isHazmat'
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
		select * from #stops

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
				@BaseRateAmount	 DECIMAL(18,2),
				@HazComment		 varchar(100) = null
				


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

			SET @OrderType = (SELECT OrderType FROM Integration_JCB.dbo.Melrose_Header A
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
			
			SET @OrderNo = ltrim(rtrim(Left(@custID,5))) +  CONVERT(varchar, YEAR(@OrderDate)) +  
				convert(varchar, case when @cnt < 100 then 
					substring( CONVERT(VARCHAR,100 + @CNT),2,2)
					else CONVERT(VARCHAR,100 + @CNT) END)


			INSERT INTO dbo.OrderHeader(OrderNo, OrderDate,Csrkey, CustKey,   
						SourceAddrKey,  DestinationAddrKey,  ReturnAddrKey,
						OrderTypeKey, [Status], HoldReasonKey, Consignee,
						StatusDate, BrokerKey, BrokerRefNo, 
						CarrierKey, VesselName, BillOfLading, BookingNo, Ach_Enabled,Ach_Amount,
						[PriorityKey], CreateDate, CreateUserKey,
						BillToAddrKey,ETADate,BaseRateAmount, MarketLocationKey )
			Select
						@OrderNo, @OrderDate, TMS_CSRKey,TMS_CustKey, 
						TMS_SourceAddrKey, TMS_DestinationAddrKey, null,
						TMS_OrderTypeKey, @OrderStausKey,@HoldReasonKey, Consignee,
						GETDATE(),TMS_BorkerKey, shipmentReferenceNumber, 
						TMS_CarrierKey, vessel, billOfLadingNumber, isnull(@BookingNo,workOrderNumber), @Ach_Enabled,@Ach_Amount,
						@PriorityKey, GETDATE(), @UserKey
						,@BillToAddrKey,ETADate,@BaseRateAmount , TMS_MarketLocationKey
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
			@sealNumberList		varchar(100),
			@HazMatInfo			varchar(100)


			SELECT @sealNumberList

		DECLARE ContCursor CURSOR LOCAL
		FOR Select ContainerKey, equipmentNumber, TMS_ContainerSizeKey, TMSOrderDetailKey, grossWeight, weightUOM, sealNumberList, HazMatInfo 
		from #container

		Open ContCursor
		set @ErrorLocation = 'Container'
		Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
			@grossWeight, @weightUOM, @sealNumberList, @HazMatInfo

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
			SELECT  @Orderkey , @ContainerId,isnull(@Containerno,@OrderNo) , @TMS_ContainerSizeKey ,
				null,ISNULL(@sealNumberList,''),@grossWeight, case when @weightUOM = 'KG' then 1 else 2 end ,
				@OrderDetailStatus, GETDATE(),@UserKey,@SourceAddrKey,
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

			--if(isnull(@HazMatInfo ,'') = 'true' )
			--Begin
			--	Set @HazComment = 'Hazard'
			--End

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

			--IF ISNULL(LTRIM(RTRIM(@HazComment)),'')<>''
			--BEGIN
			--	--***********************Update Container Type items****************
			--		EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@HazComment,@CreateUserKey=@CreateUserKey
			--	--*****************************************************************			
			--END	

			IF ISNULL(LTRIM(RTRIM(@TypeDesc)),'')<>''
				BEGIN
	
					--***********************Update Container Type items****************
						EXECUTE Update_ContainerTypeItem @OrderDetailKey= @NewOrderDetailKey,@ContType=@TypeDesc,@CreateUserKey=@CreateUserKey
					--*****************************************************************			
				END




			Fetch Next from ContCursor into @RTContainerKey, @ContainerNo, @TMS_ContainerSizeKey, @TMSOrderDetailKey ,  
				@grossWeight, @weightUOM, @sealNumberList,  @HazMatInfo
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

			select @SiteId, @DataKey, @ContainerKey, @PickStopKey, @RouteKey, @TMS_LegKey
			select @SiteId, @DataKey, @ContainerKey, @DelStopKey, @RouteKey, @TMS_LegKey

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
				VALUES (@Comment, GETDATE(),@UserKey)

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

