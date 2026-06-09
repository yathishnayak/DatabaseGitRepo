
/**
--OOCU7162977
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"ContainerNo":"","ThisWeek":false,"Today":false,"Arrived":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"NearingDemurrage":false,"WithDemurrage":false,"WithDetention":false,"Terminal":"","PageNo":1,"PageSize":50,"SortField":"OrderNo","IsAscending":true,"CSMKeys":"","CSRKeys":"","ContainerStatusKeys":"","CustKeys":"","SalesPersonKeys":"","HoldStatus":"","TerminalNames":"","TerminalCodes":"","VesselIMOs":"","MarketKeys":"","SearchText":"","DischargeYN":"","RangeName":"","ContainerStatus":"","TruckStatus":"","IsMissingUpdates":false,"IsUnapprovedCharges":false,"SearchCriteriaKey":0,"PickupAvailable":"","HoldTypes":"","PickUpFrom":null,"PickUpTo":null,"StatusKey":2,"OrderType":"","Deliverylocationkeys":"","Tracking":""}',
	@Status BIT=0, @IsDebug bit = 0,
	@Reason VARCHAR(100)=''
EXec Scheduler_GetListV2_Optimised @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Scheduler_GetListV2]   
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
WITH RECOMPILE
AS
BEGIN

	Declare @ProcessStart		Datetime,
			@ProcessEnd			DateTime,
			@KeyFetchStart		Datetime,
			@KeyFetchEnd		Datetime,
			@DataFetchStrt		Datetime,
			@DataFetchEnd		DateTime,
			@DataProcessStart	DateTime,
			@dataProcessEnd		DateTime,
			@DataSendStart		DateTime,
			@DataSendEnd		DateTime

	set @ProcessStart = sysutcdatetime()

	if(@IsDebug = 1)
	Begin
		print 'Start Time - Process Start'
		
		print convert(varchar,@ProcessStart )
	End
	/* TIME LOG CAPTURE START TIME */
	INSERT INTO SqlExecutionTimeLog
	(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	VALUes (@UserKey,'Scheduler_GetListV2','Procedure Entered','',GETDATE())

	/*SETTINGS */
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;
	SET ANSI_PADDING,
    ANSI_WARNINGS,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    QUOTED_IDENTIFIER,

    ANSI_NULLS ON;


	/* VARIABLE DECLARATIONS */
	DECLARE @ContainerNo			varchar(20),
		@CustKeys				varchar(max),
		@CSRKeys				varchar(max),
		@CSMKeys				varchar(max),
		@ContainerStatusKeys	varchar(max),	
		@HoldStatus				varchar(20)	,
		@HoldTypes				varchar(50)	,
		@TerminalNames			varchar(max),
		@TerminalCodes			varchar(max),
		@VesselIMOs				varchar(max),
		@SalesPersonKeys		varchar(max),
		@MarketKeys             varchar(max),
		@PickupAvailable		bit		,	
		@PickUpFrom             datetime  ,
        @PickUpTo               datetime  ,

		@CSRName				varchar(50),
		@PageNo					int,
		@PageSize				int,
		@SearchText				nvarchar(MAX),
		@SortField				varchar(50),
		@IsAscending			Bit = 1,
		@IsCTF					bit		,
		@IsTMF					bit		,
		@IsLine					bit		,
		@IsOther				bit		,	
		@IsCustoms				bit		,
		@IsFreight				bit		,
		@IsClosedArea			bit		,
		@isShowAll				BIT=1,
		@OutputType				Varchar(50),
		@StatusKey				INT=0,
		@OrderType				varchar(50),
		@Deliverylocationkeys	VARCHAR(100),
		@Tracking				VARCHAR(10),
		@SearchCriteriaKey		INT,
		@IsNormalSort			BIT = 1
	
	/* VALIDATIONS */
	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End
	
	/*GET PARAMETER VALUES */
	Select @ContainerNo = ContainerNo, @CustKeys = isnull(CustKeys,''),
		@CSRKeys = isnull(CSRKeys,''),  @ContainerStatusKeys = isnull(ContainerStatusKeys,''),
		@HoldStatus = isnull(HoldStatus,''), @TerminalNames = isnull(TerminalNames,''),
		@TerminalCodes = isnull(TerminalCodes,''), @HoldTypes = isnull(HoldTypes,''),
		@PickupAvailable = isnull(PickupAvailable,''), @VesselIMOs = isnull(VesselIMOs,''),
		@CSMKeys = isnull(CSMKeys,''), @SalesPersonKeys = isnull(SalesPersonKeys,''), @MarketKeys = ISNULL(MarketKeys,''),
		@PickUpFrom =isnull(PickUpFrom ,''), @PickUpTo = isnull(PickUpTo ,''),

		@PageNo = PageNo,  @PageSize =PageSize, 
		@SearchText = ltrim(rtrim(isnull(SearchText,''))), @SortField = SortField,
		@IsAscending = isnull(IsAscending,1), @OutputType = isnull(OutputType,''), 
		@StatusKey=ISNULL(StatusKey,0), @OrderType=ISNULL(OrderType,0),
		@Deliverylocationkeys=ISNULL(Deliverylocationkeys,''), @Tracking=ISNULL(Tracking,''),
		@SearchCriteriaKey = ISNULL(SearchCriteriaKey,0)
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo				varchar(20)		'$.ContainerNo',
		CSRKeys					varchar(max)	'$.CSRKeys',
		ContainerStatusKeys		varchar(max)	'$.ContainerStatusKeys',
		HoldStatus				varchar(max)	'$.HoldStatus',
		HoldTypes				varchar(50)		'$.HoldTypes',
		TerminalNames			varchar(max)	'$.TerminalNames',
		TerminalCodes			varchar(max)	'$.TerminalCodes',
		VesselIMOs				varchar(max)    '$.VesselIMOs',
		PickupAvailable			bit				'$.PickupAvailable',
		CustKeys				varchar(max)	'$.CustKeys',
		CSMKeys					varchar(max)	'$.CSMKeys',
		SalesPersonKeys			varchar(max)	'$.SalesPersonKeys',
		MarketKeys				varchar(max)    '$.MarketKeys',     
		PickUpFrom				datetime        '$.PickUpFrom', 
		PickUpTo				datetime        '$.PickUpTo', 

		PageNo					int				'$.PageNo',
		PageSize				int				'$.PageSize',
		SearchText				NVARCHAR(MAX)	'$.SearchText',
		SortField				varchar(50)		'$.SortField',
		IsAscending				bit				'$.IsAscending',
		OutputType				varchar(50)		'$.OutputType',
		StatusKey				varchar(50)		'$.StatusKey',
		OrderType				varchar(50)		'$.OrderType',
		Deliverylocationkeys	varchar(100)	'$.Deliverylocationkeys',
		Tracking				VARCHAR(100)	'$.Tracking',
		SearchCriteriaKey		INT				'$.SearchCriteriaKey'
	)
	
	/* PROCESS PARAMETER VALUES */

	SET @IsCTF = CASE WHEN @HoldTypes LIKE '%CTF%' THEN 1 ELSE 0 END 
	SET @IsTMF = CASE WHEN @HoldTypes LIKE '%TMF%' THEN 1 ELSE 0 END 
	SET @IsLine = CASE WHEN @HoldTypes LIKE '%LINE%' THEN 1 ELSE 0 END  
	SET	@IsOther = CASE WHEN @HoldTypes LIKE '%OTHER%' THEN 1 ELSE 0 END 
	SET @IsCustoms = CASE WHEN @HoldTypes LIKE '%CUSTOMS%' THEN 1 ELSE 0 END 
	SET @IsFreight = CASE WHEN @HoldTypes LIKE '%FREIGHT%' THEN 1 ELSE 0 END 
	SET @IsClosedArea = CASE WHEN @HoldTypes LIKE '%CLOSEDAREA%' THEN 1 ELSE 0 END 

	SET @StatusKey = Case when @StatusKey = 6 then 12 else @StatusKey end
	SET @StatusKey = Case when @StatusKey = 15 then 0 else @StatusKey end

	SET @IsNormalSort = case when @SortField in ('OrderNo')
		Then 1 else 0 end
	
	If(@IsDebug = 1)
	Begin
		Select @ContainerNo as ContainerNo , @CustKeys as CustKeys,
		@CSRKeys as CSRKeys,  @ContainerStatusKeys as ContainerStatusKeys,
		@HoldStatus as HoldStatus,  @TerminalNames as TerminalNames,
		@TerminalCodes  as TerminalCodes, @HoldTypes as HoldTypes,
		@PickupAvailable as PickupAvailable, @VesselIMOs as VesselIMOs,
		@CSMKeys as CSMKeys, @SalesPersonKeys as SalesPersonKeys, @MarketKeys as MarketKeys,
		@PickUpFrom as PickUpFrom, @PickUpTo as PickUpTo ,

		@PageNo  as PageNo,  @PageSize as PageSize , 
		@SearchText  as SearchText, @SortField  as SortField,
		@IsAscending as IsAscending, @OutputType as OutputType, 
		@StatusKey as StatusKey, 
		@Deliverylocationkeys as Deliverylocationkeys, @Tracking as Tracking,
		@IsCTF as IsCTF, @IsTMF as IsTMF, @IsLine as IsLine, @IsCustoms as IsCustoms, @IsOther as IsOther
		,@IsFreight AS IsFreight, @IsClosedArea AS ClosedArea, @SearchCriteriaKey AS SearchCriteriaKey
	END
	
	
	CREATE TABLE #CustKeys
	(
		CustKey		int,
		CustName	varchar(200)
	)
	IF(LEN(ISNULL(@CustKeys,'')) > 0)
	BEGIN
		insert into #CustKeys(CustName)
		select value from dbo.Fn_SplitParamCol(@CustKeys)

		Update CK set CustName =C.CustName
		from Customer C WITH (NOLOCK) 
		Inner join #CustKeys CK On C.CustKey = CK.CustKey
	END

	CREATE TABLE #CSRKeys
	(
		CSRKey		int,
		CSRName		varchar(100)
	)
	IF(LEN(ISNULL(@CSRKeys,'')) > 0)
	BEGIN
		insert into #CSRKeys(CSRName)
		select value from dbo.Fn_SplitParamCol(@CSRKeys)
	END

	CREATE TABLE #CSMKeys
	(
		CSMKey		int,
		CSMName		varchar(100)
	)
	IF(LEN(ISNULL(@CSMKeys,'')) > 0)
	BEGIN
		insert into #CSMKeys(CSMName)
		select value from dbo.Fn_SplitParamCol(@CSMKeys)

		Update A SET CSMKey = M.CsrKey
		From #CSMKeys A
		inner join CSR M WITH (NOLOCK) on A.CSMName = M.CsrName
	END

	--select * from #CSMKeys

	CREATE TABLE #SalesPersonKeys
	(
		SalesPersonKey		int
	)
	IF(LEN(ISNULL(@SalesPersonKeys,'')) > 0)
	BEGIN
		insert into #SalesPersonKeys(SalesPersonKey)
		select value from dbo.Fn_SplitParamCol(@SalesPersonKeys)
	END

	CREATE TABLE #ContainerStatusKeys
	(
		ContainerStatusKey		varchar(50)
	)
	IF(LEN(ISNULL(@ContainerStatusKeys,'')) > 0)
	BEGIN
		insert into #ContainerStatusKeys(ContainerStatusKey)
		select value from dbo.Fn_SplitParamCol(@ContainerStatusKeys)
	END

	CREATE TABLE #TerminalNames
	(
		TerminalName		varchar(100)
	)
	IF(LEN(ISNULL(@TerminalNames,'')) > 0)
	BEGIN
		insert into #TerminalNames(TerminalName)
		select value from dbo.Fn_SplitParamCol(@TerminalNames)
	END

	CREATE TABLE #TerminalCodes
	(
		TerminalCode		varchar(100)
	)
	IF(LEN(ISNULL(@TerminalCodes,'')) > 0)
	BEGIN
		insert into #TerminalCodes(TerminalCode)
		select value from dbo.Fn_SplitParamCol(@TerminalCodes)
	END

	CREATE TABLE #VesselIMOs
	(
		VesselIMO		varchar(100)
	)
	IF(LEN(ISNULL(@VesselIMOs,'')) > 0)
	BEGIN
		insert into #VesselIMOs(VesselIMO)
		select value from dbo.Fn_SplitParamCol(@VesselIMOs)
	END

	CREATE TABLE #MarketKeys
	(
	   MarketKey   int ,
	   MarketLocation		varchar(100)
	)
	IF(LEN(ISNULL(@MarketKeys,'')) > 0)
	BEGIN
	     INSERT INTO #MarketKeys(MarketLocation)
		 SELECT VALUE FROM Fn_SplitParamCol(@MarketKeys)

		 Update A SET MarketKey = M.MarketLocationKey
		From #MarketKeys A
		inner join MarketLocation M  WITH (NOLOCK) on A.MarketLocation = M.MarketLocation
	END
	CREATE TABLE #OrderTypeKeys
	(
		OrderTypeKey		int,
		OrderType		varchar(100)
	)
	IF(LEN(ISNULL(@OrderType,'')) > 0)
	BEGIN
		insert into #OrderTypeKeys(OrderType)
		select value from dbo.Fn_SplitParamCol(@OrderType)

		Update A SET OrderTypeKey = M.OrderTypeKey
		From #OrderTypeKeys A
		inner join OrderType M WITH (NOLOCK) on A.OrderType = M.OrderType
	END

	CREATE TABLE #DelieverLocationKeys
	(
		DeliverocationKey		varchar(200)
	)
	IF(LEN(ISNULL(@Deliverylocationkeys,'')) > 0)
	BEGIN
		insert into #DelieverLocationKeys(DeliverocationKey)
		select value from dbo.Fn_SplitParamCol(@Deliverylocationkeys)
	END
	create table  #CustData
	(
		UUID		varchar(50) Primary Key,
		DelLocCity	varchar(50)	,
		OrderCSR	varchar(50),
		DelLocState	varchar(50),
		BrokerRefNo	varchar(50),
		Customer	varchar(50),
		DelLocName	varchar(50)
	)

	insert into   #CustData (UUID, DelLocCity, OrderCSR, DelLocState, BrokerRefNo, Customer, DelLocName)
	SELECT UUID ,  
	  [Delivery Location City] as DelLocCity, 
		[Order CSR] as OrderCSR, [Delivery Location State] as DelLocState, 
		[Broker Ref No] as BrokerRefNo, [Customer],[Delivery Location Name] as DelLocName
	
	FROM  
	(
	  SELECT A.UUID, Field_name, Field_value
	  FROM Gnosis_Integration_ContainerCustomer_Final A WITH (NOLOCK)
	  --inner join Gnosis B on a.DataKey = b.DataKey
	) AS SourceTable  
	PIVOT  
	(  
	  max(Field_Value)
	  FOR Field_name IN ([Delivery Location City], 
		[Order CSR], [Delivery Location State], [Broker Ref No], [Customer],[Delivery Location Name])  
	) AS PivotTable;

	declare @OpenStatusKey smallint =0;

	select @OpenStatusKey = Status from OrderDetailStatus WITH (NOLOCK)	where [Description]  = 'Open'



	declare  @UserCount int = 0 

	select @UserCount = count(1)
	from (
	select LinkedUserKey from CSR WITH (NOLOCK)	 where LinkedUserKey is not null
	union all
	select LinkedUserKey from SalesPerson WITH (NOLOCK)	 where LinkedUserKey is not null
	) A where LinkedUserKey = @UserKey 

	if (@isShowAll =0)	select @isShowAll = case when isnull(@UserCount ,0) = 0 then 1 else 0 end

	Declare @RecCount	int, @RowNum int

	if(isnull(@SearchText,'') <> '')
	Begin
		SET @PickupFrom		='01/01/2020'
		SET @PickupTo		='01/12/2050'
	End

	/* SETUP FOR DATA FETCH  */

	create table #OrderDetailKeys
	(
		OrderDetailKey	int primary key
	)

	if(isnull(@SearchText,'') <> '')
	BEGIN
		IF(Charindex(',',@SearchText)=0)
		BEGIN
			Insert into #OrderDetailKeys
			select OrderDetailKey
			From OrderDetail OD WITH (NOLOCK)
			inner join OrderHeader OH WITH (NOLOCK) on OD.orderKey = OH.orderKey
			where ContainerNo like '%' + @SearchText + '%' OR 
					OrderNo like '%' + @SearchText + '%' OR 
					BillOfLading like '%' + @SearchText + '%' OR 
					ISNULL(OD.BookingNo,OH.BookingNo) like '%' + @SearchText + '%' OR
					BrokerRefNo LIKE '%' +@SearchText + '%'
		END
		ELSE
		Begin
			IF(@SearchCriteriaKey = 1)
			BEGIN
				INSERT INTO #OrderDetailKeys
					SELECT OrderDetailKey
					FROM OrderDetail OD WITH (NOLOCK)
					WHERE ContainerNo IN (SELECT VALUE FROM fn_splitparam(@SearchText))
			END		
			ELSE IF(@SearchCriteriaKey = 2)
			BEGIN
				INSERT INTO #OrderDetailKeys
					SELECT OrderDetailKey
					FROM OrderDetail OD WITH (NOLOCK)
					inner join OrderHeader OH WITH (NOLOCK) on OD.orderKey = OH.orderKey
					WHERE OrderNo IN (SELECT VALUE FROM fn_splitparam(@SearchText))
			END
			ELSE IF(@SearchCriteriaKey = 3)
			BEGIN
				INSERT INTO #OrderDetailKeys
					SELECT OrderDetailKey
					FROM OrderDetail OD WITH (NOLOCK)
					inner join OrderHeader OH WITH (NOLOCK) on OD.orderKey = OH.orderKey
					WHERE OD.BillOfLadding IN (SELECT VALUE FROM fn_splitparam(@SearchText))
						OR OH.BillOfLading IN (SELECT VALUE FROM fn_splitparam(@SearchText))
			END
			ELSE IF(@SearchCriteriaKey = 5)
			BEGIN
				INSERT INTO #OrderDetailKeys
					SELECT OrderDetailKey
					FROM OrderDetail OD WITH (NOLOCK)
					INNER JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
					WHERE OD.CustRefNo IN (SELECT VALUE FROM fn_splitparam(@SearchText))
						OR OH.BrokerRefNo IN (SELECT VALUE FROM fn_splitparam(@SearchText))
			END
			ELSE IF(@SearchCriteriaKey = 6)
			BEGIN
				INSERT INTO #OrderDetailKeys
					SELECT OrderDetailKey
					FROM OrderDetail OD WITH (NOLOCK)
					INNER JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
					WHERE ISNULL(OD.BookingNo,OH.BookingNo) IN (SELECT VALUE FROM fn_splitparam(@SearchText))
						OR OH.BrokerRefNo IN (SELECT VALUE FROM fn_splitparam(@SearchText))
			END
			ELSE
			BEGIN
				Insert into #OrderDetailKeys
				select OrderDetailKey
				From OrderDetail OD WITH (NOLOCK)
				inner join OrderHeader OH WITH (NOLOCK) on OD.orderKey = OH.orderKey
				where ContainerNo like '%' + @SearchText + '%' OR 
						OrderNo like '%' + @SearchText + '%' OR 
						BillOfLading like '%' + @SearchText + '%' OR 
						OH.BookingNo like '%' + @SearchText + '%' OR
						BrokerRefNo LIKE '%' +@SearchText + '%'
				--select * from #OrderDetailKeys
			END
		End	
	END
	ELSE
	BEGIN
		Insert into #OrderDetailKeys
		SELECT OrderDetailkey  FROM OrderDetail WITH (NOLOCK)
		WHERE status IN (1,2,3,7,9,6,12,14)
	END
	

	set @KeyFetchStart = sysutcdatetime()
	if(@IsDebug=1)
	BEGIN
		SELECT '#OrderDetailKeys', @SearchCriteriaKey as SearchCriteriaKey, * FROM #OrderDetailKeys
		print 'StartTime - Key Fetch'
		print convert(varchar,@KeyFetchStart ) 
	END
	print '@IsNormalSort'
	print @IsNormalSort

	DECLARE @IsSearchMode bit =
    CASE WHEN ISNULL(@SearchText,'') = '' THEN 0 ELSE 1 END;

