/*
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"SearchCriteriaKey":0,"DriverKeys":"","OrderKeys":"","OrderNo":"","containerNo":"","voucherNo":"","VoucherKeys":"","DriverHubkeys":"","WeekNum":"","MarketLocationKeys":"","TruckTypeKeys":"","CarrierMoveTypeKeys":"","SearchText":"","SortField":"voucherno","IsAscending":true,"PageSize":50,"PageNo":1,"StatusKey":0,"isDriverPay":false}',
	@Status BIT=0, @Debug int = 0,@Reason VARCHAR(100)=''
EXec Get_VoucherList_V2_BASE20260303 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @Debug
Select @Status, @Reason
**/
CREATE Procedure [dbo].[Get_VoucherList_V2_BASE20260303] 
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IsDebug		bit = 0
)-- [Get_DriverDispatchList]  @ContainerNo='EMCU1599652', @MarketLocationKey=0
WITH RECOMPILE
AS
BEGIN
	--INSERT INTO SqlExecutionTimeLog
	--(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	--VALUes (@UserKey,'Get_VoucherList_V2','Procedure Entered','',GETDATE())
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	Declare 
		@StatusKey				INT= 0,
		@DriverKeys				varchar(max)= '',
		@OrderKeys				varchar(max)= '',
		@OrderDateFrom			DATE='07/01/2025',
		@OrderDateTo			DATE='12/31/2099',
		@DeliveryDateFrom		DATE='07/01/2025',
		@DeliveryDateTo			DATE='12/31/2099',
		@OrderNo				VARCHAR(50)='',
		@containerNo			VARCHAR(50)='',
		@voucherNo				VARCHAR(50)='',
		@VoucherKeys			varchar(max)= '',
		@DriverHubkeys			varchar(max)= '',
		@WeekNum				VARCHAR(5) = '',
		@marketLocationKeys		varchar(max)= '',
		@TruckTypeKeys		    varchar(max)= '',
		@CarrierMoveTypeKeys	varchar(max)= '',
		@PageNo					int,
		@PageSize				int,
		@SearchText				nvarchar(MAX),
		@SortField				varchar(50),
		@IsAscending			Bit = 1,
		@isDriverPay			Bit = 0,
		@SearchCriteriaKey     INT = 0

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select	@containerNo = Isnull(ContainerNo,''),		@StatusKey = Statuskey,
			@DriverKeys = DriverKeys,		@OrderKeys = OrderKeys,
			@OrderDateFrom	= OrderDateFrom, @OrderDateTo = OrderDateTo,		
			@DeliveryDateFrom = DeliveryDateFrom, @DeliveryDateTo	= DeliveryDateTo, 
			@OrderNo = OrderNo,
			@voucherNo = voucherNo, @VoucherKeys = VoucherKeys,
			@DriverHubkeys = DriverHubkeys, @WeekNum = WeekNum,
			@MarketLocationKeys	= MarketLocationKeys,
			@TruckTypeKeys = TruckTypeKeys,
			@CarrierMoveTypeKeys = CarrierMoveTypeKeys,
			@PageNo = PageNo,  @PageSize =PageSize, 
			@SearchText = ltrim(rtrim(isnull(SearchText,''))), @SortField = SortField,
			@IsAscending = isnull(IsAscending,1),
			@isDriverPay = isDriverPay,
			@SearchCriteriaKey = SearchCriteriaKey
	from OpenJSON(@JsonString, '$')
	WITH (
		ContainerNo				varchar(20)			'$.containerNo',
		StatusKey				INT					'$.StatusKey',
		DriverKeys				varchar(max)		'$.DriverKeys',
		OrderKeys				varchar(max)		'$.OrderKeys',
		OrderDateFrom			DATE				'$.OrderDateFrom',
		OrderDateTo				DATE				'$.OrderDateTo',
		DeliveryDateFrom			DATE				'$.DeliveryDateFrom',
		DeliveryDateTo			DATE				'$.DeliveryDateTo',
		OrderNo					VARCHAR(50)			'$.OrderNo',
		voucherNo				VARCHAR(50)			'$.voucherNo',
		VoucherKeys				varchar(max)		'$.VoucherKeys',
		DriverHubkeys			varchar(max)		'$.DriverHubkeys',
		WeekNum					VARCHAR(5)			'$.WeekNum',
		MarketLocationKeys		varchar(max)		'$.MarketLocationKeys',
		TruckTypeKeys		    varchar(max)	    '$.TruckTypeKeys',
		CarrierMoveTypeKeys		varchar(max)		'$.CarrierMoveTypeKeys',
		PageNo					int					'$.PageNo',
		PageSize				int					'$.PageSize',
		SearchText				nvarchar(MAX)		'$.SearchText',
		SortField				varchar(50)			'$.SortField',
		IsAscending				bit					'$.IsAscending'	,
		isDriverPay				bit					'$.isDriverPay',
		SearchCriteriaKey		INT					'$.SearchCriteriaKey'
	)
	print '1'

	--Declare @StrDateOrder varchar(20), @StrDateDelivery		varchar(20)
	Declare @IsWithFilter Bit = 0
	if(Isnull(@voucherNo,'') <> '' OR isnull(@containerNo,'') <> '' OR isnull(@OrderNo,'')<>'' )
	Begin
		SEt @IsWithFilter = 1
	End
	if(@OrderDateFrom = '0001-01-01 00:00:00' OR @OrderDateFrom = '1900-01-01' OR @OrderDateFrom is null)
	Begin
		Set @OrderDateFrom = case when @IsWithFilter = 0 then Getdate() - 250 else  '2025-01-01' end
	End
	if(@OrderDateTO = '0001-01-01 00:00:00' OR @OrderDateTo = '1900-01-01' OR @OrderDateTo is null )
	Begin
		Set @OrderDateTO = '2050-12-31'
	End
	if(@DeliveryDateFrom = '0001-01-01 00:00:00' OR @DeliveryDateFrom='1900-01-01' OR @DeliveryDateFrom is null)
	Begin
		Set @DeliveryDateFrom =  case when @IsWithFilter = 0 then Getdate() - 250 else '2025-01-01' end
	End
	if(@DeliveryDateTo = '0001-01-01 00:00:00' OR @DeliveryDateTo='1900-01-01' OR @DeliveryDateTo is null)
	Begin
		Set @DeliveryDateTo = '2050-12-31'
	End
	
	print '2'
	if(@IsDebug = 1)
	Begin
		Select	@containerNo AS ContainerNo,		@StatusKey AS Statuskey,
			@DriverKeys AS DriverKeys,		@OrderKeys AS OrderKeys,
			@OrderDateFrom	AS OrderDateFrom, @OrderDateTo AS OrderDateTo,		
			@DeliveryDateFrom AS DeliveryDateFrom, @DeliveryDateTo	AS DeliveryDateTo, 
			@OrderNo AS OrderNo, 
			@voucherNo AS voucherNo, @VoucherKeys AS VoucherKeys,
			@DriverHubkeys AS DriverHubkeys, @WeekNum AS WeekNum,
			@MarketLocationKeys	AS MarketLocationKeys,
			@TruckTypeKeys as TruckTypeKeys,
			@CarrierMoveTypeKeys as CarrierMoveTypeKeys,
			@PageNo  as PageNo,  @PageSize as PageSize , 
			@SearchText  as SearchText, @SortField  as SortField,
			@IsAscending as IsAscending,
			@isDriverPay as isDriverPay,
			@SearchCriteriaKey AS SearchCriteriaKey
	End

	print '3'
	create table #DriverKey
	(
		DriverKey	int
	)
	create table #OrderKey
	(
		OrderKey	int
	)
	create table #voucherKey
	(
		VoucherKey	int
	)
	create table #DriverHubKey
	(
		DriverhubKey	int
	)
	create table #MarketLocationKey
	(
		MarketLocationKey	int
	)
	create table #TruckTypeKey
	(
		TruckTypeKey	int
	)
	create table #CarrierMoveTypeKey
	(
		MoveTypeKey	int
	)

	CREATE TABLE #OrderDetailKeys (OrderDetailKey INT PRIMARY KEY);
	CREATE TABLE #IsDriverPayDriverKeys (DriverKey INT PRIMARY KEY);

	IF(@IsDriverPay=1)
    BEGIN
        INSERT INTO #IsDriverPayDriverKeys
        (DriverKey)
        SELECT DriverKEY FROM Driver WITH (NOLOCK) WHERE TRY_CAST(LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1) AS INT)  BETWEEN 700 AND 948
    END
    ELSE
    BEGIN
        INSERT INTO #IsDriverPayDriverKeys
        (DriverKey)
        SELECT DriverKEY FROM Driver  WITH (NOLOCK) WHERE TRY_CAST(LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1) AS INT)  Not BETWEEN 700 AND 948
    END

	if(Isnull(@DriverKeys,'') <> '')
	Begin
		insert into #DriverKey(DriverKey)
		select value from dbo.Fn_SplitParamCol(@DriverKeys)
	End

	if(Isnull(@OrderKeys,'') <> '')
	Begin
		insert into #OrderKey(OrderKey)
		select value from dbo.Fn_SplitParamCol(@OrderKeys)
	End

	if(Isnull(@VoucherKeys,'') <> '')
	Begin
		insert into #voucherKey(VoucherKey)
		select value from dbo.Fn_SplitParamCol(@VoucherKeys)
	End

	if(Isnull(@DriverHubkeys,'') <> '')
	Begin
		insert into #DriverHubKey(DriverhubKey)
		select value from dbo.Fn_SplitParamCol(@DriverHubkeys)
	End

	if(Isnull(@marketLocationKeys,'') <> '')
	Begin
		insert into #MarketLocationKey(MarketLocationKey)
		select value from dbo.Fn_SplitParamCol(@marketLocationKeys)
	End

	if(Isnull(@TruckTypeKeys,'') <> '')
	Begin
		insert into #TruckTypeKey(TruckTypeKey)
		select value from dbo.Fn_SplitParamCol(@TruckTypeKeys)
	End

	if(Isnull(@CarrierMoveTypeKeys,'') <> '')
	Begin
		insert into #CarrierMoveTypeKey(MoveTypeKey)
		select value from dbo.Fn_SplitParamCol(@CarrierMoveTypeKeys)
	End

	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3 = Paid, 9 = PENDING TO CREATE VOUCHER

	IF(@StatusKey = 4)
	Begin
		Set @StatusKey = 0
	End

	-- Handle search text
	DECLARE @IsSearchActive BIT = 0;

	-- Handle search text
	IF ISNULL(@SearchText,'') <> ''
	BEGIN
		SET @IsSearchActive = 1;
		DECLARE @HasComma BIT = CASE WHEN CHARINDEX(',', @SearchText) > 0 THEN 1 ELSE 0 END;

		-- Single value search (no comma)
		IF @HasComma = 0
		BEGIN
			-- Check if search text is VoucherNo
			IF EXISTS (
				SELECT 1 
				FROM VoucherHeader WITH (NOLOCK)
				WHERE VoucherNo = @SearchText
			)
			BEGIN
				INSERT INTO #VoucherKey (VoucherKey)
				SELECT DISTINCT VoucherKey
				FROM VoucherHeader WITH (NOLOCK)
				WHERE VoucherNo = @SearchText;
			END
			ELSE
			BEGIN
				-- Search by ContainerNo
				INSERT INTO #OrderDetailKeys (OrderDetailKey)
				SELECT DISTINCT OD.OrderDetailKey
				FROM dbo.OrderDetail OD WITH (NOLOCK)
				WHERE OD.ContainerNo = @SearchText;

				-- Search by OrderNo
				INSERT INTO #OrderDetailKeys (OrderDetailKey)
				SELECT DISTINCT OD.OrderDetailKey
				FROM dbo.OrderDetail OD WITH (NOLOCK)
				INNER JOIN dbo.OrderHeader OH WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
				WHERE OH.OrderNo = @SearchText
				  AND NOT EXISTS (SELECT 1 FROM #OrderDetailKeys OK WHERE OK.OrderDetailKey = OD.OrderDetailKey);
			END
		END
		ELSE
		BEGIN
			-- Multiple values (comma-separated)
			IF(@SearchCriteriaKey = 1) -- ContainerNo
			BEGIN
				INSERT INTO #OrderDetailKeys (OrderDetailKey)
				SELECT DISTINCT OD.OrderDetailKey
				FROM OrderDetail OD WITH (NOLOCK)
				WHERE ContainerNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM fn_splitparam(@SearchText));
				print 'ContainerNo'           
			END		
			ELSE IF(@SearchCriteriaKey = 2) -- OrderNo
			BEGIN
				INSERT INTO #OrderDetailKeys (OrderDetailKey)
				SELECT DISTINCT OD.OrderDetailKey
				FROM OrderDetail OD WITH (NOLOCK)
				INNER JOIN OrderHeader OH WITH (NOLOCK) ON OD.orderKey = OH.orderKey
				WHERE OrderNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM fn_splitparam(@SearchText));
			END
			ELSE IF(@SearchCriteriaKey = 6) -- VoucherNo
			BEGIN
				INSERT INTO #voucherKey (VoucherKey)
				SELECT DISTINCT VH.VoucherKey 
				FROM VoucherHeader VH WITH (NOLOCK)
				WHERE VH.VoucherNo IN (SELECT LTRIM(RTRIM(VALUE)) FROM fn_splitparam(@SearchText));
			END
		END
	END

	if(@IsDebug = 1)
	Begin
		select '#DriverKey',* from #DriverKey
		select '#OrderKey',* from #OrderKey
		select '#DriverHubKey',* from #DriverHubKey
		select '#voucherKey',* from #voucherKey
		select '#MarketLocationKey',* from #MarketLocationKey
		SELECT '#OrderDetailKeys', * FROM #OrderDetailKeys
	end
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 3 = Paid, 9 = PENDING TO CREATE VOUCHER

	IF(@StatusKey = 4)
	Begin
		Set @StatusKey = 0
	End
	
	if(isnull(@WeekNum ,'')<>'')
	Begin
		DECLARE @datecol datetime = GETDATE();
		DECLARE @WeekNumInt INT = convert(int, replace(@weekNum,'WK-','') )
				, @YearNum char(4);

		SELECT @YearNum = CAST(DATEPART(YY, @datecol) AS CHAR(4));

		-- once you have the @WeekNum and @YearNum set, the following calculates the date range.
		SELECT @DeliveryDateFrom = DATEADD(wk, DATEDIFF(wk, 6, '1/1/' + @YearNum) + (@WeekNumInt-1), 7) ;
		SELECT @DeliveryDateTo = DATEADD(wk, DATEDIFF(wk, 5, '1/1/' + @YearNum) + (@WeekNumInt-1), 7);
		SEt @OrderDateFrom = '2025-07-01'
		SEt @OrderDateTo = '2050-12-31'
	End
	ELSE IF(@StatusKey=9)
	BEGIN
		SELECT @DeliveryDateFrom = GETDATE()-180 ;
		SELECT @DeliveryDateTo = GETDATE();
	END

	if(@IsDebug = 1)
	Begin
		select @DeliveryDateFrom as DeliveryDateFrom, @DeliveryDateTo as DeliveryDateTo, 
				@OrderDateFrom as OrderDateFrom, @OrderDateTo as OrderDateTo
	End
	
	Print '@IsWithFilter'
	print @IsWithFilter
	print '@OrderDateFrom'
	print @OrderDateFrom
	print '@OrderDateTo'
	print @OrderDateTo
	print '@DeliVeryDateFrom'
	print @DeliveryDateFrom
	print '@DeliveryDateTo'
	print @DeliveryDateTo

	CREATE TABLE #TEMPTABLE
	(
			orderkey			INT,
			orderdetailkey		INT,
			voucheramount		NUMERIC(18,5),
			routekey			INT,
			destinationaddrkey	INT,	
			voucherkey			INT,
			StatusKey			smallint,
			DocumentCount		INT,
			DocCounts			varchar(50),

			orderno				VARCHAR(50),
			containerno			VARCHAR(50),
			driverid			VARCHAR(20),
			firstname			VARCHAR(100),
			lastname			VARCHAR(100),
			voucherno			VARCHAR(50),
			LegTypeID			VARCHAR(100),
			Workflow			VARCHAR(100),
			DestinationCity		VARCHAR(50),
			weekNum				VARCHAR(10),
			DriverKey			int,
			DriverOrg			VARCHAR(100),
			BrokerRefNo			VARCHAR(50),
			VesselETA			DateTime,

			ActualDeparture		DateTime,
			voucherdate			DateTime,
			WeekStart			DateTime,
			WeekEnd				DateTime,
			PaidDate			DateTime,
			CompleteDate		DateTime,

			ispaymentapproved	bit,
			IsDocumentVerified	bit,
			IsRateVerified		bit default 0,
			IsPaid				bit,
			DriverHubKey		int,
			DriverHubName		varchar(100),
			MarketLocationKey	INT,
			MarketLocation		VARCHAR(200),
			PaidUserKey			int,
			PaidUserName		varchar(100),
			IsLinked			bit default 0, 
			LinkedContainerNo	varchar(20), 
			LinkedOrderDetailKey	int,
			LegID				VARCHAR(100),
			LegKey				int,
			ChargesCount		int,
			OrgName				VARCHAR(200)
	)

	Declare @OpenStatusKey smallint = 0;
	select @OpenStatusKey = Status from RouteStatus  WITH (NOLOCK) where Description = 'Leg Completed'

	SELECT StatusKey, [Description] AS StatusName INTO #VouchStatus
	FROM dbo.VoucherStatus WITH (NOLOCK)
	UNION ALL 
	SELECT 9,'PendingToProcess'

	print '@searchtext'
	print @searchtext
	IF @isDriverPay = 0
	BEGIN
	--FOR  @StatusKey IN (1,2,3,0)
	BEGIN
		insert into #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname,
		ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate,
		Workflow, LegTypeID,  DestinationCity, DocumentCount, weekNum, DriverKey, DriverHubName,
		IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts,
		WeekStart, WeekEnd,  IsPaid,  PaidDate, BrokerRefNo, VesselETA,DriverOrg,  DriverHubKey, MarketLocationKey,MarketLocation,
		PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey,LegID, Legkey,OrgName)

		SELECT distinct Case when OrdCount = 1 then OH.OrderKey else 0 end AS OrderKey,
			Case when ContCount = 1 then OD.OrderDetailKey else 0 end  AS OrderDetailKey,--oh.OrderNo,
		CASE WHEN OrdCount='1' THEN OrderNo ELSE 'Multiple Orders ('+CAST(OrdCount AS VARCHAR(50))+')' END AS OrderNo ,
		CASE WHEN ContCount='1' THEN ContNo ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo  ,--ContNo,		
		isnull(A.MinArrival,'2022-01-01') AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
		ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
		ISNULL(VH.[Statuskey],9)   AS StatusKey,
		VMT.VoucherAmt as VoucherAmount,0 AS RouteKey,
		NULL AS DestinationAddrKey,
		VH.VoucherKey,VH.VoucherNo,VH.VoucherDate,

		'' AS WorkFlow, '' as LegTypeID,'' AS City,  isnull(CDC.DocumentCount,0) 		as DocumentCount
		,'WK-' +  ISNULL(DVD.WeekNumber,CONVERT(VARCHAR,DATEPART(iso_week,A.MinArrival))) as WeekNum, 
		Rt.DriverKey,DH.DriverHubName
		,RT.IsDocumentVerified,IsRateVerified, NULL AS CompleteDate,'' DocCount, --OD.CompleteDate AS CompleteDate
		A.Week_Start_Date as [WeekStart],
		A.Week_End_Date as [WeekEnd],
		VH.IsPaid, VH.PaidDate,
		OH.BrokerRefNo, OD.VesselETA,
		 case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg,
		d.DriverHubKey AS DriverHubKey,
		ML.MarketLocationKey,ML.MarketLocation,
		VH.PaidUserKey, UI.UserID AS PaidUserName,
		OD.IsLinked, upper(OD.LinkedContainerNo), OD.LinkedOrderDetailKey,'' LegID, 0  as Legkey,OrgName
	FROM dbo.[routes] RT WITH (NOLOCK)
		INNER JOIN #IsDriverPayDriverKeys TD ON TD.DriverKey=RT.DriverKey
		INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN #OrderDetailKeys ODK	ON ODK.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN (select * from dbo.OrderHeader 	WITH (NOLOCK) 
			where isnull(@OrderKeys,'')  ='' OR OrderKey in (Select ORderKey from #OrderKey) ) OH ON oh.OrderKey = od.OrderKey
		INNER JOIN (select * from dbo.Driver D1	WITH (NOLOCK) 
			where isnull(@DriverKeys,'')  = '' OR D1.DriverKey in (select Driverkey from #DriverKey)
			) D		ON d.DriverKey = RT.DriverKey
		INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
		LEFT JOIN	Leg L				WITH (NOLOCK) ON L.LegKey = RT.LegKey
		LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
		LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey AND VH.VoucherDate > GetDate() -60
		LEFT JOIN #VoucherKey VK ON VK.VoucherKey = VH.VoucherKey
		LEft join UserInfo UI			WITH (NOLOCK) ON VH.PaidUserKey = UI.UserKey
		LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
		LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
		LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
		Left join dbo.vVoucherAmt VMT	 ON VH.VoucherKey = VMT.voucherKey
		LEft join vVoucherWeekNums A   on A.VoucherKey = VH.VoucherKey
		--****************Container Count************************
		LEFT JOIN vVoucherContainerCount DF  ON DF.VoucherKey=VH.VoucherKey	
		LEFT JOIN vVoucherContainers VF  ON VF.VoucherKey=VH.VoucherKey
		--**************Order Count**************************
		LEFT JOIN vVoucherOrderCount DK   ON DK.VoucherKey=VH.VoucherKey
		LEFT JOIN vVoucherMultiOrders VD  ON VD.VoucherKey=VH.VoucherKey
		--******************************
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
		Left join DriverHUB DH WITH (NOLOCK) on D.DriverHubKey = DH.DriverHubKey
		--Left join TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey =  D.TruckTypeKey
	   --LEFT JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.DriverKey=D.DriverKey
	   --Left join CarrierMoveType MT WITH (NOLOCK) ON MT.MoveTypeKey = DM.MoveTypeKey
	   LEFT JOIN DriverVoucher DVD WITH (NOLOCK) ON DVD.LinkedVoucherKey=VH.VoucherKey

	WHERE 	RTS.Status= @OpenStatusKey	and  VH.VoucherKey IS not NULL		
		AND VH.VoucherDate > GetDate() -60

	--	AND (  isnull(@DriverKeys,'')  = '' OR Rt.DriverKey in (select Driverkey from #DriverKey)  )
	--	AND (  isnull(@OrderKeys,'')  ='' OR OH.OrderKey in (Select ORderKey from #OrderKey) )
		AND	(  isnull(@OrderDateFrom,'')	= '' OR OH.OrderDate		IS NULL OR OH.OrderDate between @OrderDateFrom and @OrderDateTo)
		--AND	(  isnull(@DeliveryDateFrom	,'') = '' OR RT.DeliveryDateFrom is null OR RT.DeliveryDateFrom between @DeliveryDateFrom and @DeliveryDateTo)
		--AND (  isnull(@OrderNo	,'')		= '' OR OH.OrderNo		IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
		AND (  isnull(@containerNo ,'')		= '' OR OD.ContainerNo	IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
		--AND (  isnull(@voucherNo,'')		= '' OR VH.VoucherNo is null OR ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%')

		--AND ( isnull(@searchtext,'') = '' OR 
		--	(   OH.OrderNo like '%' + @searchtext + '%' OR 
		--		OD.ContainerNo like '%' +  @searchtext + '%' OR 
		--		ISNULL(VH.VoucherNo,'NA') like '%' + @searchtext + '%') ) 

		--AND (  isnull(@VoucherKeys,'') 		= '' OR Vh.VoucherKey in (select voucherkey from #voucherKey) )
		AND (  isnull(@DriverHubkeys,'')  = '' OR D.DriverHubKey in (Select DriverhubKey from #DriverHubKey))
		AND (  ISNULL(@marketLocationKeys,'') = '' OR  OH.MarketLocationKey in (Select MarketLocationKey From #MarketLocationKey) )
		AND (  ISNULL(@TruckTypeKeys,'') = '' OR  D.TruckTypeKey in (Select TruckTypeKey From #TruckTypeKey) )
		AND (@IsSearchActive = 0 OR ODK.OrderDetailKey IS NOT NULL OR VK.VoucherKey IS NOT NULL)
		--AND (  ISNULL(@CarrierMoveTypeKeys,'') = ''  OR MT.MoveTypeKey in (Select MoveTypeKey From #CarrierMoveTypeKey) )

	END

	IF(@IsDebug = 1)
	BEGIN		
		SELECT '#TEMPTABLE_1st_Query', * FROM #TEMPTABLE
	END

	--FOR (@StatusKey in (0,9))
	BEGIN
		if(isnull(@voucherNo,'') = '')
		Begin
		insert into #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname,
		ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate,
		Workflow, LegTypeID,  DestinationCity, DocumentCount, weekNum,DriverKey,DriverHubName,
		IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts,
		WeekStart, WeekEnd,  IsPaid,  PaidDate, BrokerRefNo, VesselETA,DriverOrg,  DriverHubKey, MarketLocationKey,MarketLocation,
		PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, LegID, Legkey, OrgName)
		SELECT OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,RT.ActualArrival AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
			0 AS IsPaymentApproved, 
			9   AS StatusKey,
			0 VoucherAmount,RT.RouteKey,RT.DestinationAddrKey,null VoucherKey,'' VoucherNo,null VoucherDate
			,L.Instruction AS WorkFlow, LG.LegID as LegTypeID,DST.City, isnull(CDC.DocumentCount,0) as DocumentCount --
			, 'WK-' +  convert(varchar,DatePArt(iso_week,RT.ActualArrival)) as WeekNum, RT.DriverKey,DH.DriverHubName
			,RT.IsDocumentVerified,IsRateVerified,OD.CompleteDate,'' as DocCount,
			A.Week_Start_Date as [WeekStart],
			A.Week_End_Date [WeekEnd],
			0 as IsPaid, null as PaidDate,OH.BrokerRefNo, OD.VesselETA,
			 case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg,
					d.DriverHubKey AS DriverHubKey,
			ML.MarketLocationKey,ML.MarketLocation,
					'' PaidUserKey,'' AS PaidUserName,
					OD.IsLinked, upper(OD.LinkedContainerNo), OD.LinkedOrderDetailKey, LG.LegID,
					RT.LegKey as Legkey,D.OrgName
		--INTO #TEMPVOUCHER2
		FROM vPendingRoutesToVoucher PV WITH (NOLOCK)
			inner join dbo.[routes] RT WITH (NOLOCK) ON PV.routeKey = RT.RouteKey
			INNER JOIN #IsDriverPayDriverKeys TD ON TD.DriverKey=RT.DriverKey
			INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
			INNER JOIN dbo.OrderHeader oh	WITH (NOLOCK) ON oh.OrderKey = od.OrderKey
			INNER JOIN dbo.Leg LG			WITH (NOLOCK) ON LG.LegKey = RT.LegKey
			INNER JOIN dbo.LegType L		WITH (NOLOCK) ON L.LegtypeKey = LG.LegTypeKey
			INNER JOIN dbo.Driver d			WITH (NOLOCK) ON d.DriverKey = RT.DriverKey
			INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status] and rts.Status = @OpenStatusKey
			--LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
			--LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
			--LEft join UserInfo UI			WITH (NOLOCK) ON VH.PaidUserKey = UI.UserKey
			--LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
			LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
			LEFT JOIN ContainerDocumentCount CDC	WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
			--LEFT JOIN dbo.VRouteDocumentCount V		WITH (NOLOCK) ON V.RouteKey=RT.RouteKey
			cross apply dbo.fn_getIsoWeekStartEndDates(RT.ActualArrival) A 
			LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
			LEFT JOIN DriverHUB  DH WITH (NOLOCK) on D.DriverHubKey = DH.DriverHubKey
			--Left join TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey =  D.TruckTypeKey
		    --LEFT JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.DriverKey=D.DriverKey
		    --Left join CarrierMoveType MT WITH (NOLOCK) ON MT.MoveTypeKey = DM.MoveTypeKey
		WHERE 	 --VH.VoucherKey IS NULL AND 
				RT.ActualArrival IS NOT NULL	
			AND (  isnull(@DriverKeys,'')  = '' OR Rt.DriverKey in (select Driverkey from #DriverKey)  )
			AND (  isnull(@OrderKeys,'')  ='' OR OH.OrderKey in (Select ORderKey from #OrderKey) )
			AND	(  @OrderDateFrom	IS NULL OR (OH.OrderDate between @OrderDateFrom and @OrderDateTo))
			AND	(  @DeliveryDateFrom	IS NULL OR NULLIF(RT.DeliveryDateFrom, '1900-01-01 00:00:00') is null OR RT.DeliveryDateFrom between @DeliveryDateFrom and @DeliveryDateTo)
			--AND (  @OrderNo			= '' OR (OH.OrderNo like '%' + @OrderNo + '%' ))
			AND (  @containerNo		= '' OR (OD.ContainerNo like '%' +  @containerNo + '%' ))
			--AND (  isnull(@VoucherKeys,'') 		= '' OR Vh.VoucherKey in (select voucherkey from #voucherKey) )
			AND (  ISNULL(@marketLocationKeys,'') = '' OR  OH.MarketLocationKey in (Select MarketLocationKey From #MarketLocationKey) )
			--AND ( isnull(@searchtext,'') = '' OR 
			--(   OH.OrderNo like '%' + @searchtext + '%' OR 
			--	OD.ContainerNo like '%' +  @searchtext + '%' ) ) 
			AND (  ISNULL(@TruckTypeKeys,'') = '' OR  D.TruckTypeKey in (Select TruckTypeKey From #TruckTypeKey) )
			AND (@IsSearchActive = 0 OR OD.OrderDetailKey IN (SELECT OrderDetailKey FROM #OrderDetailKeys))
			--AND (  ISNULL(@CarrierMoveTypeKeys,'') = ''  OR MT.MoveTypeKey in (Select MoveTypeKey From #CarrierMoveTypeKey) )
		End
	END
	END

	if(@isDriverPay=1)
	BEGIN
		insert into #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname,
		ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate,
		Workflow, LegTypeID,  DestinationCity, DocumentCount, weekNum, DriverKey, DriverHubName,
		IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts,
		WeekStart, WeekEnd,  IsPaid,  PaidDate, BrokerRefNo, VesselETA,DriverOrg,  DriverHubKey, MarketLocationKey,MarketLocation,
		PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey,LegID, Legkey,OrgName)

		SELECT distinct Case when OrdCount = 1 then OH.OrderKey else 0 end AS OrderKey,
			Case when ContCount = 1 then OD.OrderDetailKey else 0 end  AS OrderDetailKey,--oh.OrderNo,
		CASE WHEN OrdCount=1 THEN OrderNo ELSE 'Multiple Orders ('+CAST(OrdCount AS VARCHAR(50))+')' END AS OrderNo ,
		CASE WHEN ContCount=1 THEN ContNo ELSE 'Multiple Containers ('+CAST(ContCount AS VARCHAR(50))+')' END AS ContainerNo  ,--ContNo,		
		isnull(A.MinArrival,'2022-01-01') AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
		ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
		ISNULL(VH.[Statuskey],9)   AS StatusKey,
		VMT.VoucherAmt as VoucherAmount,0 AS RouteKey,
		NULL AS DestinationAddrKey,
		VH.VoucherKey,ISNULL(DV.DriverVoucherNumber,VH.VoucherNo) VoucherNo,VH.VoucherDate,

		'' AS WorkFlow, '' as LegTypeID,'' AS City,  isnull(CDC.DocumentCount,0) 		as DocumentCount
		,'WK-' +  CONVERT(VARCHAR,DATEPART(iso_week,A.MinArrival)) as WeekNum, Rt.DriverKey,DH.DriverHubName
		,RT.IsDocumentVerified,IsRateVerified, NULL AS CompleteDate,'' DocCount, --OD.CompleteDate AS CompleteDate
		A.Week_Start_Date as [WeekStart],
		A.Week_End_Date as [WeekEnd],
		VH.IsPaid, VH.PaidDate,
		OH.BrokerRefNo, OD.VesselETA,
		 case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end  as DriverOrg,
		d.DriverHubKey AS DriverHubKey,
		ML.MarketLocationKey,ML.MarketLocation,
		VH.PaidUserKey, UI.UserID AS PaidUserName,
		OD.IsLinked, upper(OD.LinkedContainerNo), OD.LinkedOrderDetailKey,'' LegID, 0  as Legkey,OrgName
	FROM dbo.[routes] RT WITH (NOLOCK)
		INNER JOIN #IsDriverPayDriverKeys TD ON TD.DriverKey=RT.DriverKey
		INNER JOIN dbo.OrderDetail od	WITH (NOLOCK) ON RT.OrderDetailKey = od.OrderDetailkey
		LEFT JOIN #OrderDetailKeys ODK	ON ODK.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN (select * from dbo.OrderHeader 	WITH (NOLOCK) 
			where isnull(@OrderKeys,'')  ='' OR OrderKey in (Select ORderKey from #OrderKey) ) OH ON oh.OrderKey = od.OrderKey
		INNER JOIN (select * from dbo.Driver D1	WITH (NOLOCK) 
			where isnull(@DriverKeys,'')  = '' OR D1.DriverKey in (select Driverkey from #DriverKey)
			) D		ON d.DriverKey = RT.DriverKey
		INNER JOIN dbo.RouteStatus RTS	WITH (NOLOCK) ON RTS.[Status]=RT.[Status]
		LEFT JOIN	Leg L				WITH (NOLOCK) ON L.LegKey = RT.LegKey
		LEFT JOIN RouteVouchers RV		WITH (NOLOCK) ON RV.RouteKey=RT.RouteKey
		LEFT JOIN VoucherHeader VH		WITH (NOLOCK) ON VH.VoucherKey=RV.VoucherKey
		LEFT Join DriverVoucher DV WITH (NOLOCK) ON DV.LinkedVoucherKey=VH.VoucherKey
		LEFT JOIN #VoucherKey VK ON VK.VoucherKey = VH.VoucherKey
		LEft join UserInfo UI			WITH (NOLOCK) ON VH.PaidUserKey = UI.UserKey
		LEFT JOIN dbo.VoucherStatus VS	WITH (NOLOCK) ON VS.[StatusKey]=VH.[StatusKey]
		LEFT JOIN dbo.[Address] DST		WITH (NOLOCK) ON DST.AddrKey=RT.DestinationAddrKey
		LEFT JOIN ContainerDocumentCount CDC WITH (NOLOCK) ON OD.OrderDetailKey = CDC.OrderDetailKey
		Left join dbo.vVoucherAmt VMT	 ON VH.VoucherKey = VMT.voucherKey
		LEft join vVoucherWeekNums A   on A.VoucherKey = VH.VoucherKey
		--****************Container Count************************
		LEFT JOIN vVoucherContainerCount DF  ON DF.VoucherKey=VH.VoucherKey	
		LEFT JOIN vVoucherContainers VF  ON VF.VoucherKey=VH.VoucherKey
		--**************Order Count**************************
		LEFT JOIN vVoucherOrderCount DK   ON DK.VoucherKey=VH.VoucherKey
		LEFT JOIN vVoucherMultiOrders VD  ON VD.VoucherKey=VH.VoucherKey
		--******************************
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
		Left join DriverHUB DH WITH (NOLOCK) on D.DriverHubKey = DH.DriverHubKey
		--Left join TruckType TT WITH (NOLOCK) ON TT.TruckTypeKey =  D.TruckTypeKey
	   --LEFT JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.DriverKey=D.DriverKey
	   --Left join CarrierMoveType MT WITH (NOLOCK) ON MT.MoveTypeKey = DM.MoveTypeKey

		WHERE 	RTS.Status= @OpenStatusKey	and  VH.VoucherKey IS not NULL		
		AND VH.VoucherDate > GetDate() -90

	--	AND (  isnull(@DriverKeys,'')  = '' OR Rt.DriverKey in (select Driverkey from #DriverKey)  )
	--	AND (  isnull(@OrderKeys,'')  ='' OR OH.OrderKey in (Select ORderKey from #OrderKey) )
		AND	(  isnull(@OrderDateFrom,'')	= '' OR OH.OrderDate		IS NULL OR OH.OrderDate between @OrderDateFrom and @OrderDateTo)
		--AND	(  isnull(@DeliveryDateFrom	,'') = '' OR RT.DeliveryDateFrom is null OR RT.DeliveryDateFrom between @DeliveryDateFrom and @DeliveryDateTo)
		--AND (  isnull(@OrderNo	,'')		= '' OR OH.OrderNo		IS NULL OR OH.OrderNo like '%' + @OrderNo + '%' )
		AND (  isnull(@containerNo ,'')		= '' OR OD.ContainerNo	IS NULL OR OD.ContainerNo like '%' +  @containerNo + '%' )
		--AND (  isnull(@voucherNo,'')		= '' OR VH.VoucherNo is null OR ISNULL(VH.VoucherNo,'NA') like '%' + @voucherNo + '%')

		--AND ( isnull(@searchtext,'') = '' OR 
		--	(   OH.OrderNo like '%' + @searchtext + '%' OR 
		--		OD.ContainerNo like '%' +  @searchtext + '%' OR 
		--		ISNULL(VH.VoucherNo,'NA') like '%' + @searchtext + '%') ) 

		--AND (  isnull(@VoucherKeys,'') 		= '' OR Vh.VoucherKey in (select voucherkey from #voucherKey) )
		AND (  isnull(@DriverHubkeys,'')  = '' OR D.DriverHubKey in (Select DriverhubKey from #DriverHubKey))
		AND (  ISNULL(@marketLocationKeys,'') = '' OR  OH.MarketLocationKey in (Select MarketLocationKey From #MarketLocationKey) )
		AND (  ISNULL(@TruckTypeKeys,'') = '' OR  D.TruckTypeKey in (Select TruckTypeKey From #TruckTypeKey) )
		AND (@IsSearchActive = 0 OR ODK.OrderDetailKey IS NOT NULL OR VK.VoucherKey IS NOT NULL)
	END

	--IF @isDriverPay = 1
 --   BEGIN
 --       INSERT INTO #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname, ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate, Workflow, LegTypeID, DestinationCity, DocumentCount, weekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate, BrokerRefNo, VesselETA, DriverOrg, DriverHubKey, MarketLocationKey, MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, LegID, Legkey, OrgName)
 --       SELECT 0, 0, '', DV.ContainerNo, '1900-01-01', D.DriverID, D.FirstName, D.LastName, 0, 0, ISNULL(DriverVoucherAmount, 0), 0, 0, DV.DriverVoucherKey, DriverVoucherNumber, DV.DriverVoucherdate, '', '', '', 0, 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, DV.DriverVoucherdate)), DV.DriverKey, DH.DriverHubName, 0, 0, NULL, '', '1900-01-01', '1900-01-01', 0, DV.DriverVoucherdate, '', NULL, '', D.DriverHubKey, ISNULL(D.MarketLocationKey, 0), '', DV.CreateUser, '', 0, '', 0, '', 0, D.OrgName
 --       FROM dbo.DriverVoucher DV WITH (NOLOCK) INNER JOIN dbo.Driver D WITH (NOLOCK) ON D.DriverKey = DV.DriverKey LEFT JOIN dbo.DriverHUB DH WITH (NOLOCK) ON DH.DriverHubKey = D.DriverHubKey
 --       WHERE DV.DriverVoucherdate > DATEADD(DAY, -60, GETDATE()) AND (ISNULL(@DriverKeys, '') = '' OR DV.DriverKey IN (SELECT DriverKey FROM #DriverKey)) AND (ISNULL(@WeekNum, '') = '' OR 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, DV.DriverVoucherdate)) = @WeekNum) AND (@IsSearchActive = 0 OR DV.ContainerNo IN (SELECT OD.ContainerNo FROM #OrderDetailKeys ODK INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON ODK.OrderDetailKey = OD.OrderDetailKey)) AND (@containerNo = '' OR DV.ContainerNo LIKE '%' + @containerNo + '%');
 --   END

	/*
	update A set ChargesCount = isnull(B.ChargeCount,0),
		IsRateVerified = case when StatusKey = 9 then 
			case when isnull(B.ChargeCount,0) > 0 then 1 else 0 end
			else IsRateVerified end
	--select *
	from #TEMPTABLE A
	inner join (
		select T.orderdetailkey, count(1) as ChargeCount
		from #TEMPTABLE T
		inner join OrderExpense OE on T.orderdetailkey = OE.OrderDetailKey
		inner join Item I on OE.itemkey = I.ItemKey
		where I.ItemTypeKey in (4,5)
		Group by T.orderdetailkey
	) B on A.orderdetailkey = B.orderdetailkey
	*/
	update #TEMPTABLE set IsRateVerified = 0 where StatusKey = 9

	if(@IsDebug = 1)
	Begin
		Select '#TEMPTABLE1', * from #TEMPTABLE
	END


	--IF @isDriverPay = 1
 --   BEGIN
 --       INSERT INTO #TEMPTABLE (orderkey, orderdetailkey, orderno, containerno, ActualDeparture, driverid, firstname, lastname, ispaymentapproved, StatusKey, voucheramount, routekey, destinationaddrkey, voucherkey, voucherno, voucherdate, Workflow, LegTypeID, DestinationCity, DocumentCount, weekNum, DriverKey, DriverHubName, IsDocumentVerified, IsRateVerified, CompleteDate, DocCounts, WeekStart, WeekEnd, IsPaid, PaidDate, BrokerRefNo, VesselETA, DriverOrg, DriverHubKey, MarketLocationKey, MarketLocation, PaidUserKey, PaidUserName, IsLinked, LinkedContainerNo, LinkedOrderDetailKey, LegID, Legkey, OrgName)
 --       SELECT 0, 0, '', DV.ContainerNo, '1900-01-01', D.DriverID, D.FirstName, D.LastName, 0, @StatusKey, ISNULL(DriverVoucherAmount, 0), 0, @StatusKey, DV.DriverVoucherKey, DriverVoucherNumber, DV.DriverVoucherdate, '', '', '', 0, 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, DV.DriverVoucherdate)), DV.DriverKey, DH.DriverHubName, 0, 0, NULL, '', '1900-01-01', '1900-01-01', 0, DV.DriverVoucherdate, '', NULL, '', D.DriverHubKey, ISNULL(D.MarketLocationKey, 0), '', DV.CreateUser, '', 0, '', 0, '', 0, D.OrgName
 --       FROM dbo.DriverVoucher DV WITH (NOLOCK) INNER JOIN dbo.Driver D WITH (NOLOCK) ON D.DriverKey = DV.DriverKey LEFT JOIN dbo.DriverHUB DH WITH (NOLOCK) ON DH.DriverHubKey = D.DriverHubKey
 --       WHERE DV.DriverVoucherdate > DATEADD(DAY, -60, GETDATE()) AND (ISNULL(@DriverKeys, '') = '' OR DV.DriverKey IN (SELECT DriverKey FROM #DriverKey)) AND (ISNULL(@WeekNum, '') = '' OR 'WK-' + CONVERT(VARCHAR, DATEPART(iso_week, DV.DriverVoucherdate)) = @WeekNum) AND (@IsSearchActive = 0 OR DV.ContainerNo IN (SELECT OD.ContainerNo FROM #OrderDetailKeys ODK INNER JOIN dbo.OrderDetail OD WITH (NOLOCK) ON ODK.OrderDetailKey = OD.OrderDetailKey)) AND (@containerNo = '' OR DV.ContainerNo LIKE '%' + @containerNo + '%');
 --   END
	--IF (@isDriverPay = 1)
	--BEGIN
	--	DELETE FROM #TEMPTABLE
	--	WHERE TRY_CAST(
	--			  LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1
	--		  ) AS INT) NOT BETWEEN 700 AND 948;
	--END
	--ELSE IF (@isDriverPay = 0)
	--BEGIN
	--	DELETE FROM #TEMPTABLE
	--	WHERE TRY_CAST(
	--			  LEFT(DRIVERID, PATINDEX('%[^0-9]%', DRIVERID + 'A') - 1
	--		  ) AS INT) BETWEEN 700 AND 948;
	--END

	update A set ChargesCount = isnull(B.ChargeCount,0),
		IsRateVerified = case when StatusKey = 9 then 
			case when isnull(B.ChargeCount,0) > 0 then 1 else 0 end
			else IsRateVerified end
	--select *
	from #TEMPTABLE A
	inner join (
		select T.Routekey, count(1) as ChargeCount
		from #TEMPTABLE T
		inner join OrderExpense OE WITH (NOLOCK) on T.Routekey = OE.Routekey
		inner join Item I WITH (NOLOCK) on OE.itemkey = I.ItemKey
		where I.ItemTypeKey in (4,5)
		Group by T.Routekey
	) B on A.Routekey = B.Routekey

	if(@IsDebug = 1)
	Begin
		Select Statuskey, count(1) from #TEMPTABLE Group by StatusKey
		Select '#TEMPTABLE', count(1) from #TEMPTABLE
		Select '#TEMPTABLE', * from #TEMPTABLE
	End


	
	Select T.StatusKey, count(1) as cnt 
	INTO #Status
	from  #TEMPTABLE T 
	group by T.StatusKey

	Create table #Dashboard
	(
		StatusKey	int,
		StatusName	varchar(50),
		StatusCount	int
	)

	insert into #Dashboard (StatusKey, StatusName, StatusCount)
	Select VS.StatusKey as Statuskey, VS.Description as StatusName ,0 as StatusCount
	from VoucherStatus VS  WITH (NOLOCK)	
	
	
	insert into #DashBoard 
	select 9, 'Open', 0

	update D SEt StatusCount = isnull(T.cnt,0)
	from #DashBoard D
	Left join #Status T on D.StatusKey = T.StatusKey

	insert into #DashBoard
	select 0, 'All', ISNULL(sum(isnull(StatusCount,0) ),0) from #DashBoard

	if(@IsDebug = 1)
	Begin
		Select '#DashBoard', * from #DashBoard
	End

	SELECT 
				ISNULL(orderkey,0) AS orderkey,
				ISNULL(orderdetailkey,0) AS orderdetailkey,
				ISNULL(voucheramount,0) AS voucheramount,
				ISNULL(routekey,0) AS routekey,
				ISNULL(destinationaddrkey,0) AS destinationaddrkey,
				ISNULL(voucherkey,0) AS voucherkey,
				ISNULL(StatusKey,0) AS StatusKey,
				ISNULL(DocumentCount,0) AS DocumentCount,
				ISNULL(DocCounts,0) AS DocCounts,

				ISNULL(orderno,'') AS orderno,
				ISNULL(containerno,'') AS containerno,
				ISNULL(driverid,'') AS driverid,
				ISNULL(firstname,'') AS firstname,
				ISNULL(lastname,'') AS lastname,
				ISNULL(firstname,'') + ' ' + ISNULL(lastname,'') as DriverName,
				DriverKey,
				ISNULL(voucherno,'') AS voucherno,
				ISNULL(LegTypeID,'') AS LegTypeID,
				ISNULL(Workflow,'') AS Workflow,
				ISNULL(DestinationCity,'') AS DestinationCity,
				ISNULL(weekNum,'') AS weekNum,
				ISNULL(DriverOrg,'') AS DriverOrg,
				ISNULL(BrokerRefNo,'') AS BrokerRefNo,
				ISNULL(VesselETA,'') AS VesselETA,

				convert(datetime,isnull(ActualDeparture,'01-01-1900')) as ActualDeparture,
				convert(datetime,isnull(voucherdate,'01-01-1900')) as voucherdate,
				convert(datetime,isnull(WeekStart,'01-01-1900')) as WeekStart,
				convert(datetime,isnull(WeekEnd,'01-01-1900')) as WeekEnd,
				convert(datetime,isnull(PaidDate,'01-01-1900')) as PaidDate,

				ISNULL(ispaymentapproved,convert(bit,0)) as ispaymentapproved,
				ISNULL(IsDocumentVerified,convert(bit,0)) as IsDocumentVerified,
				ISNULL(IsRateVerified,convert(bit,0)) as IsRateVerified,
				ISNULL(IsPaid,convert(bit,0)) as IsPaid,
				ISNULL(DriverHubKey,0) AS DriverHubKey,
				DriverHubName,
				ISNULL(MarketLocationKey,0) AS MarketLocationKey,
				MarketLocation,
				PaidUserKey,
				PaidUserName,
				IsLinked, LinkedContainerNo, LinkedOrderDetailKey, ISNULL(LegID,'') LegID,
				LegKey,ISNULL(ChargesCount,0) ChargesCount,OrgName
			Into #TempPrev
			FROM  #TEMPTABLE
			WHERE   (ISNULL(@WeekNum, '')='' OR weekNum =@WeekNum) 
			AND 	(  @StatusKey = 0 OR  ISNULL(Statuskey,9) = @StatusKey )

		if(@IsDebug = 1)
		Begin
			select '#TempPrev', count(1) from #TempPrev
		End

		Declare @STRSQL nvarchar(max) = ''
		SET @STRSQL = 'SELECT *,  ROW_NUMBER() over (Order by ' + @SortField + ' ' + 
		CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' ) as RowNum FROM  #TempPrev'

		print @STRSQL
		select *, convert(int, 0) as RowNum into  #FinalData_Temp from #TempPrev WHERE 1 <> 1 

		insert into #FinalData_Temp
		EXEC (@STRSQL)

		if(@IsDebug = 1)
		Begin
			select '#FinalData_Temp', count(1) from #FinalData_Temp
		End

		Declare @RecCount	int = 0
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
		/*
		---addedd for driverpay driver voucher data
		SELECT  0 AS orderkey,
				0 AS orderdetailkey,
				isnull(DriverVoucherAmount,0) AS voucheramount,
				0 AS routekey,
				0 AS destinationaddrkey,
				DV.DriverVoucherKey AS voucherkey,
				CAST(0 AS smallint) AS StatusKey,
				0 AS DocumentCount,
				'' AS DocCounts,
				'' AS orderno,
				ContainerNo AS containerno,
				D.DriverID AS driverid,
				D.FirstName AS firstname,
				D.LastName AS lastname,
				ISNULL(firstname,'') + ' ' + ISNULL(lastname,'') as DriverName,
				DV.DriverKey DriverKey,
				DriverVoucherNumber AS voucherno,
				'' AS LegTypeID,
				'' AS Workflow,
				'' AS DestinationCity,
				'WK-' +  convert(varchar,DatePArt(iso_week,DV.DriverVoucherdate)) as WeekNum,
				'' AS DriverOrg,
				'' AS BrokerRefNo,
				'' AS VesselETA,
				convert(datetime,'01-01-1900') as ActualDeparture,
				convert(datetime,isnull(DriverVoucherdate,'01-01-1900')) as voucherdate,
				convert(datetime,'01-01-1900') as WeekStart,
				convert(datetime,'01-01-1900') as WeekEnd,
				convert(datetime,isnull(DriverVoucherdate,'01-01-1900')) as PaidDate,
				--convert(datetime,'01-01-1900') as PaidDate,
				convert(bit,0) as ispaymentapproved,
				convert(bit,0) as IsDocumentVerified,
				convert(bit,0) as IsRateVerified,
				convert(bit,0) as IsPaid,
				D.DriverHubKey AS DriverHubKey,
				DH.DriverHubName DriverHubName,
				ISNULL(D.MarketLocationKey,0) AS MarketLocationKey,
				'' MarketLocation,
				DV.CreateUser PaidUserKey,
				'' PaidUserName,
				CAST(0 AS BIT)IsLinked, '' LinkedContainerNo, 0 LinkedOrderDetailKey, '' LegID,
				0 LegKey,0 ChargesCount,OrgName, 0 as rownum, 0 AS RecCount 
				INTO #DriverVoucher_data
				FROM DriverVoucher DV
				--INNER JOIN DriverVoucherDetail DVD WITH (NOLOCK) ON (DV.DriverVoucherKey=DVD.DriverVoucherKey)
				INNER JOIN Driver D WITH (NOLOCK) ON D.DriverKey=DV.DriverKey AND DV.DriverVoucherdate > GetDate() - 30
				INNER JOIN #IsDriverPayDriverKeys TD ON TD.DriverKey=D.DriverKey
				LEFT JOIN DriverHUB DH WITH (NOLOCK) ON DH.DriverHubKey=D.DriverHubKey
				LEft join [User] U WITH (NOLOCK) ON DV.CreateUser = U.UserKey
				WHERE (DV.DriverKey in(SELECT DriverKey FROM #DriverKey)  OR ISNULL(@DriverKeys,'')='')
				--AND DV.DriverVoucherdate > GetDate() - 30
				AND   (isnull(@WeekNum,'') = '' OR 'WK-' +  convert(varchar,DatePArt(iso_week,DV.DriverVoucherdate)) = @WeekNum)	
				AND (@IsSearchActive = 0 OR DV.ContainerNo IN (SELECT OD.ContainerNo FROM #OrderDetailKeys ODK INNER JOIN OrderDetail OD ON ODK.OrderDetailKey = OD.OrderDetailKey))
				AND @isDriverPay=1
				--AND (  isnull(@DriverKeys,'')  = '' OR D.DriverKey in (select Driverkey from #DriverKey)  )
			--AND (  isnull(@OrderKeys,'')  ='' OR OH.OrderKey in (Select ORderKey from #OrderKey) )
			--AND	(  @OrderDateFrom	IS NULL OR (OH.OrderDate between @OrderDateFrom and @OrderDateTo))
			--AND	(  @DeliveryDateFrom	IS NULL OR RT.DeliveryDateFrom is null OR RT.DeliveryDateFrom between @DeliveryDateFrom and @DeliveryDateTo)
			--AND (  @OrderNo			= '' OR (OH.OrderNo like '%' + @OrderNo + '%' ))
			AND (  @containerNo		= '' OR (DV.ContainerNo like '%' +  @containerNo + '%' ))
			--AND (  isnull(@VoucherKeys,'') 		= '' OR Vh.VoucherKey in (select voucherkey from #voucherKey) )
			--AND (  ISNULL(@marketLocationKeys,'') = '' OR  OH.MarketLocationKey in (Select MarketLocationKey From #MarketLocationKey) )
			--AND ( isnull(@searchtext,'') = '' OR 
			--(   
			--	DV.ContainerNo like '%' +  @searchtext + '%' ) ) 
			--AND (  ISNULL(@TruckTypeKeys,'') = '' OR  D.TruckTypeKey in (Select TruckTypeKey From #TruckTypeKey) )
			ORDER BY voucherkey, containerno, orderkey, orderdetailkey
		--Select * from #FinalData_Output
		--SELECT * FROM #DriverVoucher_data
		---end
		**/
		select VoucherList = (
			SELECT *
			FROM
			(
				Select * from #FinalData_Output
				--UNION ALL
				--SELECT * FROM #DriverVoucher_data
			) AS U
			FOR JSON PATH
		), 
		DropDowns = ( SELECT
			--CarrierList = (Select DISTINCT DriverKey, DriverName FROM 
			--				(Select distinct DriverKey, driverid AS DriverName from  #TempPrev where isnull(DriverName,'')<>'' 
			--				UNION ALL Select distinct DriverKey, driverid AS DriverName from  #DriverVoucher_data where isnull(DriverName,'')<>'' ) A ORDER BY DriverName
			--				FOR JSON PATH),
			CarrierList = (Select distinct DriverKey, driverid AS DriverName from  #TempPrev where isnull(DriverName,'')<>'' 
							 ORDER BY DriverName
							FOR JSON PATH),
			DriverHubList = (SElect distinct DriverHubKey,DriverHubName from #TempPrev where isnull(DriverHubName,'')<>'' Order by DriverHubName For JSON PATH ),
			MarketLocList = (SElect distinct MarketLocation, MarketLocationKey from #TempPrev  where isnull(MarketLocation,'')<>'' Order by MarketLocation For JSON PATH ),
			TruckTypeList = (SElect distinct TruckTypeKey, TruckType from TruckType  WITH (NOLOCK)  where isnull(TruckType,'')<>'' Order by TruckType For JSON PATH ),
			MoveTypeList = (SElect distinct MoveTypeKey, MoveTypeName from CarrierMoveType  WITH (NOLOCK)  where isnull(MoveTypeName,'')<>'' Order by MoveTypeName For JSON PATH )
			FOR JSON PATH
		),
		Dashboard = (
			Select * from #DashBoard
			For JSON PATH
		)
		FOR JSON PATH
	--	INSERT INTO SqlExecutionTimeLog
	--(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	--VALUes (@UserKey,'Get_VoucherList_V2','Procedure Execution end','',GETDATE())
		Set @Status = 1
		SEt @Reason = 'Success'

		drop table #DashBoard
		drop table #DriverHubKey
		drop table #DriverKey
		drop table #FinalData_Output
		drop table #FinalData_Temp
		drop table #MarketLocationKey
		drop table #OrderKey
		drop table #Status
		drop table #TempPrev
		drop table #TEMPTABLE
		drop table #voucherKey
		drop table #VouchStatus
		--drop table #DriverVoucher_data
END
