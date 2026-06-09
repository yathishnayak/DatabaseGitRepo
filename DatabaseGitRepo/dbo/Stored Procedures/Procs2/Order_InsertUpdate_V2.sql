
/**
DECLARE 
	@UserKey		INT=952,
	@JSONString		NVARCHAR(MAX)='{"PriorityKey":5,"CsrKey":106,"CustKey":3165,"Files":[],"OrderNo":"ACER2605XXX","OrderTypeKey":1,"OrderTypeDescription":"Import","MarketLocationKey":2,"SourceAddressKey":46544,"DestinationAddressKey":28443,"ReturnAddressKey":46555,"CustName":"Acer American Corporation (IPG-JCB)","BillToAddressKey":28442,"Ach_Enabled":true,"CSRManagerKey":106,"SalesPersonKey":4,"CreditLimitAvailable":0,"OrderDate":"2026-05-08T08:16:31.368Z","PriorityName":"HOT","BrokerRefNo":"CUST342423","DropOrLive":"Live","CarrierName":"FARHAD TRANSPORT -ABDOLLAH  MOMENI ","BillOfLading":"MBL234234","BookingNo":"BOOk8746587435","Ach_Amount":"166666","SenderInfo":"Test sender","SteamShipLineKey":31,"ConsigneeKey":2026,"OrderDetailList":[{"RowIndex":1,"ContainerNo":"IMPT2600971","ContainerSizeKey":"14","Size":"40 RFR","SealNo":"JHGJUYHG16723457643","Weight":1666,"WeightUnit":"1","WeightUnitDesc":"LB","DropOrLive":"Live","OrderTypeKey":1,"OrderTypeName":"Import","CsrKey":106,"CsrName":"Justin Nguyen ","BookingNo":"BOOk8746587435","Ref":"CUST342423","Priority":"HOT","PriorityKey":5,"Comments":"FTL,TRANSLD,BNDD","Properties":"FTL,TRANSLD,BNDD","ContainerProperties":[{"ContainerTypeKey":11,"OrderDetailKey":0,"IsSelected":true,"TypeDescription":"FTL"},{"ContainerTypeKey":6,"OrderDetailKey":0,"IsSelected":true,"TypeDescription":"TRANSLD"},{"ContainerTypeKey":16,"OrderDetailKey":0,"IsSelected":true,"TypeDescription":"BNDD"}],"Ship_From":"3 Harbors","StopAddrKeySF":46544,"LocTypeSF":"Port","Ship_To":"Acer American Corporation (IPG-JCB)","StopAddrKeyST":28443,"LocTypeST":"Customer","Return_To":"ICTF","StopAddrKeyRT":46555,"LocTypeRT":"Port","StopOffA":"JCT ALAMEDA","StopAddrKeySTA":42296,"StopOffB":"ITS-LB 234","StopAddrKeySTB":29512,"OrderDetailKey":0}],"OrderStops":[{"StopTypeKey":1,"StopTypeName":"Pickup","StopTypeShortcode":"SF","IsFoundationStop":true,"OrderBy":1,"IsActive":true,"CreateDate":"2024-12-17T02:47:47.213","CreateUserKey":29,"CreateUserName":"Shiva Prasad","UpdateUserName":"Shiva Prasad","StopNumber":1,"StopName":"3 Harbors","AddressLine1":"2300 West Willow Street","City":"Long Beach","State":"CA","Country":"USA","StopAddrKey":46544,"LocationType":"Port"},{"StopTypeKey":2,"StopTypeName":"Stop","StopTypeShortcode":"AF","IsFoundationStop":false,"OrderBy":2,"IsActive":true,"CreateDate":"2024-12-17T02:47:47.213","CreateUserKey":29,"CreateUserName":"Shiva Prasad","UpdateUserName":"Shiva Prasad","StopName":"JCT ALAMEDA","AddressLine1":"21900 S ALAMEDA ST ","City":"Long Beach","State":"CA","Country":"USA","StopAddrKey":42296,"LocationType":"Yard"},{"StopTypeKey":3,"StopTypeName":"Delivery","StopTypeShortcode":"ST","IsFoundationStop":true,"OrderBy":3,"IsActive":true,"CreateDate":"2024-12-17T02:47:47.213","CreateUserKey":29,"CreateUserName":"Shiva Prasad","UpdateUserName":"Shiva Prasad","StopNumber":2,"StopName":"Acer American Corporation (IPG-JCB)","AddressLine1":"1730 N. 1st Street Suite 400","City":"San Jose","State":"CA","Country":"USA","StopAddrKey":28443,"LocationType":"Customer"},{"StopTypeKey":4,"StopTypeName":"Stop","StopTypeShortcode":"AT","IsFoundationStop":false,"OrderBy":4,"IsActive":true,"CreateDate":"2024-12-17T02:47:47.213","CreateUserKey":29,"CreateUserName":"Shiva Prasad","UpdateUserName":"Shiva Prasad","StopName":"ITS-LB 234","AddressLine1":"1281 PIER G WAY","City":"Long Beach","State":"CA","Country":"USA","StopAddrKey":29512,"LocationType":"Port"},{"StopTypeKey":5,"StopTypeName":"Return","StopTypeShortcode":"RT","IsFoundationStop":true,"OrderBy":5,"IsActive":true,"CreateDate":"2024-12-17T02:47:47.213","CreateUserKey":29,"CreateUserName":"Shiva Prasad","UpdateUserName":"Shiva Prasad","StopNumber":3,"StopName":"ICTF","AddressLine1":"2401 E Sepulveda Blvd","City":"Long Beach","State":"CA","Country":"USA","StopAddrKey":46555,"LocationType":"Port"}]}',
	@Status			BIT=0,
	@IsDebug		BIT = 0, 
	@JsonOutput NVARCHAR(max) ='', 	
	@Reason VARCHAR(100)=''
EXEC Order_InsertUpdate_V2 @UserKey,@JSONString,@JsonOutput OUTPUT,@Status OUTPUT,@Reason OUTPUT, @IsDebug
SELECT @JsonOutput, @Status, @Reason
**/
CREATE PROC [dbo].[Order_InsertUpdate_V2]
(
	@UserKey			int,
	@JsonString			nvarchar(max) = '',
	@JsonOutput			nvarchar(max) ='' OUTPUT,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' OUTPUT,
	@IsDebug			bit = 0
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @OrderDetailKey INT, @IsExists BIT

	IF ISNULL(@JSONString, '') = ''
    BEGIN
        SET @Status = 0;
        SET @Reason = 'Invalid JSON input';
        RETURN;
    END

	create table #tmp 
	(
		RESULT		int
	)
	SELECT *
    INTO #Header
    FROM OPENJSON(@JSONString)
    WITH (
        OrderKey						BIGINT			'$.OrderKey',
		OrderNo							varchar(50)		'$.OrderNo',
		CustKey							INT				'$.CustKey',
		OrderDate						varchar(100)	'$.OrderDate',
		BillToAddressKey				int				'$.BillToAddressKey',
		SourceAddressKey				INT				'$.SourceAddressKey',
		DestinationAddressKey			INT				'$.DestinationAddressKey',
		BillToAddrName					varchar(100)	'$.BillToAddrName',
		SourceAddrName					varchar(100)	'$.SourceAddrName',
		DestinationAddrName				varchar(100)	'$.DestinationAddrName',
		ReturnAddressKey				INT				'$.ReturnAddressKey',
		Source							int				'$.Source',
		OrderType						INT				'$.OrderType',
		Status							INT				'$.Status',
		strStatusDate					varchar(100)	'$.StatusDate',
		HoldReason						INT				'$.HoldReason',
		strHoldDate						varchar(100)	'$.HoldDate',
		BrokerName						varchar(100)	'$.BrokerName',
		BrokerId						varchar(100)	'$.BrokerId',
		Brokerkey						INT				'$.BrokerKey',
		BrokerRefNo						varchar(100)	'$.BrokerRefNo',
		PortofOriginKey					INT				'$.PortofOriginKey',
		PortofOrigin					varchar(100)	'$.PortofOrigin',
		PortofDestinationKey			INT				'$.PortofDestinationKey',
		PortofDestination				varchar(100)	'$.PortofDestination',
		CarrierKey						INT				'$.CarrierKey',
		Carrier							varchar(100)	'$.Carrier',
		VesselName						varchar(100)	'$.VesselName',
		BillofLading					varchar(100)	'$.BillofLading',
		DropLive						VARCHAR(10)		'$.DropOrLive',
		BookingNo						varchar(100)	'$.BookingNo',
		CutOffDate						varchar(100)	'$.CutOffDate',
		Priority						INT				'$.PriorityKey',
		IsHazardous						BIT				'$.IsHazardous',
		CreatedBy						INT				'$.CreatedBy',
		CreatedUser						Varchar(100)	'$.CreatedUser',
		strCreatedDate					varchar(100)	'$.CreatedDate',
		ACH_Amount						decimal(18,5)	'$.Ach_Amount',
		ACH_Enabled						BIT				'$.Ach_Enabled',
		csrname							varchar(100)	'$.CsrName',
		csrkey							INT				'$.CsrKey',
		Comment							varchar(500)	'$.Comment',
		OrderTypeKey					INT				'$.OrderTypeKey',
		ordertypedescription			varchar(50)		'$.OrderTypeDescription',
		statusdescription				varchar(100)	'$.StatusDescription',
		nextaction						varchar(100)	'$.NextAction',
		containercount					INT				'$.ContainerCount',
		ETA_Date						varchar(100)	'$.ETADate',
		BaseRateAmount					decimal(18,5)	'$.BaseRateAmount',
		CustomerName					varchar(100)	'$.CustomerName',
		PickupLocation					varchar(100)	'$.PickupLocation',
		DeliveryLocation				varchar(100)	'$.DeliveryLocation',
		ReleaseNo						varchar(100)	'$.ReleaseNo',

		orderHeaderCommentBOList		nvarchar(max)	'$.OrderHeaderCommentList' as JSON,
		OrderDetailCommentBOList		nvarchar(max)	'$.OrderDetailCommentList' as JSON,
		files							nvarchar(max)	'$.Files' as JSON,
		BillToAddressBO					nvarchar(max)	'$.BillToAddress' as JSON,
		SourceAddressBO					nvarchar(max)	'$.SourceAddress' as JSON,
		DestinationAddressBO			nvarchar(max)	'$.DestinationAddress' as JSON,
		ReturnAddressBO					nvarchar(max)	'$.ReturnAddress' as JSON,
		BrokerAddressBO					nvarchar(max)	'$.BrokerAddress' as JSON,
		orderdetailslist				nvarchar(max)	'$.OrderDetailList' as JSON,

		--OrderDetails					nvarchar(max)	'$.OrderDetails' as JSON, --This is not used
		IsEdit							BIT				'$.IsEdit',
		UploadedDocumentKeyList			varchar(500)	'$.UploadedDocumentKeyList',
		DeletedBy						int				'$.DeletedBy',
		strDeletedDate					varchar(100)	'$.DeletedDate',
		SalesPersonKey					INT				'$.SalesPersonKey',
		SalesPersonName					varchar(100)	'$.SalesPersonName',
		CSRManagerKey					INT				'$.CSRManagerKey',
		CSRManagerName					varchar(100)	'$.CSRManagerName',
		MarketLocationKey				INT				'$.MarketLocationKey',
		SteamShipLinekey				INT				'$.SteamShipLineKey',
		Consignee						varchar(100)	'$.Consignee',
		ConsigneeKey					INT				'$.ConsigneeKey',
		OrderSource						varchar(100)	'$.OrderSource',
		MarketLocation					varchar(100)	'$.MarketLocation',
		ContainerNos					varchar(100)	'$.ContainerNos',
		strOrderDate					varchar(100)	'$.StrOrderDate',
		--orderdetails_2					nvarchar(max)	'$.Orderdetails2' as JSON,
		OrderStops						nvarchar(max)	'$.OrderStops' as JSON,
		CreditLimitAvailable			decimal(18,5)	'$.CreditLimitAvailable',
		SenderInfo						NVARCHAR(100)	'$.SenderInfo'
	)

	UPDATE #Header SET CreatedBy = @UserKey

	declare 
		@orderHeaderCommentBOList		nvarchar(max),
		@OrderDetailCommentBOList		nvarchar(max),
		@files							nvarchar(max),
		@BillToAddressBO				nvarchar(max),
		@SourceAddressBO				nvarchar(max),
		@DestinationAddressBO			nvarchar(max),
		@ReturnAddressBO				nvarchar(max),
		@BrokerAddressBO				nvarchar(max),
		@orderdetailslist				nvarchar(max),
		@orderdetails_1					nvarchar(max),
		@orderdetails_2					nvarchar(max),
		@OrderStops						nvarchar(max)

	select @orderHeaderCommentBOList = orderHeaderCommentBOList,
			@orderHeaderCommentBOList = orderHeaderCommentBOList,
			@files	= Files,
			@BillToAddressBO =  BillToAddressBO,
			@SourceAddressBO =  SourceAddressBO,
			@DestinationAddressBO = DestinationAddressBO,
			@ReturnAddressBO = ReturnAddressBO,
			@BrokerAddressBO = BrokerAddressBO,
			@orderdetailslist = orderdetailslist,
			--@orderdetails_1 = OrderDetails,
			--@orderdetails_2 = orderdetails_2,
			@OrderStops		= OrderStops
	from #Header 

	SELECT *
    INTO #HeaderComments
    FROM OPENJSON(@orderHeaderCommentBOList,'$')
    WITH (
        OrderKey						BIGINT			'$.OrderKey',
		Commentkey						int				'$.CommentKey',
		HeaderComment					varchar(max)	'$.HeaderComment'
	)

	SELECT *
    INTO #DetailComments
    FROM OPENJSON(@OrderDetailCommentBOList,'$')
    WITH (
        OrderDetailKey					BIGINT			'$.OrderDetailKey',
		Commentkey						int				'$.CommentKey',
		DetailComment					varchar(max)	'$.DetailComment'
	)

	SELECT *
    INTO #Files
    FROM OPENJSON(@files,'$')
    WITH (
		Dockey							int				'$.DocKey',				
		OrderKey						int				'$.OrderKey',
		CreatedBy						int				'$.CreatedBy',
		CreatedOn						varchar(50)		'$.CreatedOn',
		FileName						varchar(500)	'$.FileName',
		FileType						varchar(50)		'$.FileType',
		DocType							int				'$.DocType',
		DocTypeDescription				varchar(500)	'$.DocTypeDescription',
		FileSizeInMB					int				'$.FileSizeInMB',
		OrderNo							varchar(50)		'$.OrderNo'
	)

	
	SELECT *, 0 as OrderKey
    INTO #orderdetailslist
    FROM OPENJSON(@orderdetailslist,'$')
    WITH (
        OrderDetailKey						int				'$.OrderDetailKey',
		containerid							varchar(50)		'$.ContainerId',
		ContainerNo							varchar(50)		'$.ContainerNo',
		ContainerSize						int				'$.ContainerSizeKey',
		Chassis								varchar(50)		'$.Chassis',
		SealNo								varchar(50)		'$.SealNo',
		Weight								varchar(50)		'$.Weight',
		WeightUnit							int				'$.WeightUnit',
		ContainerStatus						int				'$.ContainerStatus',
		Comments							varchar(500)	'$.Comments',
		VesselETA							varchar(50)		'$.VesselETA',
		OrderType							int				'$.OrderTypeKey',
		BookingNo							varchar(50)		'$.BookingNo',
		Ref									varchar(50)		'$.Ref',
		DropOrLive							varchar(10)		'$.DropOrLive',
		PriorityKey							int				'$.PriorityKey',
		IsHazardous							bit				'$.IsHazardous',
		StopAddrKeySF						int				'$.StopAddrKeySF',
		StopAddrKeyST						int				'$.StopAddrKeyST',
		StopAddrKeyRT						int				'$.StopAddrKeyRT',
		StopAddrKeySTA					int					'$.StopAddrKeySTA',
		StopAddrKeySTB					int					'$.StopAddrKeySTB',
		LocTypeSF							varchar(50)		'$.LocTypeSF',
		LocTypeST							varchar(50)		'$.LocTypeST',
		LocTypeRT							varchar(50)		'$.LocTypeRT',
		LocTypeSTA							varchar(50)		'$.LocTypeSTA',
		LocTypeSTB							varchar(50)		'$.LocTypeSTB',
		ODStopKeySF							bigint			'$.ODStopKeySF',
		ODStopKeyST							bigint			'$.ODStopKeyST',
		ODStopKeyRT							bigint			'$.ODStopKeyRT',
		ODStopKeySTA						bigint			'$.ODStopKeySTA',
		ODStopKeySTB						bigint			'$.ODStopKeySTB',
		Containerprops						nvarchar(max)	'$.ContainerProps' as JSON,
		CSRKey								INT				'$.CsrKey',
		HazardClasses						VARCHAR(200)	'$.HazardClasses'
	)

	SELECT *, 0 as OrderKey
    INTO #OrderStopsList
    FROM OPENJSON(@OrderStops,'$')
    WITH (
		OrderStopKey						int				'$.OrderStopKey',
        StopTypeKey							int				'$.StopTypeKey',
		StopTypeName						varchar(50)		'$.StopTypeName',
		StopTypeShortcode					varchar(5)		'$.StopTypeShortcode',
		StopName							varchar(50)		'$.StopName',
		StopAddress							varchar(500)	'$.StopAddress',
		StopAddrKey							int				'$.StopAddrKey',
		StopNumber							int				'$.StopNumber',
		LocationType						varchar(50)		'$.LocationType',
		StatusKey							int				'$.StatusKey',
		IsFoundationStop					bit				'$.IsFoundationStop',
		OrderBy								smallint		'$.OrderBy'
	)
	
	
	if (@IsDebug = 1)
	BEGIN
		SELECT '#Header' Header, * from #Header
		--Select '#BillToAddressBO' BillToAddressBO,* from #BillToAddressBO
		--SElect '#BrokerAddressBO' BrokerAddressBO,* from #BrokerAddressBO
		--Select '#DestinationAddressBO' DestinationAddressBO,* from #DestinationAddressBO
		Select '#DetailComments' DetailComments,* from #DetailComments
		SElect '#Files' Files,* from #Files
		Select '#HeaderComments' HeaderComments,* from #HeaderComments
		Select '#orderdetailslist' orderdetailslist,* from #orderdetailslist
		--Select '#SourceAddressBO' SourceAddressBO,* from #SourceAddressBO
		--Select '#ReturnAddressBO' ReturnAddressBO, * from #ReturnAddressBO
		select '#OrderStopsList' as OrderStopsList,* from #OrderStopsList
	END

	Declare @HeaderCount	int,
			@DetailCount	int,
			@BillToAddrCount	int,
			@SourceAddrCount	int,
			@ReturnAddrCount	int,
			@BrokerAddrCount	int,
			@DestAddrCount		int,
			@FilesCount			int,
			@HeadCommCount		int,
			@DetailCommCount	int,
			@OrderStopsCount	int

	Select @HeaderCount = count(1) from #Header
	select @DetailCount = count(1) from #orderdetailslist
	--select @BillToAddrCount = count(1) from #BillToAddressBO
	--Select @SourceAddrCount = Count(1) from #SourceAddressBO
	--Select @DestAddrCount = count(1) from #DestinationAddressBO
	--select @ReturnAddrCount = count(1) from #ReturnAddressBO
	Select @FilesCount = count(1) from #Files
	select @HeadCommCount = count(1) from #HeaderComments
	select @DetailCommCount = count(1) from #DetailComments
	SElect @OrderStopsCount = count(1) from #OrderStopsList where isnull(StopName,'') <> ''

	set @IsExists = 0

	if(@HeaderCount > 0 AND @DetailCount > 0  )
	Begin
		set @IsExists = 1
	End

	if(@IsExists = 1)
	Begin
		Declare 
		@OrderKey							BIGINT			,
		@OrderNo							varchar(50)		,
		@CustKey							INT				,
		@BillToAddressKey					int				,
		@SourceAddressKey					INT				,
		@DestinationAddressKey				INT				,
		@BillToAddrName						varchar(100)	,
		@SourceAddrName						varchar(100)	,
		@DestinationAddrName				varchar(100)	,
		@ReturnAddressKey					INT				,
		@Source								int				,
		@OrderType							INT				,
		@OrderStatus						INT				,
		@strStatusDate						varchar(100)	,
		@HoldReason							INT				,
		@strHoldDate						varchar(100)	,
		@BrokerName							varchar(100)	,
		@BrokerId							varchar(100)	,
		@Brokerkey							INT				,
		@DropLive							VARCHAR(10)		,
		@BrokerRefNo						varchar(100)	,
		@PortofOriginKey					INT				,
		@PortofOrigin						varchar(100)	,
		@PortofDestinationKey				INT				,
		@PortofDestination					varchar(100)	,
		@CarrierKey							INT				,
		@Carrier							varchar(100)	,
		@VesselName							varchar(100)	,
		@BillofLading						varchar(100)	,
		@BookingNo							varchar(100)	,
		@CutOffDate							varchar(100)	,
		@Priority							INT				,
		@IsHazardous						BIT				,
		@CreatedBy							INT				,
		@CreatedUser						Varchar(100)	,
		@strCreatedDate						varchar(100)	,
		@ACH_Amount							decimal(18,5)	,
		@ACH_Enabled						BIT				,
		@csrname							varchar(100)	,
		@csrkey								INT				,
		@Comment							varchar(500)	,
		@OrderTypeKey						INT				,
		@ordertypedescription				varchar(50)		,
		@statusdescription					varchar(100)	,
		@nextaction							varchar(100)	,
		@containercount						INT				,
		@ETA_Date							Datetime		,
		@BaseRateAmount						decimal(18,5)	,
		@CustomerName						varchar(100)	,
		@PickupLocation						varchar(100)	,
		@DeliveryLocation					varchar(100)	,
		@ReleaseNo							varchar(100)	,
		@IsEdit								BIT			,
		@UploadedDocumentKeyList			varchar(500),
		@DeletedBy							int			,
		@strDeletedDate						varchar(100),
		@SalesPersonKey						INT			,
		@SalesPersonName					varchar(100),
		@CSRManagerKey						INT			,
		@CSRManagerName						varchar(100),
		@MarketLocationKey					INT			,
		@SteamShipLinekey					INT			,
		@Consignee							varchar(100),
		@ConsigneeKey						INT,
		@OrderSource						varchar(100),
		@MarketLocation						varchar(100),
		@ContainerNos						varchar(100),
		@strOrderDate						varchar(100),
		@CreditLimitAvailable				decimal(18,5),
		@SenderInfo							NVARCHAR(100)=''
		
		SElect 
			@OrderKey					=	OrderKey				,
			@OrderNo					=	OrderNo					,
			@CustKey					=	CustKey					,
			@BillToAddressKey			=	BillToAddressKey		,
			@SourceAddressKey			=	SourceAddressKey		,
			@DestinationAddressKey		=	DestinationAddressKey	,
			@BillToAddrName				=	BillToAddrName			,
			@SourceAddrName				=	SourceAddrName			,
			@DestinationAddrName		=	DestinationAddrName		,
			@ReturnAddressKey			=	ReturnAddressKey		,
			@Source						=	Source					,
			@OrderType					=	OrderType				,
			@OrderStatus				=	Status					,
			@strStatusDate				=	strStatusDate			,
			@HoldReason					=	HoldReason				,
			@strHoldDate				=	strHoldDate				,
			@BrokerName					=	BrokerName				,
			@BrokerId					=	BrokerId				,
			@Brokerkey					=	Brokerkey				,
			@DropLive					=	DropLive				,
			@BrokerRefNo				=	BrokerRefNo				,
			@PortofOriginKey			=	PortofOriginKey			,
			@PortofOrigin				=	PortofOrigin			,
			@PortofDestinationKey		=	PortofDestinationKey	,
			@PortofDestination			=	PortofDestination		,
			@CarrierKey					=	CarrierKey				,
			@Carrier					=	Carrier					,
			@VesselName					=	VesselName				,
			@BillofLading				=	BillofLading			,
			@BookingNo					=	BookingNo				,
			@CutOffDate					=	CutOffDate				,
			@Priority					=	Priority				,
			@IsHazardous				=	IsHazardous				,
			@CreatedBy					=	CreatedBy				,
			@CreatedUser				=	CreatedUser				,
			@strCreatedDate				=	strCreatedDate			,
			@ACH_Amount					=	ACH_Amount				,
			@ACH_Enabled				=	ACH_Enabled				,
			@csrname					=	csrname					,
			@csrkey						=	csrkey					,
			@Comment					=	Comment					,
			@OrderTypeKey				=	OrderTypeKey			,
			@ordertypedescription		=	ordertypedescription	,
			@statusdescription			=	statusdescription		,
			@nextaction					=	nextaction				,
			@containercount				=	containercount			,
			@ETA_Date					=	ETA_Date				,
			@BaseRateAmount				=	BaseRateAmount			,
			@CustomerName				=	CustomerName			,
			@PickupLocation				=	PickupLocation			,
			@DeliveryLocation			=	DeliveryLocation		,
			@ReleaseNo					=	ReleaseNo				,
			@IsEdit						=	IsEdit					,
			@UploadedDocumentKeyList	=	UploadedDocumentKeyList	,
			@DeletedBy					=	DeletedBy				,
			@strDeletedDate				=	strDeletedDate			,
			@SalesPersonKey				=	SalesPersonKey			,
			@SalesPersonName			=	SalesPersonName			,
			@CSRManagerKey				=	CSRManagerKey			,
			@CSRManagerName				=	CSRManagerName			,
			@MarketLocationKey			=	MarketLocationKey		,
			@SteamShipLinekey			=	SteamShipLinekey		,
			@Consignee					=	Consignee				,
			@ConsigneeKey				=	ConsigneeKey			,
			@OrderSource				=	OrderSource				,
			@MarketLocation				=	MarketLocation			,
			@ContainerNos				=	ContainerNos			,
			@strOrderDate				=	strOrderDate			,
			@CreditLimitAvailable		=	CreditLimitAvailable	,
			@SenderInfo					=   SenderInfo
		from #Header
		
		Declare @OrderDate	datetime
		SET @OrderDate = convert(datetime, @strOrderDate)
		SEt @OrderDate = isnull(@OrderDate, GetDatE())

		Declare @OutPut bit = 0,
				@IsNew	bit = case when isnull(@OrderKey,0) = 0 then 1 else 0 end

		if(Isnull(@ORderkey,0) > 0)
		Begin
			update #OrderStopsList set orderkey =  @OrderKey
			update #orderdetailslist set OrderKey = @OrderKey
		End

		BEGIN TRY 
			BEGIN TRANSACTION ORDER_V2
			print 'Transaction Start'
			if (Isnull(@OrderKey,0) = 0)
			Begin
				print 'Insert_OrderHeader'
				insert into #tmp (result)
				Exec dbo.Insert_OrderHeader 	@OrderNo, @OrderDate, @CustKey, @BillToAddressKey, @Csrkey, @CSRManagerKey, 
					@SalesPersonKey, @SourceAddressKey, @DestinationAddressKey, @ReturnAddressKey, @OrderTypeKey, @Status, 
					@BrokerKey, @BrokerrefNo, @CarrierKey, @VesselName, @BillOfLading, @DropLive, @BookingNo, @Ach_Enabled, @Ach_Amount, 
					null, null, null, Null, @Priority, @Comment, @CreatedBy, @ETA_Date, @BaseRateAmount, @MarketLocationKey, 
					@SteamShipLinekey, @Consignee, @ConsigneeKey, @OrderKey OUTPUT,@SenderInfo
				print 'OrderKey'
				print @OrderKey
				update #OrderStopsList set orderkey =  @OrderKey
				update #orderdetailslist set OrderKey = @OrderKey
			End
			Else
			Begin
				print 'Update_OrderHeader'
				insert into #tmp (result)
				Exec dbo.Update_OrderHeader @OrderKey, @CustKey, @BillToAddressKey, @CsrKey, @CSRManagerKey, @SalesPersonKey, 
					@SourceAddressKey, @DestinationAddressKey, @ReturnAddressKey, @OrderTypeKey, @OrderStatus, @BrokerKey, 
					@BrokerRefNo,@CarrierKey, @VesselName, @BillOfLading, @DropLive, @BookingNo, @Priority, @Ach_Enabled, @Ach_Amount, 
					@Comment, @CreatedBy, @ETA_Date, @BaseRateAmount, @OrderNo, @MarketLocationKey, 
					@SteamShipLinekey,@Consignee, @ConsigneeKey, @OutPut OUTPUT,@SenderInfo
			End

			if(@OrderStopsCount > 0)
			Begin
				Declare @StopsOutput	nvarchar(max),
						@StopsStatus	bit,
						@StopsReason	varchar(500)
				set @OrderStops =( select OrderStops = (select * from #OrderStopsList FOR JSON PATH))
				print 'OrderStops'
				print @OrderStops

				insert into #tmp (result)
				Exec Order_SaveStopList @UserKey,@OrderStops,@StopsOutput OUTPUT,@StopsStatus OUTPUT,@StopsReason OUTPUT, 0

				
				if(@IsDebug = 1)
				Begin
					Select @StopsOutput as StopsOutput, @StopsStatus as StopsStatus, @StopsReason as StopsReason
				End
			End

			if(@DetailCount > 0)
			Begin
				Declare 
					@OrderDetailKey_Cur INT,
					@ContainerNo_Cur	VARCHAR(30),
					@containerid_Cur	VARCHAR(50),
					@ContainerSize_Cur	SMALLINT,
					@Chassis_Cur		VARCHAR(20),
					@SealNo_Cur			VARCHAR(20),
					@Weight_Cur			DECIMAL(18,2),
					@WeightUnit_Cur		SMALLINT,
					@Comment_Cur		VARCHAR(500),
					@VesselETA_Cur		DateTime = '1/1/1900',
					@ContOrderType			int	,		
					@ContBookingNo			varchar(50)	,
					@ContRef				varchar(50)	,
					@DropOrLive			varchar(10)	,
					@PriorityKey		int			,
					@IsHazardous_cur	Bit = 0,
					@StopAddrKeySF	int,
					@StopAddrKeyST	int,
					@StopAddrKeyRT	int,
					@StopAddrKeySTA	int,
					@StopAddrKeySTB	int,
					@LocTypeSF			varchar(50),
					@LocTypeST			varchar(50),
					@LocTypeRT			varchar(50),
					@LocTypeSTA			varchar(50),
					@LocTypeSTB			varchar(50),
		
					@ODStopKeySF		bigint,		
					@ODStopKeyST		bigint,		
					@ODStopKeyRT		bigint,		
					@ODStopKeySTA		bigint,		
					@ODStopKeySTB		bigint,		
					@Containerprops		nvarchar(max),
					@ContainerData		nvarchar(max) = '',
					@ContainerOutput	nvarchar(max),
					@ContainerStatus	bit,
					@ContainerReason	varchar(500),
					@CSRKey_Cur			int,
					@HazardClasses		varchar(200)

				Declare CurDetail CURSOR For
				Select OrderDetailKey,containerid,ContainerNo,ContainerSize,
					Chassis, SealNo, Weight, WeightUnit,Comments, VesselETA , IsHazardous,
					StopAddrKeySF, StopAddrKeyST, StopAddrKeyRT, StopAddrKeySTA, 
					StopAddrKeySTB, Containerprops, LocTypeSF, LocTypeST, LocTypeRT, LocTypeSTA, 
					LocTypeSTB	, ODStopKeySF, ODStopKeyST, ODStopKeyRT, ODStopKeySTA, ODStopKeySTB,
					OrderType,BookingNo, Ref, DropOrLive, PriorityKey,CSRKey,HazardClasses	
				from #orderdetailslist

				Open CurDetail
				Fetch Next from CurDetail 
					into  @OrderDetailKey_Cur,  @containerid_Cur, @ContainerNo_Cur, @ContainerSize_Cur,
							@Chassis_Cur, @SealNo_Cur, @Weight_Cur, @WeightUnit_Cur, @Comment_Cur, 
							@VesselETA_Cur, @IsHazardous_cur, @StopAddrKeySF, @StopAddrKeyST, 
							@StopAddrKeyRT, @StopAddrKeySTA, @StopAddrKeySTB, @Containerprops,
							@LocTypeSF, @LocTypeST, @LocTypeRT, @LocTypeSTA, @LocTypeSTB, @ODStopKeySF, 
							@ODStopKeyST, @ODStopKeyRT, @ODStopKeySTA, @ODStopKeySTB,
							@ContOrderType, @ContBookingNo, @ContRef, @DropOrLive, @PriorityKey	,@CSRKey_Cur, @HazardClasses
				WHILE @@FETCH_STATUS = 0  
				BEGIN  
					print 'OrderDetail start'
					print @ContainerNo_Cur
					--IF(isnull(@OrderDetailKey_Cur ,0) = 0)
					--Begin
						SEt @ContainerData = (select 
						@OrderKey as OrderKey,
						@OrderDetailKey_Cur AS OrderDetailKey,
						@ContainerId_cur as ContainerId,
						@ContainerNo_Cur as Containerno,
						@ContainerSize_Cur as ContainerSize, 
						@Chassis_Cur as Chassis, 
						@SealNo_Cur as Sealno,
						@Weight_Cur as Weight,
						@WeightUnit_Cur as WeightUnit,
						@Comment_cur as Comment,
						@UserKey as CreateUserKey,
						@VesselETA_Cur as VesselETA,
						@IsHazardous_cur as IsHazardus,
						@ContOrderType		as OrderType,		
						@ContBookingNo		as BookingNo,		
						@ContRef			as Ref		,	
						@DropOrLive			as DropOrLive,		
						@PriorityKey		as PriorityKey,	
						@StopAddrKeySF		as StopAddrKeySF	,
						@StopAddrKeyST		as StopAddrKeyST,	
						@StopAddrKeyRT		as StopAddrKeyRT,	
						@StopAddrKeySTA		as StopAddrKeySTA,	
						@StopAddrKeySTB		as StopAddrKeySTB,	
						@LocTypeSF			as LocTypeSF,	
						@LocTypeST			as LocTypeST,			
						@LocTypeRT			as LocTypeRT,			
						@LocTypeSTA			as LocTypeSTA,			
						@LocTypeSTB			as LocTypeSTB,			
						@ODStopKeySF		as ODStopKeySF,
						@ODStopKeyST		as ODStopKeyST,
						@ODStopKeyRT		as ODStopKeyRT,
						@ODStopKeySTA		as ODStopKeySTA,
						@ODStopKeySTB		as ODStopKeySTB	,
						@CSRKey_Cur			as CSRKey,
						@DropLive			as DropLive,
						@Containerprops		AS Containerprops,
						@HazardClasses		AS HazardClasses
						for JSON PATH)
						print '@ContainerData'
						print @ContainerData

						declare @SqlStmt nvarchar(max) 
						set @SqlStmt = N'InsertUpdate_OrderDetail_V2 @UserKey=' + convert( varchar(50),@UserKey) + ', ' 
							+ '@ContainerData=' + @ContainerData + ',' 
							+ '@ContainerOutput ' + ' OUTPUT,' + '@ContainerStatus ' + ' OUTPUT,' 
							+  '@ContainerReason ' + ' OUTPUT, 0'

						--insert into #tmp (result)
						--exec sp_executesql @Sqlstmt ;
						Exec InsertUpdate_OrderDetail_V2 @UserKey,@ContainerData,@ContainerOutput OUTPUT,@ContainerStatus OUTPUT,@ContainerReason OUTPUT, 0
				
					--End

					Fetch Next from CurDetail 
					into  @OrderDetailKey_Cur,  @containerid_Cur, @ContainerNo_Cur, @ContainerSize_Cur,
							@Chassis_Cur, @SealNo_Cur, @Weight_Cur, @WeightUnit_Cur, @Comment_Cur, 
							@VesselETA_Cur, @IsHazardous_cur, @StopAddrKeySF, @StopAddrKeyST, 
							@StopAddrKeyRT, @StopAddrKeySTA, @StopAddrKeySTB, @Containerprops,
							@LocTypeSF, @LocTypeST, @LocTypeRT, @LocTypeSTA, @LocTypeSTB, @ODStopKeySF, 
							@ODStopKeyST, @ODStopKeyRT, @ODStopKeySTA, @ODStopKeySTB,
							@ContOrderType, @ContBookingNo, @ContRef, @DropOrLive, @PriorityKey	,@CSRKey_Cur, @HazardClasses
				END  
				CLOSE CurDetail  
				DEALLOCATE CurDetail
			End
		
			
			COMMIT TRANSACTION ORDER_V2
		END TRY
		BEGIN CATCH
			print ERROR_number()
			Print ERROR_MESSAGE()
			Print ERROR_Line()
			Print ERROR_State()
			ROLLBACK TRANSACTION ORDER_V2
			SET @Status = 0
			set @Reason = ERROR_MESSAGE()
			Return
		END CATCH
	End
	
	SEt @JsonOutput = (select @OrderKey as OrderKey for JSON PATH)

	IF(@IsExists = 1)
	BEGIN
		select OrderKey,OrderNo, OrderDate from ORderheader WITH (NOLOCK) where ORderKey = @OrderKey  for JSON PATH, WITHOUT_ARRAY_WRAPPER
		set @Status = 1
		SEt @Reason = 'Success'
	END
	ELSE
	BEGIN
		SET @Status = 0
		SEt @Reason = 'Data doesn''t exists for the OrderDetailKey passed'
	END
	drop table #tmp
	drop table #DetailComments
	drop table #Files
	drop table #Header
	drop table #HeaderComments
	drop table #orderdetailslist
	drop table #OrderStopsList
END
