/**
--OOCU7162977
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"ContainerNo":"","ThisWeek":false,"Today":false,"Arrived":false,"NextWeek":false,"ThisMonth":false,"DemurrageStatus":false,"DetentionStatus":false,"NearingDemurrage":false,"WithDemurrage":false,"WithDetention":false,"Terminal":"","PageNo":1,"PageSize":50,"SortField":"OrderNo","IsAscending":true,"CSMKeys":"","CSRKeys":"","ContainerStatusKeys":"","CustKeys":"","SalesPersonKeys":"","HoldStatus":"","TerminalNames":"","TerminalCodes":"","VesselIMOs":"","MarketKeys":"","SearchText":"","DischargeYN":"","PickupAvailable":"","HoldTypes":"Freight:","PickUpFrom":null,"PickUpTo":null,"OrderType":"","Deliverylocationkeys":"","Tracking":""}',
	@Status BIT=0, @IsDebug bit = 0,
	@Reason VARCHAR(100)=''
EXec Scheduler_GetListV2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Scheduler_GetListV2_Base20260210]   
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
AS
BEGIN
INSERT INTO SqlExecutionTimeLog
	(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	VALUes (@UserKey,'Scheduler_GetListV2','Procedure Entered','',GETDATE())
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	--SET ARITHABORT ON;

	SET ANSI_PADDING,
    ANSI_WARNINGS,
    CONCAT_NULL_YIELDS_NULL,
    ARITHABORT,
    QUOTED_IDENTIFIER,
    ANSI_NULLS ON;
	--Declare @IsDebug	bit = 0

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
		@PickUpFrom            datetime  ,
        @PickUpTo              datetime  ,

		@CSRName				varchar(50),
		@PageNo			int,
		@PageSize		int,
		@SearchText		nvarchar(MAX),
		@SortField		varchar(50),
		@IsAscending	Bit = 1,
		@IsCTF				bit		,
		@IsTMF				bit		,
		@IsLine				bit		,
		@IsOther			bit		,	
		@IsCustoms			bit		,
		@IsFreight			bit		,
		@IsClosedArea		bit		,
		@isShowAll			BIT=1,
		@OutputType			Varchar(50),
		@StatusKey			INT=0,
		@OrderType          varchar(50),
		@Deliverylocationkeys VARCHAR(100),
		@Tracking	VARCHAR(10),
		@SearchCriteriaKey INT
		

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End
	
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
		HoldStatus				varchar(max)		'$.HoldStatus',
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
		SearchText				NVARCHAR(MAX)		'$.SearchText',
		SortField				varchar(50)		'$.SortField',
		IsAscending				bit				'$.IsAscending',
		OutputType				varchar(50)		'$.OutputType',
		StatusKey				varchar(50)		'$.StatusKey',
		OrderType				varchar(50)		'$.OrderType',
		Deliverylocationkeys	varchar(100)	'$.Deliverylocationkeys',
		Tracking				VARCHAR(100)				'$.Tracking',
		SearchCriteriaKey		INT				'$.SearchCriteriaKey'
	)
	


	SET @IsCTF = CASE WHEN @HoldTypes LIKE '%CTF%' THEN 1 ELSE 0 END 
	SET @IsTMF = CASE WHEN @HoldTypes LIKE '%TMF%' THEN 1 ELSE 0 END 
	SET @IsLine = CASE WHEN @HoldTypes LIKE '%LINE%' THEN 1 ELSE 0 END  
	SET	@IsOther = CASE WHEN @HoldTypes LIKE '%OTHER%' THEN 1 ELSE 0 END 
	SET @IsCustoms = CASE WHEN @HoldTypes LIKE '%CUSTOMS%' THEN 1 ELSE 0 END 
	SET @IsFreight = CASE WHEN @HoldTypes LIKE '%FREIGHT%' THEN 1 ELSE 0 END 
	SET @IsClosedArea = CASE WHEN @HoldTypes LIKE '%CLOSEDAREA%' THEN 1 ELSE 0 END 

	SET @StatusKey = Case when @StatusKey = 6 then 12 else @StatusKey end
	SET @StatusKey = Case when @StatusKey = 15 then 0 else @StatusKey end

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
		,@IsFreight AS IsFreight, @IsClosedArea AS ClosedArea
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

	--Select distinct Final_dest_city , 
	--	MarketLocation = case when Final_dest_city in ('Chicago, US','Harvey, US','Joliet, US','Elwood, US')
	--	Then 'Chicago' 
	--	when isnull(Final_dest_city,'') = '' then 'NA' 
	--	else 'Long Beach' end
	--into #MktLocation
	--from Gnosis_Integration_Container_FINAL WITH (NOLOCK)	

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
	--select @isShowAll
	
	--DECLARE @STRSQL VARCHAR(MAX)
	Declare @RecCount	int, @RowNum int

	if(isnull(@SearchText,'') <> '')
	Begin
		SET @PickupFrom		='01/01/2020'
		SET @PickupTo		='01/12/2050'
	End

	create table #OrderDetailKeys
	(
		OrderDetailKey	int primary key
	)
	if(isnull(@SearchText,'') <> '')

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
	ELSE
	BEGIN
		--SELECT OrderDetailkey INTO #OrderDetail FROM OrderDetail
		--WHERE status IN (1,2,3,7,9,6,12,14)
		Insert into #OrderDetailKeys
		SELECT OrderDetailkey  FROM OrderDetail WITH (NOLOCK)
		WHERE status IN (1,2,3,7,9,6,12,14)
	END
	
	if(@IsDebug=1)
	BEGIN
		SELECT '#OrderDetailKeys',* FROM #OrderDetailKeys
	END

		SELECT
			isnull(OH.OrderKey,0) OrderKey,
			isnull(OH.OrderDate,'1900-01-01') as OrderDate,
			isnull(OD.OrderDetailkey,0) as OrderDetailkey,
			COALESCE(OD.OrderTypeKey, OH.OrderTypeKey, 0) as OrderTypeKey,
			isnull(OH.OrderNo,'') as OrderNo,
			isnull(OD.ContainerNo,'') as ContainerNo,
			isnull(OD.ContainerID, '') as ContainerID,
			isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,
			--ISNULL(isnull(OD.LastFreeDay,Last_free_demurrage_day_dt),'') as LastFreeDay,
			--convert(Datetime,ISNULL(isnull(OD.LastFreeDay,Last_free_demurrage_day_dt ),'1900-01-01')) as LastFreeDay,
			CONVERT(DATETIME, ISNULL(ISNULL(CGD.LFD, OD.LastFreeDay), '1900-01-01')) AS LastFreeDay,
			--RT.PickupDateFrom AS PickupDate ,
			--CONVERT(VARCHAR(10), CAST(RT.PickupDateFrom AS TIME), 0) PickupTime,		
			--RT.DeliveryDateFrom AS DropOffDate,
			--CONVERT(VARCHAR(10), CAST(RT.DeliveryDateFrom AS TIME), 0) DropOffTime,
			
			--ODS.ActualPickupDate AS PickupDate ,
			--CONVERT(VARCHAR(10), CAST(ODS.ActualPickupDate AS TIME), 0) PickupTime,		
			--ODSD.ActualDeliveryDate AS DropOffDate,
			--CONVERT(VARCHAR(10), CAST(ODSD.ActualDeliveryDate AS TIME), 0) DropOffTime,	

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
			
			--isnull(CSR.AddrName,SR.AddrName) AS S_AddrName,
			--isnull(CSR.Address1,SR.Address1) AS S_Address1,
			--isnull(CSR.City,SR.City)  AS S_City,
			--isnull(CSR.[State],SR.[State])  AS S_State,
			--isnull(CSR.ZipCode,SR.ZipCode)  AS S_ZipCode,
			--isnull(CSR.Country,SR.Country)  AS S_Country,

			SR.AddrName AS S_AddrName,
			SR.Address1 AS S_Address1,
			SR.City  AS S_City,
			SR.[State]  AS S_State,
			SR.ZipCode  AS S_ZipCode,
			SR.Country  AS S_Country,

			--isnull(CSR.AddrName,SR.AddrName) AS Source_AddrName,
			--isnull(CSR.Address1,SR.Address1) AS Source_Address1,
			--isnull(CSR.City,SR.City)  AS Source_City,
			--isnull(CSR.[State],SR.[State])  AS Source_State,
			--isnull(CSR.ZipCode,SR.ZipCode)  AS Source_ZipCode,
			--isnull(CSR.Country,SR.Country)  AS Source_Country,

			SR.AddrName AS Source_AddrName,
			SR.Address1 AS Source_Address1,
			SR.City  AS Source_City,
			SR.[State]  AS Source_State,
			SR.ZipCode  AS Source_ZipCode,
			SR.Country  AS Source_Country,

			--isnull(CDT.AddrName,DT.AddrName)  AS D_AddrName,
			--isnull(CDT.Address1,DT.Address1)  AS D_Address1,
			--isnull(CDT.City,DT.City)  AS D_City,
			--isnull(CDT.[State],DT.[State])  AS D_State,
			--isnull(CDT.ZipCode,DT.ZipCode)  AS D_ZipCode,
			--isnull(CDT.Country,DT.Country)  AS D_Country,

			--isnull(CDT.AddrName,DT.AddrName)  AS Destination_AddrName,
			--isnull(CDT.Address1,DT.Address1)  AS Destination_Address1,
			--isnull(CDT.City,DT.City)  AS Destination_City,
			--isnull(CDT.[State],DT.[State])  AS Destination_State,
			--isnull(CDT.ZipCode,DT.ZipCode)  AS Destination_ZipCode,
			--isnull(CDT.Country,DT.Country)  AS Destination_Country,

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
			--ISNULL(isnull(OD.VesselETA,Gnosis_vessel_eta_dt),'') AS VesselETA,
			--CAST(ISNULL(isnull(GICF.Vessel_eta_dt,Gnosis_vessel_eta_dt),'')AS DATETIME) AS VesselETA,
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
			--PDC.Code AS DelayReasonCode,
			
			Stuff((SELECT ', ' + PUD.Code
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPURC
			 INNER JOIN PUScheduleDelayCode PUD WITH (NOLOCK) ON (PUD.CodeKey=ODPURC.PUScheduleRCKey)
			   WHERE OD.OrderDetailKey = ODPURC.OrderDetailKey 
			 FOR XML PATH('')),1,1,'') AS DelayReasonCode,
			 

			OD.PUDelayedCodeKey,
			ISNULL(CGD.Available,GICF.Available_for_pickup) AS AvailableforPickup,
			--ISNULL(CGD.AvailableDate, GICF.Available_dt) AS AvailableforPickupDate,
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
			--GICF.Pod_terminal_name,
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
			 --'' AS FromLocationDifference,
			 --'' AS ToLocationDifference,
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
			 ISNULL(ETA_ATAChangedByUser,0)ETA_ATAChangedByUser,--ContainerStatusChangedByUser,ISNULL(MBLChangedByUser,0) MBLChangedByUser,
			ISNULL(LFDChangedByUser,0) LFDChangedByUser, --SSLChangedByUser,	Size_TypeChangedByUser,HoldChangedByUser,VesselChangedByUser,
			--AvailableChangedByUser,HoldTypeChangedByUser,AvailableDateChangedByUser,
			CASE WHEN ISNULL(CGD.OrderDetailKey,0)=0 THEN CAST(0 AS BIT)  ELSE CAST(1 AS BIT) END  IsGnosisTracking ,
			IsChargesApproved = CASE WHEN ((SELECT COUNT(1) FROM OrderExpense WHERE OrderDetailKey=OD1.OrderDetailKey AND isCSRApproved=0 )>0 
											AND (SELECT COUNT(1) FROM Invoicedetail WHERE OrderDetailKey=OD1.OrderDetailKey)=0)
								   THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
		into #TempAll
		FROM  dbo.#OrderDetailKeys OD1					WITH (NOLOCK)	
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
			--LEFT JOIN OrderDetailStops  ODS			WITH (NOLOCK)   ON ODS.OrderDetailKey=OD.OrderDetailKey AND ODS.StopTypeKey=1 AND ISNULL(ODS.IsDryrunPort,0)=0--added stops table
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
			--LEFT JOIN OrderDetailStops  ODSD			WITH (NOLOCK) ON ODSD.OrderDetailKey=OD.OrderDetailKey AND ODSD.StopTypeKey=3 AND ISNULL(ODSD.IsDryrunCustomer,0)=0--added stops table
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
			--LEFT JOIN		#MktLocation MLT On GICF.Final_dest_city = MLT.Final_dest_city
			--LEFT JOIN		VGnosis_MarketLocation MLT WITH (NOLOCK) On GICF.Final_dest_city = MLT.Final_dest_city
			--LEFT JOIN		#OrderDetailKeys ODK ON od.OrderDetailKey =ODK.OrderDetailKey
			LEFT JOIN Gnosis_VContainerTrackingToDisplay GVTD WITH (NOLOCK) ON (GVTD.OrderDetailKey=OD.OrderDetailKey)
								AND OD.ContainerNo+'_'+oh.BillofLading=GVTD.ContainerNo+'_'+GVTD.MBL
			--LEFT JOIN Container_GnosisData CGD  WITH(NOLOCK) ON OD.OrderDetailKey=CGD.OrderDetailKey
			OUTER APPLY (
						SELECT TOP 1 *
						FROM Container_GnosisData CGDI WITH (NOLOCK)
						WHERE CGDI.OrderDetailKey=OD.OrderDetailKey 
						)CGD
		----WHERE   
			--(ISNULL(@SearchText,'') = '' and OD.status in (1,2,3,7,9,6,12,14) ) OR 
			--(ISNULL(@SearchText,'') = ''  ) OR 
				--( (ISNULL(@SearchText,'') <> '' and od.OrderDetailKey = ODK.OrderDetailKey))

		if(@IsDebug = 1)
		Begin
			SELECT 1
			Select '#TempAll',@IsFreight,Freight,* from #TempAll WHERE ContainerNo = 'MSDU5941323'
			select @SearchText as SearchText
		end
		
		
		Update #TempAll set IsDataSelected = 1, 
		Status=CASE WHEN StatusKey=3 THEN 'Open' ELSE Status END,
		StatusKey=CASE WHEN StatusKey=3 THEN 1 ELSE StatusKey END --changed to update status key 3 as 1
		where  Isnull(@SearchText,'') <> '' OR (
		--(Isnull(@ContainerNo,'') = '' OR ContainerNo = @ContainerNo) AND
		(ISNULL(@PickupAvailable,0 ) = 0 or @PickupAvailable = AvailableforPickup) AND
		(Isnull(@TerminalNames,'') = '' OR Pod_terminal_name in (select TerminalName from #TerminalNames)) AND
		(isnull(@IsCTF,0) = 0 OR CTF = 'true') AND
		(isnull(@IsTMF,0) = 0 OR TMF = 'true') AND
		(isnull(@IsLine,0) = 0 OR Line = 'true') AND
		(isnull(@IsOther,0) = 0 OR Other = 'true') AND
		(isnull(@IsCustoms,0) = 0 OR Customs = 'true') AND
		(isnull(@IsFreight,0) = 0 OR Freight = 'true') AND
		(isnull(@IsClosedArea,0) = 0 OR ClosedArea = 'true') AND

		
		(Isnull(@CustKeys,'') = '' OR Customer in (SElect CustName from #CustKeys) ) AND
		(Isnull(@CSRkeys,'') = '' OR OrderCSR in (SElect CSRName from #CSRKeys) ) AND
		--(Isnull(@CSMkeys,'') = '' OR CSRManagerKey in (Select CSMKey from #CSMKeys) ) AND
		(Isnull(@MarketKeys,'') = '' OR MarketLocationKey in (select MarketKey from #MarketKeys )) AND 
		
		--(Isnull(@SalesPersonKeys,'') = '' OR SalesPersonKey in (Select SalesPersonKey from #SalesPersonKeys ) ) AND
		
		(ISNULL(@PickUpFrom,'') ='' OR isnull(Pickup_appointment_dt,'') = '' or Pickup_appointment_dt >= @PickUpFrom) AND
		(ISNULL(@PickUpTo,'') ='' OR isnull(Pickup_appointment_dt,'') = '' or Pickup_appointment_dt  <= @PickUpTo)-- AND
		--(isnull(@isShowAll,0) = 1 OR @UserKey =LinkedUserKey)
		AND (ISNULL(@Tracking,'')='' OR @Tracking= case when [Tracking] = 1 then 'Yes' else 'No' end )
		AND (ISNULL(@Deliverylocationkeys,'')='' OR ltrim(rtrim(D_AddrName)) in (Select DeliverocationKey from #DelieverLocationKeys ))
		AND	(ISNULL(@OrderType ,'') =''  OR OrderTypeKey in (SElect OrderTypeKey from #OrderTypeKeys) )
		)

		if(@IsDebug = 1)
		Begin
			SELECT 1
			Select '#TempAll-AfterUpdate',IsDataSelected,* from #TempAll WHERE ContainerNo = 'MSDU5941323'
			select @SearchText as SearchText
		end

		Select T.Status,T.StatusKey, count(1) as cnt 
		INTO #Status
		from  #TempAll T
		where IsDataSelected = 1
		group by T.Status,T.StatusKey
		Select ODS.Status as Statuskey, ODS.Description , isnull(cnt,0) as ContainerCount
		into #DashBoard
		from OrderDetailStatus ODS WITH (NOLOCK)	
		Left join #Status T on ODS.Status = T.StatusKey
		where  ODS.status in (1,2,3,6,7,9,12,14)
		

		if(@IsDebug = 1)
		Begin
			SELECT 1
			Select '#Status',* from #Status  
			select @SearchText as SearchText
		end
		--update #TempAll set Statuskey = 6 where statuskey in (6,12,14)

		/* REMOVED AS PER INSTRUCTION FROM KATHRYN ON 30/09/2024 
		declare @CompleteCount	int,
				@CSCount		int
		SElect @CSCount = ConfigValue1 from AppConfig where ConfigId = 72
		
		update #DashBoard SET ContainerCount = @CSCount where StatusKey = 9
		*/
		

		--update #DashBoard set ContainerCount = @CompleteCount, Description = 'Complete' where Statuskey = 12
		--select @CompleteCount = sum(ContainerCount) from #DashBoard where statuskey in (6,12,14)
		update #DashBoard set Description = 'Complete' where Statuskey = 12
		--Delete from #DashBoard where statuskey = 14
		--Delete from #DashBoard where statuskey = 6

		insert into #DashBoard (Statuskey,Description, ContainerCount)
		select 0, 'Total Containers', sum(Containercount) from #DashBoard
		 
		if(@IsDebug = 1)
		Begin
			select '#DashBoard', * from #DashBoard
			select '#TempDashboard',count(1) from #TempAll where IsDataSelected = 1
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
		update #TempAll set IsSelectedStatusKey = 1
		where IsDataSelected = 1 and ((ISNULL(@SearchText,'') <>'' AND @StatusKey = 0) OR 
			(StatusKey in (1,2,3,6,7,9,12,14) and 
				(isnull(@statusKey,0) = 0 OR  StatusKey in (SELECT StatusKey from #tmpStatusKeys))))
		
		--alter table #TempAll add ID int identity(1,1) Primary Key

		if(@IsDebug = 1)
		Begin
			select '#Temp', count(1) from #TempAll where IsSelectedStatusKey = 1
		End

		Declare @STRSQL nvarchar(max) = ''
		SET @STRSQL = 'SELECT ID,  ROW_NUMBER() over (Order by ' + @SortField + ' ' + 
		CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' ) as RowNum FROM  #TempAll 
		where IsSelectedStatusKey = 1'-- ORDER BY '+ @SortField
		--+ ' ' + 		CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END
		print @STRSQL

		select ID, convert(int, 0) as RowNum into  #FinalData_Temp from #TempAll WHERE 1 <> 1 

		insert into #FinalData_Temp (ID, RowNum)
		EXEC (@STRSQL)

		--select * into Schedulert_Temp_Praveen FROM #FinalData_Temp

		if(@IsDebug = 1)
		Begin
			select '#FinalData_Temp', * from #FinalData_Temp
		End

		Select @RecCount = COUNT(1) from #FinalData_Temp A
		
		print @reccount

		declare @RecFrom int, @RecTo  int
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

		create table #HoldTypes
		(
			HoldType	varchar(10)
		)
		insert into #HoldTypes (HoldType)
		values ('CTF'),('TMF'),('Line'),('Other'),('Customs'),('Freight'),('ClosedArea')

		select ContainerList = (
			Select T.*, A.RowNum, A.RecCount from #FinalData_Output A
			inner join #TempAll T on a.id = T.id
			where IsSelectedStatusKey = 1
			order by Rownum
			FOR JSON PATH
		), 
		DropDowns = ( SELECT
			CSRList = (Select distinct CsrName from  #TempAll where IsSelectedStatusKey = 1 and isnull(CSRName,'')<>'' order by  CsrName for JSON PATH),
			CSMList = (SElect distinct CSManagerName from #TempAll where IsSelectedStatusKey = 1 and isnull(CSManagerName,'')<>'' Order by CSManagerName For JSON PATH ),
			CustList = (Select distinct CustKey, CustName  from #TempAll where IsSelectedStatusKey = 1 and isnull(CustName,'')<>'' Order by CustName FOR JSON PATH) ,
			HoldTypeList = (Select distinct HoldType  from #HoldTypes  where isnull(HoldType,'')<>'' Order by HoldType FOR JSON PATH),
			HoldStatus = (SElect distinct HoldStatus from #TempAll where IsSelectedStatusKey = 1 and isnull(HoldStatus,'')<>'' Order by HoldStatus For JSON PATH ),
			SalesPersonList = (SElect distinct SalesPersonName from #TempAll where IsSelectedStatusKey = 1 and isnull(SalesPersonName,'')<>'' Order by SalesPersonName For JSON PATH ),
			DeliveryLocationList = (SElect distinct  ltrim(rtrim(D_AddrName)) as LocationName from #TempAll where IsSelectedStatusKey = 1 and isnull(D_AddrName,'')<>'' Order by ltrim(rtrim(D_AddrName)) For JSON PATH ),
			MarketLocList = (SElect distinct MarketLocation from #TempAll where IsSelectedStatusKey = 1 and isnull(MarketLocation,'')<>'' Order by MarketLocation For JSON PATH ),
			TerminalList = (SElect distinct Pod_terminal_name as TerminalName from #TempAll where IsSelectedStatusKey = 1 and isnull(Pod_terminal_name,'')<>'' Order by Pod_terminal_name For JSON PATH ),
			OrderTypeList = (SElect distinct OrderType from #TempAll where IsSelectedStatusKey = 1 and isnull(OrderType,'')<>'' Order by OrderType For JSON PATH ),
			TrackingList = (SElect distinct Tracking from #TempAll where IsSelectedStatusKey = 1 and isnull(Tracking,'')<>'' Order by Tracking For JSON PATH )
			FOR JSON PATH
		),
		Dashboard = (
			Select * from #DashBoard
			For JSON PATH
		)
		FOR JSON PATH

		
		--select count(1) from #temp
		--where RowNum between @RecFrom and @RecTo

		INSERT INTO SqlExecutionTimeLog
	(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	VALUes (@UserKey,'Scheduler_GetListV2','Procedure Execution end','',GETDATE())
		SET @Status=1
		SET @Reason='SUCCESSS'

		--drop table #TempPrev
		drop table #OrderTypeKeys
		drop table #FinalData_Temp
		drop table #ContainerStatusKeys 
		drop table #CSMKeys 
		drop table #CSRKeys
		drop table #CustData
		drop table #CustKeys
		drop table #DelieverLocationKeys
		drop table #FinalData_Output
		drop table #MarketKeys
		--drop table #MktLocation
		drop table #SalesPersonKeys
		drop table #DashBoard
		drop table #HoldTypes
		drop table #TempAll
		--drop table #TempDashboard
		drop table #TerminalCodes
		drop table #TerminalNames
		drop table #VesselIMOs
		drop table #OrderDetailKeys
		drop table #Status

END