--SET STATISTICS IO, TIME ON;
	
	select Od.orderdetailkey, OH.orderKey, OD.Status, OH.orderNo,
	CONVERT(biT, 0) AS IsDataRequired 
	into #RequiredRecords
	FROM  #OrderDetailKeys OD1					WITH (NOLOCK)	
			INNER JOIN dbo.OrderDetail OD			WITH (NOLOCK)	ON OD.OrderDetailkey = OD1.OrderDetailkey
			INNER JOIN dbo.OrderHeader OH			WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
			INNER JOIN dbo.OrderStatus OS			WITH (NOLOCK)	ON OS.[Status]=OH.[Status]
			LEFT JOIN dbo.[Broker]  BR				WITH (NOLOCK)	ON BR.BrokerKey=OH.BrokerKey
			INNER JOIN  dbo.OrderDetailStatus OSD	WITH (NOLOCK)	ON OSD.[Status] = OD.[Status]
			LEFT JOIN dbo.ContainerSize CS			WITH (NOLOCK)	ON CS.ContainerSizeKey = OD.ContainerSizeKey
			LEFT JOIN DBO.Customer CU				WITH (NOLOCK)	ON OH.CustKey = CU.CustKey
			LEFT JOIN dbo.CSR CR					WITH (NOLOCK)	ON CR.CsrKey= ISNULL(OD.CsrKey, OH.CSRKey)
			LEFT JOIN  dbo.OrderType OT				WITH (NOLOCK)	ON OT.OrderTypeKey = OH.OrdertypeKey 
			LEFT JOIN  dbo.OrderType OTD			WITH (NOLOCK)	ON OTD.OrderTypeKey = OD.OrdertypeKey 
			LEFT join Routes RT						WITH (NOLOCK)	ON OD.CurrentRouteKey = Rt.RouteKey
			OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODSI WITH (NOLOCK)
						WHERE ODSI.OrderDetailKey=OD.OrderDetailKey AND ODSI.StopTypeKey=1 AND ISNULL(ODSI.IsDryrunPort,0)=0
						ORDER BY ODSI.StopNumber ASC
						)ODS
			LEFT JOIN [Address] SR					WITH (NOLOCK)	ON SR.AddrKey=ODS.StopAddrKey
			LEFT JOIN [Address] DT					WITH (NOLOCK)	ON DT.AddrKey=isnull(OD.DestinationAddrKey, OH.DestinationAddrKey)
			LEFT JOIN [Address] BT					WITH (NOLOCK)	ON BT.AddrKey=OH.BillToAddrKey
			LEFT JOIN [Address] RET					WITH (NOLOCK)	ON RET.AddrKey=OH.ReturnAddrKey
			LEFT JOIN ADDRESS CSR					WITH (NOLOCK)	ON RT.SourceAddrKey = CSR.AddrKey
			OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODSDI WITH (NOLOCK)
						WHERE ODSDI.OrderDetailKey=OD.OrderDetailKey AND ODSDI.StopTypeKey=3 AND ISNULL(ODSDI.IsDryrunCustomer,0)=0
						ORDER BY ODSDI.StopNumber ASC
						)ODSD
			LEFT JOIN ADDRESS CDT					WITH (NOLOCK)	ON ODSD.StopAddrKey = CDT.AddrKey
			LEFT JOIN  dbo.[Priority] PT			WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
			LEFT Join DBO.[User] UU					WITH (NOLOCK)	ON OD.CreateUserKey = uu.UserKey
			LEft join ContainerTypesLink CT				WITH (NOLOCK) on CT.OrderDetailKey = OD.OrderDetailKey and ct.ContainerTypeKey = 6 --and Ct.TypeID = 'Transload'
			LEft join Address RA					with (nolock) on RT.DestinationAddrKey = RA.AddrKey
			LEFT join Leg L							WITH (NOLOCK) ON RT.LegKey = l.LegKey
			LEFT JOIN ADDRESS RP					WITH (NOLOCK) ON RT.SourceAddrKey = RP.AddrKey
			LEFT JOIN ContainerTypesLink HZ				WITH (NOLOCK) ON HZ.OrderDetailKey = OD.OrderDetailKey and HZ.ContainerTypeKey = 1 --AND HZ.TypeID = 'Hazard'
			LEFT JOIN ContainerDocumentCount CDC	WITH (NOLOCK)	ON OD.OrderDetailKey = CDC.OrderDetailKey
			LEft join Int_ContainerAvailability B	with (NOLOCK) on OD.OrderDetailkey  = B.OrderDetailKey
			lEFT jOIN [USER] u2						WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey
			LEft Join CSR CM						WITH (NOLOCK) ON CM.CsrKey = isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey)
			LEFT JOIN SalesPerson SP				WITH (NOLOCK) ON SP.SalesPersonKey =  ISNULL( OH.SalesPersonKey, CU.SalesPersonKey)
			LEFT JOIN MarketLocation ML				WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
			LEFT JOIN SteamShipLine SL				WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey
			LEFT JOIN Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
											AND OD.ContainerNo+'_'+oh.BillofLading=GICF.Container_Journey_start_key
			LEFT JOIN PUScheduleDelayCode PDC		WITH (NOLOCK) ON PDC.CodeKey=PUDelayedCodeKEy
			LEFT JOIN PrePullReasonCodes PPDC	WITH (NOLOCK) ON PPDC.CodeKey=PrepullDelayedCodeKEy
			LEFT JOIN		#CustData C on C.UUID = GICF.UUID
			LEFT JOIN		Gnosis_Integration_Holds_Final H  WITH (NOLOCK) ON C.UUID = H.UUID
			LEFT JOIN WeighUnit WU WITH (NOLOCK) ON WU.WeightUnitKey = OD.WeightUnit
			LEFT JOIN Gnosis_VContainerTrackingToDisplay GVTD WITH (NOLOCK) ON (GVTD.OrderDetailKey=OD.OrderDetailKey)
								AND OD.ContainerNo+'_'+oh.BillofLading=GVTD.ContainerNo+'_'+GVTD.MBL
			OUTER APPLY (
						SELECT TOP 1 *
						FROM Container_GnosisData CGDI WITH (NOLOCK)
						WHERE CGDI.OrderDetailKey=OD.OrderDetailKey 
						)CGD
	where  
	(
		@IsSearchMode = 1
	)
	OR
	(
		@IsSearchMode = 0 AND 
		(
			1=1
			-- Pickup availability
			AND (isnull(@PickupAvailable,0) = 0 OR Isnull(CGD.Available , GICF.Available_for_pickup) = @PickupAvailable)
			AND (@IsCTF = 0 OR CTF = 'true')
			AND (@IsTMF = 0 OR TMF = 'true')
			AND (@IsLine = 0 OR Line = 'true')
			AND (@IsOther = 0 OR Other = 'true')
			AND (@IsCustoms = 0 OR Customs = 'true')
			AND (@IsFreight = 0 OR Freight = 'true')
			AND (@IsClosedArea = 0 OR ClosedArea = 'true')
			AND (
				isnull(@TerminalNames,'') = ''
				OR EXISTS (
					SELECT 1
					FROM #TerminalNames TN
					WHERE TN.TerminalName = Pod_terminal_name
				)
			)
			AND (
				Isnull(@CustKeys,'') = ''
				OR EXISTS (
					SELECT 1 FROM #CustKeys CK
					WHERE CK.CustKey = OH.custKey
				)
			)
			AND (
				ISNULL(@CSRKeys,'') = ''
				OR EXISTS (
					SELECT 1 FROM #CSRKeys CS
					WHERE CS.CSRKey = OH.CsrKey
				)
			)
			
			AND (
				Isnull(@MarketKeys,'') = ''
				OR EXISTS (
					SELECT 1 FROM #MarketKeys MK
					WHERE MK.MarketKey = OH.MarketLocationKey
				)
			)
			AND (
				ISNULL(@PickUpFrom,'') =''
				OR Pickup_appointment_dt >= @PickUpFrom
			)
			AND (
				ISNULL(@PickUpTo,'') ='' 
				OR Pickup_appointment_dt <= @PickUpTo
			)
			AND (
				ISNULL(@Tracking,'')=''
				OR (
					@Tracking = 'Yes' AND GICF.OrderDetailKey IS NOT NULL
				)
				OR (
					@Tracking = 'No' AND GICF.OrderDetailKey IS NULL
				)
			)
			AND (
				ISNULL(@Deliverylocationkeys,'')=''
				OR EXISTS (
					SELECT 1
					FROM #DelieverLocationKeys DL
					WHERE DL.DeliverocationKey = LTRIM(RTRIM(CDT.AddrName))
				)
			)
			AND (
				isnull(@OrderType,'') = '' 
				OR COALESCE(OD.OrderTypeKey, OH.OrderTypeKey) IN
					(SELECT OrderTypeKey FROM #OrderTypeKeys)
			)
		)
	)
	OPTION (RECOMPILE);

	--SET STATISTICS IO, TIME Off;

		set @KeyFetchEnd = sysutcdatetime()
		set @DataFetchStrt = sysutcdatetime()

		if(isnull(@SearchText,'') <>'')
		Begin
			update #RequiredRecords set IsDataRequired = 1 
		END
		ELSE
		Begin
			update #RequiredRecords set IsDataRequired = 1 where (  Status = @StatusKey)
		End

		if(@IsDebug = 1)
		begin
			print 'End Time - Key Fetch'
			print convert(varchar,@KeyFetchEnd ) 
			
			select * from #RequiredRecords
			select Status, count(1) from #RequiredRecords group by Status order by status

			print 'StartTime - Data Fetch'
			print convert(varchar, @DataFetchStrt)
			
		end
		
		Declare @STRSQL nvarchar(max) = '',
				@StartRowNum	int ,
				@EndRowNum		INT 
				
		SET @StartRowNum = ((@PageNo - 1)  * @PageSize) +1
		SET @EndRowNum =  (@PageNo * @PageSize)
		print '@StartRowNum' 
		Print @StartRowNum
		print '@EndRowNum'
		print @EndRowNum

		select *, convert(int, 0) as RowNum into #FinalRecords from #RequiredRecords where 1=0

		IF(@IsNormalSort = 1 and isnull(@SearchText,'') = '')
		BEGIN
			insert into #FinalRecords
			SELECT *
			FROM (
				SELECT
					RR.*,
					ROW_NUMBER() OVER (ORDER BY [OrderNo] ASC) AS RowNum
				FROM #RequiredRecords RR
				where IsDataRequired = 1
			) X
			WHERE RowNum >= @StartRowNum
			  AND RowNum <= @EndRowNum
		END
		ELSE
		Begin
			insert into #FinalRecords
			Select *,1  from #RequiredRecords
		End

--SET STATISTICS IO, TIME ON;

		SELECT
			isnull(OH.OrderKey,0) OrderKey,
			isnull(OH.OrderDate,'1900-01-01') as OrderDate,
			isnull(OD.OrderDetailkey,0) as OrderDetailkey,
			COALESCE(OD.OrderTypeKey, OH.OrderTypeKey, 0) as OrderTypeKey,
			isnull(OH.OrderNo,'') as OrderNo,
			isnull(OD.ContainerNo,'') as ContainerNo,
			isnull(OD.ContainerID, '') as ContainerID,
			isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,
			CONVERT(DATETIME, ISNULL(ISNULL(CGD.LFD, OD.LastFreeDay), '1900-01-01')) AS LastFreeDay,

			ODS.SchedulePickupDate AS PickupDate ,
			CONVERT(VARCHAR(10), CAST(ODS.SchedulePickupDate AS TIME), 0) PickupTime,		
			ODSD.ScheduleDeliveryDate AS DropOffDate,
			CONVERT(VARCHAR(10), CAST(ODSD.ScheduleDeliveryDate AS TIME), 0) DropOffTime,	

			isnull(OSD.[Description],'') AS [Status],
			Case   when OD.Status = 6 then 12
				when OD.Status =14 then 12 else OD.Status  end as StatusKey,
			COALESCE(OTD.OrderType,OT.OrderType, '') AS OrderType,
			isnull(OD.BillOfLadding,OH.BillOfLading) AS BillOfLading,
			isnull(OD.BookingNo,'') AS BookingNo,
			isnull(OD.CustRefNo ,OH.BrokerRefNo) as BrokerRefNo,
			isnull(CS.[Description],'') AS ContainerSize,
			isnull(PT.[Description],'')  AS [Priority],
			ChassisNo=(SELECT TOP 1 ChassisNo FROM [Routes] RTI WITH (NOLOCK) WHERE RTI.OrderDetailKey=OD.OrderDetailKey ORDER BY RouteKey DESC),
			
			SR.AddrName AS S_AddrName,
			SR.Address1 AS S_Address1,
			SR.City  AS S_City,
			SR.[State]  AS S_State,
			SR.ZipCode  AS S_ZipCode,
			SR.Country  AS S_Country,

			SR.AddrName AS Source_AddrName,
			SR.Address1 AS Source_Address1,
			SR.City  AS Source_City,
			SR.[State]  AS Source_State,
			SR.ZipCode  AS Source_ZipCode,
			SR.Country  AS Source_Country,

			CDT.AddrName  AS D_AddrName,
			CDT.Address1  AS D_Address1,
			CDT.City  AS D_City,
			CDT.[State]  AS D_State,
			CDT.ZipCode AS D_ZipCode,
			CDT.Country  AS D_Country,			

			CDT.AddrName  AS Destination_AddrName,
			CDT.Address1  AS Destination_Address1,
			CDT.City  AS Destination_City,
			CDT.[State]  AS Destination_State,
			CDT.ZipCode  AS Destination_ZipCode,
			CDT.Country  AS Destination_Country,

			isnull(BT.AddrName,'')  AS B_AddrName,
			isnull(BT.Address1,'')  AS B_Address1,
			isnull(BT.City,'')  AS B_City,
			isnull(BT.[State],'')  AS B_State,
			isnull(BT.ZipCode,'')  AS B_ZipCode,
			isnull(BT.Country,'')  AS B_Country,
			isnull(RET.AddrName,'') AS R_AddrName,
			isnull(RET.Address1,'') AS R_Address1,
			isnull(RET.City,'') AS R_City,
			isnull(RET.[State],'') AS R_State,
			isnull(RET.ZipCode,'') AS R_ZipCode,
			isnull(RET.Country,'') AS R_Country,	

			CAST(ISNULL(ISNULL(CGD.ETA_ATA,OD.VesselETA),'1900-01-01')AS DATETIME) AS VesselETA,
			isnull(OD.IsLinked,0) AS IsLinked,
			isnull(OD.LinkedContainerNo,'') AS LinkedContainerNo,
			CASE 
				WHEN OD.status = 1 THEN 'Proceed to Schedule' 
				WHEN OD.status = 3 THEN 'Complete Schedule'          
				WHEN OD.status = 4 THEN 'Confirm/Complete Schedule' 
				WHEN OD.status = 5 THEN 'Process Dispatch' 
				WHEN OD.status = 7 THEN 'Complete Dispatch'   
				WHEN OD.status = 8 THEN 'Confirm/Complete Dispatch'  
				WHEN OD.status = 9 THEN 'Approve Invoice/Driver Pay'  
				WHEN OD.status = 10 THEN 'Closed' 
				WHEN OD.status = 6 THEN 'Approve for Invoice/Driver Pay' 
				WHEN OD.status = 2 THEN 'Proceed to Dispatch'
				END AS NextAction,
			OH.custKey,BR.BrokerName,OH.OrderSource,OD.[Weight],WU.WeightUnit,OH.VesselName,OD.SealNo,OD.CutOffDate 
			, isnull(OD.IsEmpty,0) as IsEmpty
			, OD.DriverNotes , OD.SchedulerNotes
			, isnull(OD.IsTMF,0) as IsTMF
			, case when ISNULL(Ct.ContainerTypeKey,0) = 0 then 0 else 1 end  as isTransLoad 
			, isnull(CU.CustName,'''') as  CustName,
			isnull(CU.CustID,'''') as CustID,
			ISNULL(UU.UserName,'''') AS CreatedUser,
			CAST(ISNULL(od.CurrentLegNo,0) AS VARCHAR(10))+' [ ' + ISNULL(CAST(od.CurrentLegNo AS VARCHAR(10)),0)+ ' of '+ CAST(od.TotalLegs AS VARCHAR(10))+' ]' AS CurLeg,
			l.FromLocation  AS LocationType ,
			RA.AddrName AS CurLocation, RT.RouteKey, RP.AddrName, 
			case when ISNULL(Hz.ContainerTypeKey,0) = 0 then 0 else 1 end AS IsHazardous,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			B.LastFreeDay as  Int_LFD, convert(bit, case when isnull(B.OrderDetailKey,0) = 0 then 0 else 1 end) as IntDataExists ,
			od.CompleteDate as TerminationDate,
			od.isStreetTurn,
			ISNULL(u2.UserName,'') AS StreetTurnSetUser,
			OD.StreetTurnSetDate,
			CR.CsrKey,
			CM.CsrKey AS CSManagerKey,
			SP.LinkedUserKey as SalePersonKey,
			isnull(CR.CsrName,'') as CsrName,
			isnull(CM.CsrName,'') as CSManagerName,
			isnull(OH.CSRManagerKey ,CM.CsrKey) as CSRManagerKey,
			isnull(SP.SalesPersonName,'') as SalesPersonName,
			CR.LinkedUserKey AS CSRUser, CM.LinkedUserKey AS CMUser, SP.LinkedUserKey AS SPUser, 
			ISNULL(ML.MarketLocationKey,0) MarketLocationKey
			, ISNULL(ML.MarketLocation,'') MarketLocation
			, ISNULL(OD.Consignee,OH.Consignee) Consignee, SL.LineName AS SteamShipLine, OH.SenderInfo,
			GICF.Ocean_carrier_scac AS SCAC, GICF.Discharged_dt AS Dischargedate, 
			GICF.HoldStatus,'' LiveDrop,
			
			Stuff((SELECT ', ' + PUD.Code
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPURC
			 INNER JOIN PUScheduleDelayCode PUD WITH (NOLOCK) ON (PUD.CodeKey=ODPURC.PUScheduleRCKey)
			   WHERE OD.OrderDetailKey = ODPURC.OrderDetailKey 
			 FOR XML PATH('')),1,1,'') AS DelayReasonCode,
			 
			OD.PUDelayedCodeKey,
			ISNULL(CGD.Available,GICF.Available_for_pickup) AS AvailableforPickup,
			COALESCE(CGD.AvailableDate, GICF.Available_dt,GICF.Discharged_dt) AS AvailableforPickupDate,
			CAST(0 AS BIT) IsEditDelayReasonCode,
			OD.PrepullDelayedCodeKEy,
			--PPDC.Code AS PrepullDelayedCode,
			Stuff((SELECT ', ' + PPR.Code
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPPRC
			 INNER JOIN PrePullReasonCodes PPR  WITH (NOLOCK) ON (PPR.CodeKey=ODPPRC.PrepullRCKey)
			   WHERE OD.OrderDetailKey = ODPPRC.OrderDetailKey 
			 FOR XML PATH('')),1,1,'') AS PrepullDelayedCode,

			 
			CAST(0 AS BIT) IsEditPrepullReasonCode,
			
			Location_at_terminal,
			CASE WHEN ISNULL(GICF.OrderDetailKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS [Tracking],
			CASE WHEN Is_railing = 'true' THEN GICF.Rail_terminal ELSE GICF.Pod_terminal_name END Pod_terminal_name,
			H.CTF, H.Customs, H.Line, H.Other, H.TMF,H.Freight, H.ClosedArea,
			HoldType= (case when isnull(H.CTF,'') = 'true' then 'CTF;' else '' END )+
					(case when isnull(H.TMF,'') = 'true' then 'TMF;' else '' END )+
					(case when isnull(H.Customs,'') = 'true' then 'Customs;' else '' END )+
					(case when isnull(H.Line,'') = 'true' then 'Line;' else '' END )+
					(case when isnull(H.Other,'') = 'true' then 'Other;' else '' END )+
					(case when isnull(H.Freight	,'') = 'true' then 'Freight	;' else '' END )+
					(case when isnull(H.ClosedArea,'') = 'true' then 'ClosedArea;' else '' END )
					,
			CU.CustName as Customer,
			CR.CsrName as OrderCSR,
			OH.SalesPersonKey,
			Isnull(GICF.Pickup_appointment_dt,RT.ScheduledDeparture) as Pickup_appointment_dt,
			ISNULL(ISNULL(CR.LinkedUserKey, CM.LinkedUserKey),   SP.LinkedUserKey) as LinkedUserKey,
			ISNULL(CDT.AddrKey,DT.AddrKey) as DeliveryLocationKey
			, ISNULL(GVTD.Remarks,'N/A') As NoTrackingRemarks,
			 
			PrepullRCKeys=(Stuff((SELECT ', ' + CAST(ODPPRC.PrepullRCKey AS VARCHAR)
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPPRC WITH (NOLOCK)
			   WHERE OD.OrderDetailKey = ODPPRC.OrderDetailKey 
			 FOR XML PATH('')),1,2,'')),
			 
			 Stuff((SELECT ', ' + CAST(ODPURC.PUScheduleRCKey AS VARCHAR)
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPURC  WITH (NOLOCK)
			   WHERE OD.OrderDetailKey = ODPURC.OrderDetailKey 
			 FOR XML PATH('')),1,2,'') AS PUDealyedRCKeys,

			 convert(bit, 0) as IsDataSelected,
			 convert(bit,0) as IsSelectedStatusKey,

			ROW_Number() Over(ORDER BY OD.OrderDetailKey) as ID,
			Stuff((SELECT ', ' + CAST(CTI.ShortCode AS VARCHAR)
			FROM ContainerTypesLink CTL WITH (NOLOCK)
			inner join ContainerTypes CTI WITH (NOLOCK) on CTL.ContainerTypeKey = CTI.ContainerTypeKey
			  WHERE CTL.OrderDetailKey = OD.OrderDetailKey 
			FOR XML PATH('')),1,2,'') AS ContainerProps,
			Stuff((SELECT ', ' + CAST(CTI.ColorCode AS VARCHAR)
			FROM ContainerTypesLink CTL WITH (NOLOCK)
			inner join ContainerTypes CTI WITH (NOLOCK) on CTL.ContainerTypeKey = CTI.ContainerTypeKey
			  WHERE CTL.OrderDetailKey = OD.OrderDetailKey 
			FOR XML PATH('')),1,2,'') AS ColorCode,
			 ISNULL(AvailableT,0) AvailableT,ISNULL(ScheduleT,'') ScheduleT,
			 ISNULL(DemCheck,0) DemCheck,ISNULL(Issues,0) AS Issues,
			 ISNULL(ETA_ATAChangedByUser,0)ETA_ATAChangedByUser,
			ISNULL(LFDChangedByUser,0) LFDChangedByUser, 

			CASE WHEN ISNULL(CGD.OrderDetailKey,0)=0 THEN CAST(0 AS BIT)  ELSE CAST(1 AS BIT) END  IsGnosisTracking ,
			IsChargesApproved = CASE WHEN ((SELECT COUNT(1) FROM OrderExpense WHERE OrderDetailKey=OD1.OrderDetailKey AND isCSRApproved=0 )>0 
											AND (SELECT COUNT(1) FROM Invoicedetail WHERE OrderDetailKey=OD1.OrderDetailKey)=0)
								   THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END,
			ISNULL(OnSiteSent,0) AS OnSiteSent,
			ISNULL(PODSent,0) AS PODSent
		into #TempAll
		FROM  #FinalRecords OD1					WITH (NOLOCK)	
			INNER JOIN dbo.OrderDetail OD			WITH (NOLOCK)	ON OD.OrderDetailkey = OD1.OrderDetailkey
			INNER JOIN dbo.OrderHeader OH			WITH (NOLOCK)	ON OH.OrderKey=OD.OrderKey
			INNER JOIN dbo.OrderStatus OS			WITH (NOLOCK)	ON OS.[Status]=OH.[Status]
			LEFT JOIN dbo.[Broker]  BR				WITH (NOLOCK)	ON BR.BrokerKey=OH.BrokerKey
			INNER JOIN  dbo.OrderDetailStatus OSD	WITH (NOLOCK)	ON OSD.[Status] = OD.[Status]
			LEFT JOIN dbo.ContainerSize CS			WITH (NOLOCK)	ON CS.ContainerSizeKey = OD.ContainerSizeKey
			LEFT JOIN DBO.Customer CU				WITH (NOLOCK)	ON OH.CustKey = CU.CustKey
			LEFT JOIN dbo.CSR CR					WITH (NOLOCK)	ON CR.CsrKey= ISNULL(OD.CsrKey, OH.CSRKey)
			LEFT JOIN  dbo.OrderType OT				WITH (NOLOCK)	ON OT.OrderTypeKey = OH.OrdertypeKey 
			LEFT JOIN  dbo.OrderType OTD			WITH (NOLOCK)	ON OTD.OrderTypeKey = OD.OrdertypeKey 
			LEFT join Routes RT						WITH (NOLOCK)	ON OD.CurrentRouteKey = Rt.RouteKey
			OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODSI WITH (NOLOCK)
						WHERE ODSI.OrderDetailKey=OD.OrderDetailKey AND ODSI.StopTypeKey=1 AND ISNULL(ODSI.IsDryrunPort,0)=0
						ORDER BY ODSI.StopNumber ASC
						)ODS
			--LEFT JOIN [Address] SR					WITH (NOLOCK)	ON SR.AddrKey=isnull(OD.SourceAddrKey, OH.SourceAddrKey)
			LEFT JOIN [Address] SR					WITH (NOLOCK)	ON SR.AddrKey=ODS.StopAddrKey
			LEFT JOIN [Address] DT					WITH (NOLOCK)	ON DT.AddrKey=isnull(OD.DestinationAddrKey, OH.DestinationAddrKey)
			LEFT JOIN [Address] BT					WITH (NOLOCK)	ON BT.AddrKey=OH.BillToAddrKey
			LEFT JOIN [Address] RET					WITH (NOLOCK)	ON RET.AddrKey=OH.ReturnAddrKey
			LEFT JOIN ADDRESS CSR					WITH (NOLOCK)	ON RT.SourceAddrKey = CSR.AddrKey
			OUTER APPLY (
						SELECT TOP 1 *
						FROM OrderDetailStops ODSDI WITH (NOLOCK)
						WHERE ODSDI.OrderDetailKey=OD.OrderDetailKey AND ODSDI.StopTypeKey=3 AND ISNULL(ODSDI.IsDryrunCustomer,0)=0
						ORDER BY ODSDI.StopNumber ASC
						)ODSD
			LEFT JOIN ADDRESS CDT					WITH (NOLOCK)	ON ODSD.StopAddrKey = CDT.AddrKey
			LEFT JOIN  dbo.[Priority] PT			WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
			LEFT Join DBO.[User] UU					WITH (NOLOCK)	ON OD.CreateUserKey = uu.UserKey
			LEft join ContainerTypesLink CT				WITH (NOLOCK) on CT.OrderDetailKey = OD.OrderDetailKey and ct.ContainerTypeKey = 6 --and Ct.TypeID = 'Transload'
			LEft join Address RA					with (nolock) on RT.DestinationAddrKey = RA.AddrKey
			LEFT join Leg L							WITH (NOLOCK) ON RT.LegKey = l.LegKey
			LEFT JOIN ADDRESS RP					WITH (NOLOCK) ON RT.SourceAddrKey = RP.AddrKey
			LEFT JOIN ContainerTypesLink HZ				WITH (NOLOCK) ON HZ.OrderDetailKey = OD.OrderDetailKey and HZ.ContainerTypeKey = 1 --AND HZ.TypeID = 'Hazard'
			LEFT JOIN ContainerDocumentCount CDC	WITH (NOLOCK)	ON OD.OrderDetailKey = CDC.OrderDetailKey
			LEft join Int_ContainerAvailability B	with (NOLOCK) on OD.OrderDetailkey  = B.OrderDetailKey
			lEFT jOIN [USER] u2						WITH (NOLOCK) ON OD.StreetTurnSetUser = U2.UserKey
			LEft Join CSR CM						WITH (NOLOCK) ON CM.CsrKey = isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey)
			LEFT JOIN SalesPerson SP				WITH (NOLOCK) ON SP.SalesPersonKey =  ISNULL( OH.SalesPersonKey, CU.SalesPersonKey)
			LEFT JOIN MarketLocation ML				WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
			LEFT JOIN SteamShipLine SL				WITH(NOLOCK) ON SL.LineKey = OH.SteamShipLinekey
			LEFT JOIN Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
											AND OD.ContainerNo+'_'+oh.BillofLading=GICF.Container_Journey_start_key
			LEFT JOIN PUScheduleDelayCode PDC		WITH (NOLOCK) ON PDC.CodeKey=PUDelayedCodeKEy
			LEFT JOIN PrePullReasonCodes PPDC	WITH (NOLOCK) ON PPDC.CodeKey=PrepullDelayedCodeKEy
			LEFT JOIN		#CustData C on C.UUID = GICF.UUID
			LEFT JOIN		Gnosis_Integration_Holds_Final H  WITH (NOLOCK) ON C.UUID = H.UUID
			LEFT JOIN WeighUnit WU WITH (NOLOCK) ON WU.WeightUnitKey = OD.WeightUnit
			LEFT JOIN Gnosis_VContainerTrackingToDisplay GVTD WITH (NOLOCK) ON (GVTD.OrderDetailKey=OD.OrderDetailKey)
								AND OD.ContainerNo+'_'+oh.BillofLading=GVTD.ContainerNo+'_'+GVTD.MBL
			OUTER APPLY (
						SELECT TOP 1 *
						FROM Container_GnosisData CGDI WITH (NOLOCK)
						WHERE CGDI.OrderDetailKey=OD.OrderDetailKey 
						)CGD
			WHERE OD1.IsDataRequired = 1
			OPTION (RECOMPILE, MAXDOP 1);
--SET STATISTICS IO, TIME Off;


		----WHERE   
			--(ISNULL(@SearchText,'') = '' and OD.status in (1,2,3,7,9,6,12,14) ) OR 
			--(ISNULL(@SearchText,'') = ''  ) OR 
				--( (ISNULL(@SearchText,'') <> '' and od.OrderDetailKey = ODK.OrderDetailKey))

		set @DataFetchEnd = sysutcdatetime()
		SET @DataProcessStart = sysutcdatetime()
		if(@IsDebug = 1)
		Begin
			print 'End Time - Data Fetch'
			print convert(varchar,@DataFetchEnd )
			SELECT '#RequiredRecords', count(1) from #RequiredRecords
			select '#TempAll', count(1) from #TempAll
			select @SearchText as SearchText

			print 'StartTime - Data Process'
			print convert(varchar,@DataProcessStart )

		end
		
		
		if(@IsDebug = 1)
		Begin
			select @SearchText as SearchText
		end
		
		update #RequiredRecords set Status = 12 where status in (12,14)

		select distinct status, count(1) as cnt 
		INTO #Status
		from #RequiredRecords
		group by Status
		order by status

		--Select T.Status,T.StatusKey, count(1) as cnt 
		--INTO #Status
		--from  #TempAll T
		--where IsDataSelected = 1
		--group by T.Status,T.StatusKey

		Select ODS.Status as Statuskey, ODS.Description , isnull(cnt,0) as ContainerCount
		into #DashBoard
		from OrderDetailStatus ODS WITH (NOLOCK)	
		Left join #Status T on ODS.Status = T.Status
		where  ODS.status in (1,2,3,6,7,9,12,14)
		
		update #DashBoard set Description = 'Complete' where Statuskey = 12

		insert into #DashBoard (Statuskey,Description, ContainerCount)
		select 0, 'Total Containers', sum(Containercount) from #DashBoard

		if(@IsDebug = 1)
		Begin
			SELECT 1
			Select '#Status',* from #Status  
			select @SearchText as SearchText
		end

		

		/* REMOVED AS PER INSTRUCTION FROM KATHRYN ON 30/09/2024 
		declare @CompleteCount	int,
				@CSCount		int
		SElect @CSCount = ConfigValue1 from AppConfig where ConfigId = 72
		
		update #DashBoard SET ContainerCount = @CSCount where StatusKey = 9
		*/
		

		--update #TempAll set IsDataSelected = 1 where StatusKey = @StatusKey
		
		 
		if(@IsDebug = 1)
		Begin
			select '#DashBoard', * from #DashBoard
			select '#TempDashboard',count(1) from #TempAll --where IsDataSelected = 1
			--select * from #TempPrev where isnull(HoldType ,'') <> ''
		End
		
		create table #tmpStatusKeys 
		(
			StatusKey INT
		)

		INSERT INTO #tmpStatusKeys
		SELECT @StatusKey
		IF(@StatusKey=1)
		BEGIN
			INSERT INTO #tmpStatusKeys
			SELECT 3
		END

		/*
		update #TempAll set IsSelectedStatusKey = 1
		where IsDataSelected = 1 and ((ISNULL(@SearchText,'') <>'' AND @StatusKey = 0) OR 
			(StatusKey in (1,2,3,6,7,9,12,14) and 
				(isnull(@statusKey,0) = 0 OR  StatusKey in (SELECT StatusKey from #tmpStatusKeys))))
		*/
		set @dataProcessEnd = sysutcdatetime()
		set @DataSendStart = sysutcdatetime()
		if(@IsDebug = 1)
		Begin
			print 'End Time - Data Process'
			print convert(varchar,@dataProcessEnd )
			--select '#Temp', count(1) from #TempAll where IsSelectedStatusKey = 1
			select '#Temp', count(1) from #TempAll --where IsDataSelected = 1
			print 'Start Time - Data Send'
			print convert(varchar,@DataSendStart )
		End

		select ID, convert(int, 0) as RowNum into  #FinalData_Temp from #TempAll WHERE 1 <> 1 
		
		if(@IsNormalSort = 0)
		Begin
			SET @STRSQL = N'
			SELECT ID, RowNum
			FROM (
				SELECT
					ID,
					ROW_NUMBER() OVER (ORDER BY ' + QUOTENAME(@SortField) + ' ' +
						CASE WHEN @IsAscending = 0 THEN 'DESC' ELSE 'ASC' END + ') AS RowNum
				FROM #TempAll
			) X
			WHERE RowNum >= ' + convert(varchar,  @StartRowNum ) + '
			  AND RowNum <= ' + convert(varchar, @EndRowNum) + ';';
			print @STRSQL

			

			insert into #FinalData_Temp (ID, RowNum)
			EXEC sp_executesql
				@STRSQL
		end
		else
		begin
			insert into #FinalData_Temp(ID, RowNum)
			select ID, ROW_NUMBER() Over (Order By Orderno ASC) from #TempAll
		end

		--select * into Schedulert_Temp_Praveen FROM #FinalData_Temp

		if(@IsDebug = 1)
		Begin
			select '#FinalData_Temp', * from #FinalData_Temp
		End

		declare @RecFrom int, @RecTo  int
		Select @RecCount = COUNT(1) from #FinalData_Temp A
		/*
		
		
		print @reccount

		
		select @RecFrom = ((@PageNo - 1) * @PageSize) + 1

		select @RecTo = @PageNo *  @PageSize
		select *, @RecCount as RecCount 
		INTO #FinalData_Output
		from #FinalData_Temp
			where RowNum between @RecFrom and @RecTo 
	
	

		if(@IsDebug = 1)
		Begin
			select '#FinalData_Output', * from #FinalData_Output
		End

		*/
		create table #HoldTypes
		(
			HoldType	varchar(10)
		)
		insert into #HoldTypes (HoldType)
		values ('CTF'),('TMF'),('Line'),('Other'),('Customs'),('Freight'),('ClosedArea')

		select ContainerList = (
			Select T.*, A.RowNum, @RecCount as RecCount 
			from #FinalData_Temp A
			inner join #TempAll T on a.id = T.id
--			where IsDataSelected = 1
			order by Rownum
			FOR JSON PATH
		), 
		--DropDowns = ( SELECT
		--	CSRList = (Select distinct CsrName from  #TempAll where IsSelectedStatusKey = 1 and isnull(CSRName,'')<>'' order by  CsrName for JSON PATH),
		--	CSMList = (SElect distinct CSManagerName from #TempAll where IsSelectedStatusKey = 1 and isnull(CSManagerName,'')<>'' Order by CSManagerName For JSON PATH ),
		--	CustList = (Select distinct CustKey, CustName  from #TempAll where IsSelectedStatusKey = 1 and isnull(CustName,'')<>'' Order by CustName FOR JSON PATH) ,
		--	HoldTypeList = (Select distinct HoldType  from #HoldTypes  where isnull(HoldType,'')<>'' Order by HoldType FOR JSON PATH),
		--	HoldStatus = (SElect distinct HoldStatus from #TempAll where IsSelectedStatusKey = 1 and isnull(HoldStatus,'')<>'' Order by HoldStatus For JSON PATH ),
		--	SalesPersonList = (SElect distinct SalesPersonName from #TempAll where IsSelectedStatusKey = 1 and isnull(SalesPersonName,'')<>'' Order by SalesPersonName For JSON PATH ),
		--	DeliveryLocationList = (SElect distinct  ltrim(rtrim(D_AddrName)) as LocationName from #TempAll where IsSelectedStatusKey = 1 and isnull(D_AddrName,'')<>'' Order by ltrim(rtrim(D_AddrName)) For JSON PATH ),
		--	MarketLocList = (SElect distinct MarketLocation from #TempAll where IsSelectedStatusKey = 1 and isnull(MarketLocation,'')<>'' Order by MarketLocation For JSON PATH ),
		--	TerminalList = (SElect distinct Pod_terminal_name as TerminalName from #TempAll where IsSelectedStatusKey = 1 and isnull(Pod_terminal_name,'')<>'' Order by Pod_terminal_name For JSON PATH ),
		--	OrderTypeList = (SElect distinct OrderType from #TempAll where IsSelectedStatusKey = 1 and isnull(OrderType,'')<>'' Order by OrderType For JSON PATH ),
		--	TrackingList = (SElect distinct Tracking from #TempAll where IsSelectedStatusKey = 1 and isnull(Tracking,'')<>'' Order by Tracking For JSON PATH )
		--	FOR JSON PATH
		--),
		DropDowns = ( SELECT
			CSRList = (Select distinct CsrName from  #TempAll where  isnull(CSRName,'')<>'' order by  CsrName for JSON PATH),
			CSMList = (SElect distinct CSManagerName from #TempAll where  isnull(CSManagerName,'')<>'' Order by CSManagerName For JSON PATH ),
			CustList = (Select distinct CustKey, CustName  from #TempAll where  isnull(CustName,'')<>'' Order by CustName FOR JSON PATH) ,
			HoldTypeList = (Select distinct HoldType  from #HoldTypes  where isnull(HoldType,'')<>'' Order by HoldType FOR JSON PATH),
			HoldStatus = (SElect distinct HoldStatus from #TempAll where  isnull(HoldStatus,'')<>'' Order by HoldStatus For JSON PATH ),
			SalesPersonList = (SElect distinct SalesPersonName from #TempAll where  isnull(SalesPersonName,'')<>'' Order by SalesPersonName For JSON PATH ),
			DeliveryLocationList = (SElect distinct  ltrim(rtrim(D_AddrName)) as LocationName from #TempAll where IsSelectedStatusKey = 1 and isnull(D_AddrName,'')<>'' Order by ltrim(rtrim(D_AddrName)) For JSON PATH ),
			MarketLocList = (SElect distinct MarketLocation from #TempAll where   isnull(MarketLocation,'')<>'' Order by MarketLocation For JSON PATH ),
			TerminalList = (SElect distinct Pod_terminal_name as TerminalName from #TempAll where   isnull(Pod_terminal_name,'')<>'' Order by Pod_terminal_name For JSON PATH ),
			OrderTypeList = (SElect distinct OrderType from #TempAll where  isnull(OrderType,'')<>'' Order by OrderType For JSON PATH ),
			TrackingList = (SElect distinct Tracking from #TempAll where  isnull(Tracking,'')<>'' Order by Tracking For JSON PATH )
			FOR JSON PATH
		),
		Dashboard = (
			Select * from #DashBoard
			For JSON PATH
		)
		FOR JSON PATH

		

		INSERT INTO SqlExecutionTimeLog
	(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	VALUes (@UserKey,'Scheduler_GetListV2','Procedure Execution end','',GETDATE())
		SET @Status=1
		SET @Reason='SUCCESSS'
		
		SET @DataSendEnd = sysutcdatetime()
		set @ProcessEnd = sysutcdatetime()
		if(@IsDebug = 1)
		Begin
			print 'End Time - Data Send'
			print convert(varchar,@DataSendEnd )	
			print 'End Time - Process End'
			print convert(varchar,@ProcessEnd )
		End

		drop table #OrderTypeKeys
		
		drop table #ContainerStatusKeys 
		drop table #CSMKeys 
		drop table #CSRKeys
		drop table #CustData
		drop table #CustKeys
		drop table #DelieverLocationKeys
		
		drop table #MarketKeys
		drop table #SalesPersonKeys

		drop table #TerminalCodes
		drop table #TerminalNames
		drop table #VesselIMOs
		drop table #OrderDetailKeys
		
		drop table #DashBoard
		drop table #HoldTypes
		drop table #TempAll
		drop table #FinalData_Temp
		--drop table #FinalData_Output
		drop table #Status
		
		If ( @IsDebug = 1)
		Begin
			Select @ProcessStart		as ProcessStart,
					@ProcessEnd			as ProcessEnd,
					DATEDIFF(SECOND, @ProcessStart,@ProcessEnd ) as PRocessTime,
					@KeyFetchStart		as KeyFetchStart,
					@KeyFetchEnd		as KeyFetchEnd	,
					DATEDIFF(MILLISECOND,@KeyFetchStart, @KeyFetchEnd ) as KeyFetchTime,
					@DataFetchStrt		as DataFetchStrt,
					@DataFetchEnd		as DataFetchEnd,
					DATEDIFF(MILLISECOND, @DataFetchStrt, @DataFetchEnd) as DataFetchTime,
					@DataProcessStart	as DataProcessStart	,
					@dataProcessEnd		as dataProcessEnd,
					DATEDIFF(MILLISECOND, @DataProcessStart, @dataProcessEnd) as DataProcessTime,
					@DataSendStart		as DataSendStart,
					@DataSendEnd		as DataSendEnd,
					DATEDIFF(MILLISECOND, @DataSendStart, @DataSendEnd) as DataSendTime

		End
		PRINT 'PRocessTime'
		PRINT DATEDIFF(SECOND, @ProcessStart,@ProcessEnd )  
		print 'KeyFetchTime'
		print DATEDIFF(MILLISECOND,@KeyFetchStart, @KeyFetchEnd ) 
		print 'DataFetchTime'
		print DATEDIFF(MILLISECOND, @DataFetchStrt, @DataFetchEnd) 
		print 'DataProcessTime'
		print DATEDIFF(MILLISECOND, @DataProcessStart, @dataProcessEnd) 
		print 'DataSendTime'
		print DATEDIFF(MILLISECOND, @DataSendStart, @DataSendEnd)

END
