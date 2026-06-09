/* 

DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)= 
	'{"ContainerNo":"","RouteStatusKeys":4,"StatusSelected":0,"CarrierAssignedBy":"","PickupDate":"","DeliveryDate":"","IsEmpty":-1,"CustomerKeys":"","ChassisTypeKeys":"","PropertyKeys":"","PageNo":2,"PageSize":10,"IsAscending":true,"SortField":"","OutputType":"","SearchText":""}',
	@Status			BIT=0, @IsDebug		BIT = 1, @Reason			VARCHAR(100)=''
	EXec [Dispatch_GetActions] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status, @Reason

*/

CREATE PROCEDURE [dbo].[Dispatch_GetActions]
(
	@UserKey		INT = 0,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON

	/* ---- DO NOT DELETE-------------
	**********StatusSelected***********
	1. - Assign Carrier
	2. - Confirm Delivery
	3. - Assign Chassis
	4. - Confirm Pickup

	*/

	Declare
		@ContainerNo		varchar(50) = '',	
		@RouteStatusKeys	INT = 0,
		@StatusSelected	INT = 0,
		@CarrierAssignedBy	varchar(50) = '',
		@PickupDate			VARCHAR(50) = '',
		@DeliveryDate		VARCHAR(50) = '',
		@IsEmpty			SmallInt = -1,
		@CustomerKeys		varchar(1000) = '',  -- comma separated User keys
		@ChassisTypeKeys	varchar(1000) = '',  -- comma separated User keys
		@PropertyKeys		varchar(200) = '',  -- Comma seperated Container Props Keys
		@PageNo				INT = 1,
		@PageSize			INT	= 10,
		@IsAscending		BIT = 1,
		@SortField			VARCHAR(50) = '',
		@OutputType			VARCHAR(20),
		@SearchText			VARCHAR(50) =''

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	SELECT 
		@ContainerNo		=	ContainerNo,		
		@RouteStatusKeys	=	RouteStatusKeys,
		@StatusSelected	=	StatusSelected,
		@CarrierAssignedBy	=	CarrierAssignedBy,
		@PickupDate			=	PickupDate,
		@DeliveryDate		=	DeliveryDate,
		@IsEmpty			=	IsEmpty,
		@CustomerKeys		=	CustomerKeys,
		@ChassisTypeKeys	=	ChassisTypeKeys,
		@PropertyKeys		=	PropertyKeys ,
		@PageNo				=	PageNo,		
		@PageSize			=	PageSize,	
		@IsAscending		=	IsAscending,
		@SortField			=	SortField,	
		@outputType			=	outputType,
		@SearchText			=	SearchText
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		ContainerNo			varchar(50)		'$.ContainerNo',
		RouteStatusKeys		INT			    '$.RouteStatusKeys',
		StatusSelected	INT				'$.StatusSelected',
		CarrierAssignedBy	varchar(50)		'$.CarrierAssignedBy',
		PickupDate			VARCHAR(50)		'$.PickupDate',
		DeliveryDate		VARCHAR(50)		'$.DeliveryDate',
		IsEmpty				SMALLINT		'$.IsEmpty',
		CustomerKeys		varchar(1000)	'$.CustomerKeys',
		ChassisTypeKeys		VARCHAR(50)		'$.ChassisTypeKeys',
		PropertyKeys		varchar(500)	'$.PropertyKeys',
		PageNo				INT				'$.PageNo',
		PageSize			INT				'$.PageSize',
		IsAscending			BIT				'$.IsAscending',
		SortField			VARCHAR(50)		'$.SortField',
		outputType			VARCHAR(20)		'$.outputType',
		SearchText			VARCHAR(50)		'$.SearchText'
	)

	IF((isnull(@SortField,'')='') or @SortField='')
	BEGIN
		SET @SortField = 'ContainerNo';
	END

	--SELECT '@SortField' , @SortField

	if(@IsDebug = 1)
	Begin
		SELECT 'Parameters' AS Params,
		@ContainerNo		AS	ContainerNo,		
		@RouteStatusKeys	AS	RouteStatusKeys,
		@CarrierAssignedBy  AS	CarrierAssignedBy,
		@PickupDate			AS	PickupDate,
		@DeliveryDate		AS	DeliveryDate,
		@IsEmpty			AS	IsEmpty,
		@CustomerKeys		as	CustomerKeys,
		@ChassisTypeKeys	AS	ChassisTypeKeys,
		@PropertyKeys		as	PropertyKeys,
		@PageNo				AS	PageNo,		
		@PageSize			AS	PageSize,	
		@IsAscending		AS	IsAscending,
		@SortField			AS	SortField,	
		@outputType			AS	outputType,
		@SearchText			AS	SearchText
	End

	CREATE TABLE #DateOptions 
	(
		FilterDayKey	INT,
		FilterDay		NVARCHAR(50)
	);

	INSERT INTO #DateOptions (FilterDayKey,FilterDay)
	VALUES
		(1,'Today'),(2,'Tomorrow'),(3,'This week'),(4,'Next week'),(5,'This month'),(6, 'Next month');

	INSERT INTO #DateOptions (FilterDayKey,FilterDay)
	VALUES
		(1,'Today'),(2,'Tomorrow'),(3,'This week'),(4,'Next week'),(5,'This month'),(6, 'Next month');

	
	CREATE TABLE #CustomerKeyList
	(
		CustKey			int,
		CustName		varchar(200)
	)

	IF(LEN(ISNULL(@CustomerKeys,'')) > 0)
	BEGIN
		insert into #CustomerKeyList(CustKey)
		select value from dbo.Fn_SplitParamCol(@CustomerKeys)

		update A set CustName = C.CustName
		from #CustomerKeyList A
		inner join Customer C WITH (NOLOCK) on A.CustKey = C.CustKey
	END

	CREATE TABLE #ChassisKeyList
	(
		ChassisCategoryKey		int,
		ChassisCategory			varchar(200)
	)

	IF(LEN(ISNULL(@ChassisTypeKeys,'')) > 0)
	BEGIN
		insert into #ChassisKeyList(ChassisCategoryKey)
		select value from dbo.Fn_SplitParamCol(@ChassisTypeKeys)

		update A set ChassisCategory = CC.ChassisCategory
		from #ChassisKeyList A
		inner join ChassisCategory CC WITH (NOLOCK) on A.ChassisCategoryKey = CC.ChassisCategoryKey
	END

	CREATE TABLE #PropsKeyList
	(
		TypeKey			int,
		TypeID			varchar(200)
	)
	create table #OrdersWithProps
	(
		OrderDetailKey		int
	)

	IF(LEN(ISNULL(@PropertyKeys,'')) > 0)
		BEGIN
		insert into #PropsKeyList(TypeKey)
		select value from dbo.Fn_SplitParamCol(@PropertyKeys)

		update A set TypeID = C.TypeID
		from #PropsKeyList A
		inner join ContainerTypes C WITH (NOLOCK) on A.TypeKey = C.ContainerTypeKey

		insert into #OrdersWithProps
		select distinct OD.OrderDetailKey
		from ContainerTypesLink A WITH (NOLOCK)
		inner join OrderDetail OD WITH (NOLOCK) on a.OrderDetailKey = OD.OrderDetailKey
		--inner join OrderHeader OH WITH (NOLOCK) on Od.OrderKey = Oh.OrderKey
		inner join #PropsKeyList P on A.ContainerTypeKey = P.TypeKey
	END

	CREATE TABLE #UserKeyList
	(
		UserKey			int,
		UserName		varchar(200)
	)

	IF(LEN(ISNULL(@CarrierAssignedBy,'')) > 0)
	BEGIN
		insert into #UserKeyList(UserKey)
		select value from dbo.Fn_SplitParamCol(@CarrierAssignedBy)

		update A set UserName = U.UserName
		from #UserKeyList A
		inner join [User] U WITH (NOLOCK) on A.UserKey = U.UserKey
	END

	DECLARE @PickupFromDate DATETIME;
	DECLARE @PickupToDate DATETIME;
	DECLARE @DeliveryFromDate DATETIME;
	DECLARE @DeliveryToDate DATETIME;
	
	--Set Pickupdate and Deliverydate to varicables
	SELECT @PickupFromDate =  FromDate, @PickupToDate = ToDate  FROM dbo.GetDateRange(@PickupDate)
	SELECT @DeliveryFromDate =  FromDate, @DeliveryToDate = ToDate  FROM dbo.GetDateRange(@DeliveryDate)

	IF(@PickupFromDate IS NULL OR @PickupFromDate = '1900-01-01')
	BEGIN
		SET @PickupFromDate = '2020-01-01' -- Getdate() - 90
	END
	IF(@PickupToDate IS NULL OR @PickupToDate = '1900-01-01')
	BEGIN
		SET @PickupToDate = Getdate()  + 30
	END
	IF(@DeliveryFromDate IS NULL OR @PickupFromDate = '1900-01-01')
	BEGIN
		SET @DeliveryFromDate = '2020-01-01' -- Getdate() - 90
	END
	IF(@DeliveryToDate IS NULL OR @DeliveryToDate = '1900-01-01')
	BEGIN
		SET @DeliveryToDate = Getdate()  + 30
	END

	IF(@IsDebug = 1)
	BEGIN
		SELECT @PickupFromDate		PickupFromDate,		@PickupToDate		PickupToDate	
		SELECT @DeliveryFromDate 	DeliveryFromDate,	@DeliveryToDate		DeliveryToDate
	END

	SELECT 
		OD.ContainerNo, ODS.Description as ContainerDStatus, RS.Description as RouteDStatus, L.LegID, OH.CustKey, C.CustName AS Customer,
		D.FirstName+' '+D.LastName AS DriverName, CCK.ChassisCategory, OH.MarketLocationKey, ML.MarketLocation, CZ.Description AS ContainerSize,
		OH.BookingNo, OH.OrderNo,OH.BillOfLading,OH.SteamShipLineKey, SShL.LineName, OT.OrderType, OT.OrderTypeKey,
		OD.TMFCheckOff,OD.CTFCheckOff, 
		OD.IsTMFJCTPaid, OD.IsTMFCustomerPaid,
		OD.IsCTFJCTPaid, OD.IsCTFCustomerPaid,
		CS.IsEditable, D.TruckTypeKey, TT.TruckType,
		--CTO.Properties AS ContainerProperties, 
		U.UserName AS DispatcherName,
		STUFF((
            SELECT ',' + CT.TypeID
            FROM ContainerTypesLink	CTL		WITH (NOLOCK)	
						LEFT JOIN ContainerTypes CT		WITH (NOLOCK)	ON CTL.ContainerTypeKey = CT.ContainerTypeKey
						WHERE OD.OrderDetailKey = CTL.OrderDetailKey
            FOR XML PATH('')
            ), 1, 1, '') AS ContainerProperties,
		--****************Source Address***********
		SR.Address1 AS SRAddress1,
		SR.Address2 AS SRAddress2,
		SR.AddrName AS SRAddrName,
		SR.City		AS SRCity,
		SR.Country	AS SRCountry,
		SR.Email	AS SREmail,
		SR.Email2	AS SREmail2,
		SR.Fax		AS SRFax,
		SR.[State]	AS SRState,
		SR.ZipCode	AS SRZipCode,
		--****************Destination Address********
		DT.Address1 AS DTAddress1,
		DT.Address2 AS DTAddress2,
		DT.AddrName AS DTAddrName,
		DT.City		AS DTCity,
		DT.Country	AS DTCountry,
		DT.Email	AS DTEmail,
		DT.Email2	AS DTEmail2,
		DT.Fax		AS DTFax,
		DT.[State]	AS DTState,
		DT.ZipCode	AS DTZipCode,
		--**************** Routes ********
		RT.RouteKey,
		RT.OrderDetailKey,
		RT.OrderKey,
		RT.LegKey,
		RT.LegNo,
		RT.FromLocation,
		RT.ToLocation,
		RT.SourceAddrKey,
		RT.PickupDateFrom,
		RT.DeliveryDateFrom,
		RT.ConfirmationNo,
		RT.ChassisNo,
		RT.ChassisType,
		RT.DestinationAddrKey,
		RT.Status,
		RT.DriverKey,
		RT.ScheduledPickupDate,
		RT.ScheduledArrival,
		RT.ActualDeparture,
		RT.ActualArrival,
		RT.ChassisKey,
		RT.CompanyKey,
		RT.CreateUserKey,
		RT.UpdateUserKey,
		RT.CreateDate,
		RT.LastUpdateDate,
		RT.IsEmpty,
		RT.IsDryRun,
		RT.IsBobtail,
		RT.DryRunType,
		RT.ChassisCategoryKey,
		RT.ActualDepartureUpdateMethod,
		RT.isStreetTurn,
		RT.ActualArrivalUpdateMethod,
		RT.CarrierAssignedBy,
		RT.EmptySource, 
		--RT.NoWaitTIme,
		RT.DriverInstructions,
		RT.CarrierRate,
		RT.LegType,

		RT.LinkedContainer, 
		RT.LinkedBy, 
		RT.LinkedDate, 
		RT.LinkedContainerSource,
		OD.IsLinked, DATEDIFF(day, RT.ActualDeparture, GETDATE()) AS StreetDwell,
		CP.OrderDetailKey as ContPropsFiltered
		--IsSelectedStatusKey = Case when RT.Status = @RouteStatusKeys then 1 else 0 end
	Into #Dispatch
		from Routes RT
		INNER JOIN Leg L on RT.LegKey = L.LegKey
		INNER JOIN OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey AND RT.RouteKey = OD.CurrentRouteKey
		INNER JOIN OrderHeader OH ON OD.OrderKey = OH.OrderKey
		Inner Join Customer C On OH.CustKey = C.CustKey
		Left Join Driver D On RT.DriverKey = D.DriverKey
		Left Join TruckType TT ON D.TruckTypeKey = TT.TruckTypeKey
		Left Join ChassisCategory CCK On RT.ChassisCategoryKey = CCK.ChassisCategoryKey		
		Left Join MarketLocation ML On OH.MarketLocationKey = ML.MarketLocationKey
		Inner Join ContainerSize CZ ON OD.ContainerSizeKey = CZ.ContainerSizeKey
		LEFT JOIN #OrdersWithProps CP WITH (NOLOCK) on OD.OrderDetailKey = CP.OrderDetailKey
		Left Join Chassis CS ON RT.ChassisKey = CS.chassisKey
		Left Join [Address] SR	 with ( NOLOCK)	ON	RT.SourceAddrKey = SR.AddrKey
		Left Join [Address] DT	 with ( NOLOCK)	ON	RT.DestinationAddrKey =DT.AddrKey
		Left Join SteamShipLine SShL ON OH.SteamShipLineKey = SShL.LineKey
		INNER JOIN RouteStatus RS on RT.Status = RS.Status
		INNER JOIN OrderDetailStatus ODS on OD.Status = ODS.Status
		Inner Join OrderType OT On OH.OrderTypeKey = OT.OrderTypeKey
		LEFT JOIN vContainerTypeByOrder CTO WITH (NOLOCK) on RT.OrderKey = CTO.OrderKey
		Left Join [User] U with ( NOLOCK)	ON	RT.CarrierAssignedBy = U.UserKey
		--Left Join DryRunType DRT ON RT.DryRunType = DRT.DryRunTypeKey
		where 
		OD.Status NOT IN (6,10,12,14,15)

	IF(@IsDebug = 1)
	BEGIN
		SELECT '@outputType', @outputType
		SELECT '#Dispatch', count(1) from #Dispatch WITH (NOLOCK)
	END

	Select * , 
	CASE WHEN @RouteStatusKeys = 4 AND ISNULL(ChassisCategoryKey,0) <> 0 THEN 4
		WHEN @RouteStatusKeys = 4 AND ISNULL(ChassisCategoryKey,0) = 0 THEN 3
		ELSE 0 END AS StatusSelected
	Into #Dispatch_Final_Data from #Dispatch D
	Where
	(ISNULL(ScheduledPickupDate, GETDate()) Between @PickupFromDate AND @PickupToDate)
	AND (ISNULL( ScheduledArrival, GETDATE()) Between @DeliveryFromDate AND @DeliveryToDate)
	AND (ISNULL(@RouteStatusKeys,'')='' OR  D.[Status] = @RouteStatusKeys)
	AND (ISNULL(@CustomerKeys,'')='' OR  D.CustKey in (select CustKey From #CustomerKeyList))
	AND (ISNULL(@CarrierAssignedBy,'')='' OR  D.CarrierAssignedBy in (select UserKey From #UserKeyList))
	AND (@IsEmpty = -1 OR D.IsEmpty = @IsEmpty)
	AND ( ISNULL(@PropertyKeys,'') = '' OR ContPropsFiltered is not null)
	AND (ISNULL(@ChassisTypeKeys,'')='' OR D.ChassisCategoryKey IS NULL OR D.ChassisCategoryKey in (Select ChassisCategoryKey from #ChassisKeyList))
	AND	(ISNULL(@SearchText,'')='' OR  
		D.ContainerNo Like '%' + @SearchText + '%' OR
		D.Customer Like '%' + @SearchText + '%' OR
		D.DriverName Like '%' + @SearchText + '%')
		 
		 -- AND StatusSelected = CASE WHEN @StatusSelected IN (3,4) THEN @StatusSelected ELSE 0 END

	SELECT * INTO #Dispatch_Final FROM #Dispatch_Final_Data 
	WHERE StatusSelected = CASE WHEN @StatusSelected IN (3,4) THEN @StatusSelected ELSE 0 END

	-- // FOR CONTAINER PROPERTIES - START
	SELECT DISTINCT CTL.ContainerTypeKey, CTL.TypeID
	INTO #ContProps
	FROM vContainerType CTL
	INNER JOIN ORDERDETAIL OD ON CTL.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN #Dispatch_Final_Data F ON OD.OrderKey = F.OrderKey
	-- // FOR CONTAINER PROPERTIES - END
	
	IF(@IsDebug = 1)
	BEGIN
		Select ContainerProperties, ContPropsFiltered from #Dispatch_Final
		SELECT @StatusSelected StatusSelected
		SELECT  Distinct ChassisCategoryKey  from #Dispatch_Final
		SELECT  Distinct ChassisKey from #Dispatch_Final
	END

	SELECT *,0 as RecCount, 0 AS RowNum   INTO  #FinalData_Temp FROM #Dispatch_Final WITH (NOLOCK) WHERE 1 <> 1

	IF(@IsDebug = 1)
	BEGIN
		SELECT '@outputType', @outputType
		SELECT '#FinalData_Temp', * FROM #FinalData_Temp WITH (NOLOCK)
	END

	IF(ISNULL(@outputType,'') IN ('Excel','PDF'))
	BEGIN
		SET		@PageNo = 1
		SET		@PageSize = (SELECT COUNT(1) FROM  #Dispatch_Final WITH (NOLOCK)) 
							--WHERE IsSelectedStatusKey = 1)
	END

	DECLARE			@STRSQL VARCHAR(MAX)
	DECLARE			@cnt INT
	SELECT			@cnt = COUNT(1) FROM #Dispatch_Final WITH (NOLOCK) 
							--WHERE IsSelectedStatusKey = 1

	SET				@STRSQL = '
					SELECT *   FROM (
					SELECT top 1000000 *,' + convert(varchar, @cnt) + ' as RecCount
					,ROW_NUMBER() Over(Order by ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ', ContainerNo ' + ') RowNum
					FROM #Dispatch_Final) a
					WHERE ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
					+' Order BY ROWNUM'

					--SELECT *   FROM (
					--SELECT top 1000000 *,' + convert(varchar, @cnt) + ' as RecCount
					--,ROW_NUMBER() Over(Order by ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ', ContainerNo ' + ') RowNum
					--FROM #Dispatch_Final
					--WHERE IsSelectedStatusKey = 1) a

	PRINT			(@STRSQL)

	INSERT INTO		#FinalData_Temp
	EXEC			(@STRSQL)


	IF(@IsDebug = 1)
	BEGIN
		SELECT '#FinalData_Temp', * FROM #FinalData_Temp
	END

	--Declare @JSONOutput NVARCHAR(MAX)
	--Data converted to JSON Path	
	SELECT	Dispatch = (
		SELECT * FROM #FinalData_Temp WITH (NOLOCK)
		--WHERE IsSelectedStatusKey = 1 
		FOR JSON PATH
	), 
	DropDowns = ( SELECT
		CustomerList =			(SELECT DISTINCT	CustKey, Customer FROM  #Dispatch_Final  WITH (NOLOCK)
									WHERE ISNULL(Customer,'')<>''	ORDER BY CustKey FOR JSON PATH),
		ChassisCategoryList =	(SELECT DISTINCT	ChassisCategoryKey, ChassisCategory FROM  #Dispatch_Final  WITH (NOLOCK)
									WHERE ISNULL(ChassisCategory,'')<>''	ORDER BY ChassisCategory FOR JSON PATH),
		DateList			=	(SELECT DISTINCT	FilterDayKey, FilterDay FROM  #DateOptions  WITH (NOLOCK)
									ORDER BY FilterDayKey FOR JSON PATH),
		DryRunTypeList		=	(SELECT DISTINCT	DryRunTypeKey, DryRunType FROM  DryRunType  WITH (NOLOCK)
									WHERE ISNULL(DryRunType,'')<>''	ORDER BY DryRunTypeKey FOR JSON PATH),
		RouteStatusList		=	(SELECT DISTINCT	[Status] AS RouteStatusKey, Description AS RouteDescription FROM  RouteStatus  WITH (NOLOCK)
									ORDER BY RouteStatusKey FOR JSON PATH),
		DispatcherList		=	(SELECT DISTINCT	CarrierAssignedBy, DispatcherName FROM  #Dispatch_Final  WITH (NOLOCK)
								WHERE ISNULL(DispatcherName,'')<>''	ORDER BY CarrierAssignedBy FOR JSON PATH),
		PropertiesList		=   (SELECT DISTINCT    A.ContainerTypeKey,A.TypeID from #ContProps A Order by A.TypeID For JSON PATH ),
		TruckTypeList		 =	(SELECT TruckTypeKey, TruckType FROM  TruckType  WITH (NOLOCK)
									ORDER BY TruckTypeKey FOR JSON PATH)
		FOR JSON PATH
		)FOR JSON PATH


	SET @Status = 1
	SET @Reason = 'Success'
	SET ARITHABORT OFF;

	if(@IsDebug = 1)
	Begin
	Select * FROM #Dispatch_Final
	end

	Drop Table #Dispatch
	Drop Table #Dispatch_Final
	Drop Table #CustomerKeyList
	Drop Table #ChassisKeyList
	Drop Table #DateOptions
	Drop Table #ContProps
	Drop Table #Dispatch_Final_Data
	Drop Table #FinalData_Temp
	Drop Table #OrdersWithProps
	Drop Table #PropsKeyList
	Drop Table #UserKeyList
END
