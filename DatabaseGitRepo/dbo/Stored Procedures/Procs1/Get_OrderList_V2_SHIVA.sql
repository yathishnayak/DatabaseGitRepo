

/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustomerKeys":"","CSRKeys":"","CreatedUserKeys":"","MarketLocationKeys":"","PropertyKeys":"","EntryType":"","OrderTypeKey":"","StatusKey":0,"SearchText":"unicargo2504417","PageNo":1,"PageSize":50,"IsAscending":false,"SortField":"CreateDate","outputType":""}',
	@Status BIT=0,@IsDebug		BIT = 0,
	@Reason VARCHAR(100)=''
EXec [Get_OrderList_V2_SHIVA] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PRocedure [dbo].[Get_OrderList_V2_SHIVA] -- [Get_OrderList_V2_SHIVA] @StatusKey=2, @PageNo = 1,@SearchText='WHSU5296890'
(
	@UserKey		INT = 714,
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
	SET Concat_null_Yields_null ON

	--INSERT INTO SqlExecutionTimeLog
	--(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	--VALUes (@UserKey,'Get_OrderList_V2','Procedure Entered','',GETDATE())

	Declare
		@CustomerKeys		varchar(1000) = '', -- comma separated customer keys
		@OrderDateFrom		DATE='01/01/2020',
		@OrderDateTo		DATE='01/01/2099',
		@CSRKeys			varchar(1000) = '', -- comma separated CSR keys
		@PropertyKeys		varchar(200) = '',  -- Comma seperated Container Props Keys
		@OrderTypeKey		varchar(200) = '',  
		@StatusKey			INT = 0,
		@EntryTypes			varchar(500) = '',	-- Comma separated Entry types
		@marketLocationKeys	varchar(1000) = '', -- comma separated Market Location keys
		@SearchText			varchar(50) ='',
		@CreatedUserKeys	varchar(1000) = '',  -- comma separated User keys
		@PageNo				INT = 1,
		@PageSize			INT	= 10,
		@SortField			VARCHAR(50) = 'ORDERNO',
		@IsAscending		BIT = 1,
		@outputType			VARCHAR(20)

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

	SElect 
		@StatusKey			=	StatusKey,
		@CustomerKeys		=	CustomerKeys,
		@OrderDateFrom		=	OrderDateFrom,
		@OrderDateTo		=	OrderDateTo,
		@CSRKeys			=	CSRKeys,
		@MarketLocationKeys	=	MarketLocationKeys,
		@PropertyKeys		=	PropertyKeys ,
		@OrderTypeKey		=	OrderTypeKey, 
		@EntryTypes			=	EntryType,
		@SearchText			=	SearchText,
		@PageNo				=	PageNo,
		@PageSize			=	PageSize,
		@SortField			=	SortField,
		@IsAscending		=	IsAscending,
		@outputType			=	outputType,
		@CreatedUserKeys	=	CreatedUserKeys
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		StatusKey			INT				'$.StatusKey',
		CustomerKeys		varchar(1000)	'$.CustomerKeys',
		OrderDateFrom		DATE			'$.OrderDateFrom',
		OrderDateTo			DATE			'$.OrderDateTo',
		CSRKeys				varchar(1000)	'$.CSRKeys',
		PropertyKeys		varchar(500)	'$.PropertyKeys',
		OrderTypeKey		varchar(500)	'$.OrderTypeKey',
		EntryType			varchar(500)	'$.EntryType',
		MarketLocationKeys	varchar(1000)	'$.MarketLocationKeys',
		SearchText			varchar(50)		'$.SearchText',
		PageNo				INT				'$.PageNo',
		PageSize			INT				'$.PageSize',
		SortField			VARCHAR(50)		'$.SortField',
		IsAscending			BIT				'$.IsAscending',
		outputType			VARCHAR(20)		'$.outputType',
		CreatedUserKeys		VARCHAR(1000)	'$.CreatedUserKeys'
	)
	Set @StatusKey = case when (isnull(@SearchText,'')<>'') then 0 else @StatusKey end
	if(@IsDebug = 1)
	Begin
		SELECT 'Parameters' as Params,
		@StatusKey			as	StatusKey,
		@CustomerKeys		as	CustomerKeys,
		@OrderDateFrom		as	OrderDateFrom,
		@OrderDateTo		as	OrderDateTo,
		@CSRKeys			as	CSRKeys,
		@PropertyKeys		as	PropertyKeys,
		@OrderTypeKey		AS	OrderTypeKey,
		@EntryTypes			as EntryTypes,
		@MarketLocationKeys	as	MarketLocationKeys,
		@SearchText			as	SearchText ,
		@PageNo				as	PageNo,
		@PageSize			as	PageSize,
		@SortField			as	SortField,
		@IsAscending		as	IsAscending,
		@outputType			as  outputType
	End

	IF(@OrderDateFrom IS NULL OR @OrderDateFrom = '1900-01-01')
	BEGIN
		SET @OrderDateFrom = '2020-01-01' -- Getdate() - 90
	END

	IF(@OrderDateTo IS NULL OR @OrderDateTo = '1900-01-01')
	BEGIN
		SET @OrderDateTo = Getdate()  + 30
	END
--for completed tab showing 90 days data
	IF(@StatusKey=9)
	BEGIN
		SET @OrderDateFrom = Getdate() - 600
		SET @OrderDateTo = Getdate()
	END

	IF(@StatusKey=3)
	BEGIN
		SET @StatusKey=0
	END

	CREATE TABLE #CustomerKeyList
	(
		CustKey			int,
		CustName		varchar(200)
	)

	CREATE TABLE #PropsKeyList
	(
		TypeKey			int,
		TypeID			varchar(200)
	)

	create table #OrdersWithProps
	(
		OrderKey		int
	)

	Create table #EntryTypes
	(
		EntryType		varchar(50)
	)

	Create table #OrderTypeList
	(
		OrderTypeKey		varchar(50),
		OrderDescription	VARCHAR(200)
	)

	IF(len(isnull(@EntryTypes,'')) > 0)
	begin
		INSERT INTO #EntryTypes (EntryType)
		SELECT VALUE FROM DBO.Fn_SplitParamCol(@EntryTypes)
	end

	IF(LEN(ISNULL(@CustomerKeys,'')) > 0)
	BEGIN
		insert into #CustomerKeyList(CustKey)
		select value from dbo.Fn_SplitParamCol(@CustomerKeys)

		update A set CustName = C.CustName
		from #CustomerKeyList A
		inner join Customer C WITH (NOLOCK) on A.CustKey = C.CustKey
	END

	IF(LEN(ISNULL(@PropertyKeys,'')) > 0)
	BEGIN
		insert into #PropsKeyList(TypeKey)
		select value from dbo.Fn_SplitParamCol(@PropertyKeys)

		update A set TypeID = C.TypeID
		from #PropsKeyList A
		inner join ContainerTypes C WITH (NOLOCK) on A.TypeKey = C.ContainerTypeKey

		insert into #OrdersWithProps
		select distinct OH.Orderkey 
		from ContainerTypesLink A WITH (NOLOCK)
		inner join OrderDetail OD WITH (NOLOCK) on a.OrderDetailKey = OD.OrderDetailKey
		inner join OrderHeader OH WITH (NOLOCK) on Od.OrderKey = Oh.OrderKey
		inner join #PropsKeyList P on A.ContainerTypeKey = P.TypeKey
	END

	IF(LEN(ISNULL(@OrderTypeKey, ''))>0)
	BEGIN
		INSERT INTO #OrderTypeList(OrderTypeKey)
		select value from dbo.Fn_SplitParamCol(@OrderTypeKey)

		UPDATE A SET OrderTypeKey = OT.OrderType
		FROM #OrderTypeList A
		INNER JOIN OrderType OT WITH (NOLOCK) ON A.OrderTypeKey = OT.OrderType
	END

	CREATE TABLE #CSRKeyList
	(
		CSRKey		int,
		CSRName		varchar(200)
	)

	IF(LEN(ISNULL(@CustomerKeys,'')) > 0)
	BEGIN
		insert into #CSRKeyList(CSRKey)
		select value from dbo.Fn_SplitParamCol(@CSRKeys)

		update A set CSRName = C.CSRName
		from #CSRKeyList A
		inner join CSR C WITH (NOLOCK) on A.CSRKey = C.CSRKey
	END

	CREATE TABLE #MarketLocationKeyList
	(
		MarketKey		int,
		MarketName		varchar(200)
	)

	IF(LEN(ISNULL(@marketLocationKeys,'')) > 0)
	BEGIN
		insert into #MarketLocationKeyList(MarketKey)
		select value from dbo.Fn_SplitParamCol(@marketLocationKeys)

		update A set MarketName = C.MarketLocation
		from #MarketLocationKeyList A
		inner join MarketLocation C WITH (NOLOCK) on A.MarketKey = C.MarketLocationKey
	END


	CREATE TABLE #UserKeyList
	(
		UserKey		int,
		UserName		varchar(200)
	)

	IF(LEN(ISNULL(@CreatedUserKeys,'')) > 0)
	BEGIN
		insert into #UserKeyList(UserKey)
		select value from dbo.Fn_SplitParamCol(@CreatedUserKeys)

		update A set UserName = C.UserName
		from #UserKeyList A
		inner join [USER] C WITH (NOLOCK) on A.UserKey = C.UserKey
	END

	if(@IsDebug = 1)
	Begin
		SElect 'Parameters' as Params,
		@StatusKey			as	StatusKey,
		@CustomerKeys		as	CustomerKeys,
		@OrderDateFrom		as	OrderDateFrom,
		@OrderDateTo		as	OrderDateTo,
		@CSRKeys			as	CSRKeys,
		@MarketLocationKeys	as	MarketLocationKeys,
		@PropertyKeys		as  PropertyKeys,
		@EntryTypes			as EntryTypes,
		@SearchText			as	SearchText ,
		@PageNo				as	PageNo,
		@PageSize			as	PageSize,
		@SortField			as	SortField,
		@IsAscending		as	IsAscending,
		@outputType			as  outputType
	End

	if(@IsDebug = 1)
	Begin
		SElect 'Customer Keys', * from #CustomerKeyList
		select 'CSR Keys', * from #CSRKeyList
		SElect 'Market Location Keys', * from #MarketLocationKeyList
		Select 'Created User Keys', * from #UserKeyList
		select 'PropertyKeys', * from #PropsKeyList
		Select 'EntryTypes', * from #EntryTypes
	End

	SELECT COUNT (1) AS ContainerCount ,OrderKey,
		(SELECT STRING_AGG(ContainerNo,',')within  GROUP (ORDER BY OrderKey ASC)) AS ContainerNos 
	INTO #ContainerCount
	FROM OrderDetail	with (nolock)
	GROUP BY OrderKey;
	/*
	CREATE TABLE #FilteredOrderKeys
	(
		OrderKey	INT
	)
	IF(ISNULL(@StatusKey,0)=0)
	BEGIN
		INSERT INTO #FilteredOrderKeys
		SELECT OrderKey FROM OrderHeader with (nolock) WHERE Status<>14 
	END
	ELSE
	BEGIN
		INSERT INTO #FilteredOrderKeys
		SELECT OrderKey FROM OrderHeader with (nolock) WHERE Status=@StatusKey
	END
	*/
/*
SELECT OH.Status
into #OrderListCountData
FROM	dbo.OrderHeader OH   with ( NOLOCK) 	
	--LEFT JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey
    LEFT JOIN dbo.Customer CUS	 with ( NOLOCK)		ON CUS.CustKey = OH.CustKey      
    LEFT JOIN dbo.[Broker] BR	 with ( NOLOCK)		ON OH.BrokerKey = BR.BrokerKey
    LEFT JOIN dbo.OrderType OT	 with ( NOLOCK)		ON OH.OrderTypeKey = OT.OrderTypeKey   
    LEFT JOIN dbo.OrderStatus OS with ( NOLOCK)		ON OS.[Status] = OH.[Status]
	--LEFT JOIN Dbo.Holdreason	HR with ( NOLOCK)		ON HR.HoldReasonKey=OH.HoldReasonKey
	LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
	Left join CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
	Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
	LEFT JOIN #ContainerCount CT with ( NOLOCK)		ON CT.OrderKey=OH.OrderKey
	LEFT JOIN #OrdersWithProps CP WITH (NOLOCK) on OH.OrderKey = CP.OrderKey
	LEFT JOIN vContainerTypeByOrder CTO WITH (NOLOCK) on OH.OrderKey = CTO.OrderKey
	LEFT JOIN [Address] SR	 with ( NOLOCK)			ON	SR.AddrKey=OH.SourceAddrKey
	LEFT JOIN [Address] DT	 with ( NOLOCK)			ON	DT.AddrKey=OH.DestinationAddrKey
	LEFT JOIN [Address] CA	 with ( NOLOCK)			ON CUS.AddrKey = CA.AddrKey
	LEFT JOIN [Address] RT	 with ( NOLOCK)			ON OH.ReturnAddrKey = RT.AddrKey
	LEFT JOIN [Address] BA	 with ( NOLOCK)			ON BR.AddrKey = BA.AddrKey
	LEFT JOIN [User] U	 with ( NOLOCK)				ON OH.CreateUserKey = U.UserKey
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey

	IF(@IsDebug = 1)
	bEGIN
		SELECT '#OrderListCountData', * FROM #OrderListCountData
	eND
*/
	SELECT 
        OH.OrderNo ,  OH.OrderDate ,  OH.CustKey,  OH.DropLive DropOrLive,
        CUS.AddrKey AS BillToAddressKey,  
		CUS.CustName AS BillToAddrName,
        OH.SourceAddrKey AS SourceAddressKey, 
		SR.AddrName AS SourceAddrName,
        OH.DestinationAddrKey AS DestinationAddressKey,
		DT.AddrName AS DestinationAddrName,
        OH.ReturnAddrKey AS ReturnAddressKey, 
        OH.OrderTypeKey OrderTypeKey,oh.PriorityKey,
        OH.[Status] ,  
		OH.StatusDate    AS StatusDate,
        --HR.[Description] AS HoldReason ,
        oh.HoldDate ,
        BR.BrokerName,
        BR.BrokerID ,
		BR.BrokerKey,
        OH.BrokerRefNo BrokerRefNo,
        OH.PortoForiginKey ,
        OH.CarrierKey,
        OH.VesselName ,
        OH.BillOfLading ,
        OH.BookingNo ,
        OH.CreateDate ,
        OH.CreateUserKey,
        OH.OrderKey,
		OH.ETADate,
        OT.OrderType AS OrderTypeDescription,
        OS.Description AS StatusDescription,    
		'' AS NextAction,
		CT.ContainerCount,
		SR.City AS PickupLocation,
		DT.City AS DeliveryLocation,
		CUS.CustName,
		--************Customer Adress************
		CA.Address1 AS CusAddress1,
		CA.Address2 AS CusAddress2,
		CA.AddrName AS CusAddrName,
		CA.City		AS CusCity,
		CA.Country	AS CusCountry,
		CA.Email	AS CusEmail,
		CA.Email2	AS CusEmail2,
		CA.Fax		AS CusFax,
		CA.[State]	AS CusState,
		CA.ZipCode	AS CusZipCode,
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
		--******************Return Address***************
		RT.Address1 AS RTAddress1,
		RT.Address2 AS RTAddress2,
		RT.AddrName AS RTAddrName,
		RT.City		AS RTCity,
		RT.Country	AS RTCountry,
		RT.Email	AS RTEmail,
		RT.Email2	AS RTEmail2,
		RT.Fax		AS RTFax,
		RT.[State]	AS RTState,
		RT.ZipCode	AS RTZipCode,
		--******************Broker Adress******************
		BA.Address1 AS BAAddress1,
		BA.Address2 AS BAAddress2,
		BA.AddrName AS BAAddrName,
		BA.City		AS BACity,
		BA.Country	AS BACountry,
		BA.Email	AS BAEmail,
		BA.Email2	AS BAEmail2,
		BA.Fax		AS BAFax,
		BA.[State]	AS BAState,
		BA.ZipCode  AS BAZipCode,
		--******************************
		U.UserName AS CreatedUsedName,
		dbo.fAllowOrderDelete(OH.orderKey) as AllowOrderDelete,
		CS.CsrKey as CSRKey,
		CS.CsrName as CSRName,
		oh.SalesPersonKey,
		SP.SalesPersonName,
		CM.CsrKey as CSRManagerKey,
		CM.CsrName as CSRManagerName,
		ML.MarketLocationKey,
		ML.MarketLocation,
		OH.OrderSource,
		OH.Consignee AS Consignee,
		CT.ContainerNos,
		IsSelectedStatusKey = Case when OH.Status = @StatusKey or IsNull(@StatusKey,0) = 0 then 1 else 0 end,
		CTO.Properties,
		CP.OrderKey as ContPropsFiltered, 
		OH.SenderInfo
		--STUFF((
  --          SELECT ',' + CT.TypeID
  --          FROM ContainerTypesLink	CTL		WITH (NOLOCK)	
		--				LEFT JOIN ContainerTypes CT		WITH (NOLOCK)	ON CTL.ContainerTypeKey = CT.ContainerTypeKey
		--				WHERE OD.OrderDetailKey = CTL.OrderDetailKey
  --          FOR XML PATH('')
  --          ), 1, 1, '') AS Properties
	into #OrderListData
    FROM orderheader oh with (NOLOCK)
		--(select ORderKey from ORDERHEADER WITH (NOLOCK)  
		--	where ((isnull(@Status,0) = 0 and Status <> 14) OR (isnull(@Status,0)<> 0 and Status = @StatusKey))) FOH
		--INNER JOIN dbo.OrderHeader OH with ( NOLOCK)	ON FOH.OrderKey=OH.OrderKey 	
        LEFT JOIN dbo.Customer CUS	 with ( NOLOCK)		ON CUS.CustKey = OH.CustKey      
        LEFT JOIN dbo.[Broker] BR	 with ( NOLOCK)		ON OH.BrokerKey = BR.BrokerKey
        LEFT JOIN dbo.OrderType OT	 with ( NOLOCK)		ON OH.OrderTypeKey = OT.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus OS with ( NOLOCK)		ON OS.[Status] = OH.[Status]
		LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
		Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
		LEFT JOIN #ContainerCount CT with ( NOLOCK)		ON CT.OrderKey=OH.OrderKey
		LEFT JOIN #OrdersWithProps CP WITH (NOLOCK) on OH.OrderKey = CP.OrderKey
		LEFT JOIN vContainerTypeByOrder CTO WITH (NOLOCK) on OH.OrderKey = CTO.OrderKey
		LEFT JOIN OrderStops OSF WITH (NOLOCK) ON OSF.OrderKey = OH.OrderKey  AND OSF.StopTypeKey = 1
		LEFT JOIN [Address] SR	 with ( NOLOCK)			ON	SR.AddrKey= OSF.StopAddrKey
		LEFT JOIN OrderStops OST WITH (NOLOCK) ON OST.OrderKey = OH.OrderKey  AND OST.StopTypeKey = 3
		LEFT JOIN [Address] DT	 with ( NOLOCK)			ON	DT.AddrKey= OST.StopAddrKey
		LEFT JOIN [Address] CA	 with ( NOLOCK)			ON CUS.AddrKey = CA.AddrKey
		LEFT JOIN [Address] RT	 with ( NOLOCK)			ON OH.ReturnAddrKey = RT.AddrKey
		LEFT JOIN [Address] BA	 with ( NOLOCK)			ON BR.AddrKey = BA.AddrKey
		LEFT JOIN [User] U	 with ( NOLOCK)				ON OH.CreateUserKey = U.UserKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
	where ((isnull(@StatusKey,0) = 0 and  OH.Status NOT IN (14) AND ISNULL(@SearchText,'')<> '') 
			OR  (isnull(@StatusKey,0)<> 0 and  OH.Status = @StatusKey)) 
	--WHERE 
		AND (OH.OrderDate IS NULL OR OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
		AND ( ISNULL(@CustomerKeys,'')='' OR  OH.CustKey in (select CustKey From #CustomerKeyList))
		AND ( ISNULL(@CSRKeys,'')='' OR OH.CsrKey IS NULL OR OH.CsrKey in (Select CSRKey from #CSRKeyList) )	
		--AND (case when isnull(@StatusKey, 0) = 0 then 0 else OH.[Status] end = isnull(@StatusKey, 0))
		AND ( ISNULL(@CreatedUserKeys,'') = '' OR OH.CreateUserKey in (Select UserKey from #UserKeyList)) 
		AND ( ISNULL(@marketLocationKeys,'') = '' OR ISNULL(OH.MarketLocationKey,0) in (SElect MarketKey from #MarketLocationKeyList))
		and ( ISNULL(@EntryTypes,'') = '' OR ISNULL(OH.OrderSource,'') IN (SELECT ENTRYTYPE FROM #EntryTypes))
		and ( ISNULL(@OrderTypeKey,'') = '' OR ISNULL(OH.OrderTypeKey,'') IN (SELECT OrderTypeKey FROM #OrderTypeList))
		AND ( ISNULL(@PropertyKeys,'') = '' OR CP.OrderKey is not null)
		--AND ( ISNULL(@PropertyKeys,'') = '' OR  1 = (select 1 from #PropsKeyList where  Typeid like '%' + O.Properties + '%' ) ) 
		AND (ISNULL(@SearchText,'')='' OR
			OH.OrderNo like '%' +  @SearchText + '%'  OR
			CUS.CustName like '%' +  @SearchText + '%'  OR
			SR.AddrName like '%' +  @SearchText + '%'  OR
			BR.BrokerName like '%' +  @SearchText + '%'  OR
			OH.BookingNo like '%' +  @SearchText + '%'  OR
			ContainerNos like '%' +  @SearchText + '%' OR
			OH.BillOfLading LIKE '%' +  @SearchText + '%' )
	/*
	Select *
	INTO #OrderListData_Final
	FROM #OrderListData O
	WHERE 
		(O.OrderDate IS NULL OR O.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
		AND ( ISNULL(@CustomerKeys,'')='' OR  O.CustKey in (select CustKey From #CustomerKeyList))
		AND ( ISNULL(@CSRKeys,'')='' OR O.CsrKey IS NULL OR O.CsrKey in (Select CSRKey from #CSRKeyList) )	
		--AND ( ISNULL(@StatusKey,0) = 0 OR O.[Status] IS NULL OR O.[Status] = @StatusKey)
		AND (case when isnull(@StatusKey, 0) = 0 then 0 else O.[Status] end = isnull(@StatusKey, 0))
		AND ( ISNULL(@CreatedUserKeys,'') = '' OR O.CreateUserKey in (Select UserKey from #UserKeyList)) 
		AND ( ISNULL(@marketLocationKeys,'') = '' OR ISNULL(O.MarketLocationKey,0) in (SElect MarketKey from #MarketLocationKeyList))
		and ( ISNULL (@EntryTypes,'') = '' OR ISNULL(O.OrderSource,'') IN (SELECT ENTRYTYPE FROM #EntryTypes))
		and ( ISNULL (@OrderTypeKey,'') = '' OR ISNULL(O.OrderTypeKey,'') IN (SELECT OrderTypeKey FROM #OrderTypeList))
		AND ( ISNULL(@PropertyKeys,'') = '' OR ContPropsFiltered is not null)
		--AND ( ISNULL(@PropertyKeys,'') = '' OR  1 = (select 1 from #PropsKeyList where  Typeid like '%' + O.Properties + '%' ) ) 
		AND (ISNULL(@SearchText,'')='' OR
		O.OrderNo like '%' +  @SearchText + '%'  OR
		O.CustName like '%' +  @SearchText + '%'  OR
		O.SourceAddrName like '%' +  @SearchText + '%'  OR
		O.BrokerName like '%' +  @SearchText + '%'  OR
		O.BookingNo like '%' +  @SearchText + '%'  OR
		ContainerNos like '%' +  @SearchText + '%' OR
		O.BillOfLading LIKE '%' +  @SearchText + '%' )
		*/

	-- // FOR CONTAINER PROPERTIES - START
	SELECT DISTINCT CTL.ContainerTypeKey, CTL.TypeID
	INTO #ContProps
	FROM vContainerType CTL with (nolock)
	INNER JOIN ORDERDETAIL OD with (nolock) ON CTL.OrderDetailKey = OD.OrderDetailKey
	INNER JOIN #OrderListData F ON OD.OrderKey = F.OrderKey

	IF(@IsDebug = 1)
	BEGIN
		Select status, count(1) cnt from  #OrderListData group by Status
	END

	create table #Dashboard
	(
		StatusKey		int,
		Description		varchar(50),
		OrderCount		int
	)

	-- // FOR CONTAINER PROPERTIES - END
	
	if(isnull(@SearchText,'') = '')
	Begin
		INSERT INTO			#DashBoard
		SELECT			S.status as StatusKey, S.Description , ISNULL(cnt,0) AS OrderCount
		FROM			OrderStatus S WITH (NOLOCK)
		LEFT JOIN		(select status, count(1) CNT from orderheader with (nolock) group by status) Z on S.Status = Z.Status
		where S.IsActive = 1
	End
	ELSE
	BEGIN
		INSERT INTO			#DashBoard
		SELECT			S.status as StatusKey, S.Description , ISNULL(cnt,0) AS OrderCount
		FROM			OrderStatus S WITH (NOLOCK)
		LEFT JOIN		(Select status, count(1) cnt from  #OrderListData group by Status) Z on S.Status = Z.Status
		where S.IsActive = 1
	END
	
	SELECT *,0 as RecCount, 0 AS RowNum   INTO  #FinalData_Temp FROM #OrderListData WITH (NOLOCK) WHERE 1 <> 1 

	IF(@IsDebug = 1)
	BEGIN
		SELECT '@outputType', @outputType
		SELECT '#InvoiceListData', * FROM #FinalData_Temp WITH (NOLOCK)
	END

	IF(ISNULL(@outputType,'') IN ('Excel','PDF'))
	BEGIN
		SET		@PageNo = 1
		SET		@PageSize = (SELECT COUNT(1) FROM  #OrderListData WITH (NOLOCK) WHERE IsSelectedStatusKey = 1)
	END
	
	DECLARE			@STRSQL VARCHAR(MAX)
	DECLARE			@cnt INT
	SELECT			@cnt = COUNT(1) FROM #OrderListData WITH (NOLOCK) WHERE IsSelectedStatusKey = 1

					--Changed SELECT top 1000000 to 1000
	SET				@STRSQL = '
					SELECT *   FROM (
					SELECT top 1000 *,' + convert(varchar, @cnt) + ' as RecCount
					,ROW_NUMBER() Over(Order by ' + @SortField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ', OrderNo ' + ') RowNum
					FROM #OrderListData
					WHERE IsSelectedStatusKey = 1) a
					WHERE ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
					+' Order BY ROWNUM'

	PRINT			(@STRSQL)

	INSERT INTO		#FinalData_Temp
	EXEC			(@STRSQL)


	IF(@IsDebug = 1)
	BEGIN
		SELECT '#FinalData_Temp', * FROM #FinalData_Temp
	END


	if(@IsDebug = 1)
	Begin
		SELECT	OrderList = (
			SELECT  * FROM #FinalData_Temp WITH (NOLOCK)
			WHERE IsSelectedStatusKey = 1 
			FOR JSON PATH
		), 
		DropDowns = ( SELECT
			CustomerList	=	(SELECT DISTINCT CustKey, CustName FROM  #FinalData_Temp  WITH (NOLOCK)
									WHERE IsSelectedStatusKey = 1 AND ISNULL(CustName,'')<>''	ORDER BY CustName FOR JSON PATH),
			CSRList			=	(SELECT DISTINCT CSRKey, CSRName FROM #FinalData_Temp  WITH (NOLOCK)
									WHERE IsSelectedStatusKey = 1 AND ISNULL(CSRName,'')<>''	ORDER BY CSRName FOR JSON PATH ),
			MarketLocList	=	(SELECT DISTINCT MarketLocationKey,MarketLocation FROM #FinalData_Temp WITH (NOLOCK) 
									WHERE IsSelectedStatusKey = 1 AND ISNULL(MarketLocation,'')<>''	ORDER BY MarketLocation FOR JSON PATH ),
			CreatedUserList =	(SELECT DISTINCT CreateUserKey,CreatedUsedName FROM #FinalData_Temp  WITH (NOLOCK)
									WHERE IsSelectedStatusKey = 1 AND ISNULL(CreatedUsedName,'')<>'' ORDER BY CreatedUsedName FOR JSON PATH ),
			WarehouseStatus =   (SELECT DISTINCT StatusKey,Description from WarehouseStatus Order by StatusKey For JSON PATH ),
			PropertiesList	=   (SELECT DISTINCT A.ContainerTypeKey,A.TypeID from #ContProps A Order by A.TypeID For JSON PATH ),
			SourceList		=	(SELECT DISTINCT OrderSource from #FinalData_Temp order by OrderSource FOR JSON PATH),
			OrderTypeList	=	(SELECT OrderTypeKey, OrderType AS OrderTypeDescription FROM OrderType WITH(NOLOCK)
									ORDER BY OrderType FOR JSON PATH)
			FOR JSON PATH
		),
		Dashboard = (
			SELECT * FROM #DashBoard WITH (NOLOCK)
			For JSON PATH
		)
	END
	ELSE
	BEGIN
		SELECT	
		Dashboard = (
			SELECT * FROM #DashBoard WITH (NOLOCK)
			For JSON PATH
		),
		OrderList = (
			SELECT  * FROM #FinalData_Temp WITH (NOLOCK)
			WHERE IsSelectedStatusKey = 1 
			FOR JSON PATH
		), 
		DropDowns = ( SELECT
			CustomerList	=	(SELECT DISTINCT CustKey, CustName FROM  #FinalData_Temp  WITH (NOLOCK)
									WHERE IsSelectedStatusKey = 1 AND ISNULL(CustName,'')<>''	ORDER BY CustName FOR JSON PATH),
			CSRList			=	(SELECT DISTINCT CSRKey, CSRName FROM #FinalData_Temp  WITH (NOLOCK)
									WHERE IsSelectedStatusKey = 1 AND ISNULL(CSRName,'')<>''	ORDER BY CSRName FOR JSON PATH ),
			MarketLocList	=	(SELECT DISTINCT MarketLocationKey,MarketLocation FROM #FinalData_Temp WITH (NOLOCK) 
									WHERE IsSelectedStatusKey = 1 AND ISNULL(MarketLocation,'')<>''	ORDER BY MarketLocation FOR JSON PATH ),
			CreatedUserList =	(SELECT DISTINCT CreateUserKey,CreatedUsedName FROM #FinalData_Temp  WITH (NOLOCK)
									WHERE IsSelectedStatusKey = 1 AND ISNULL(CreatedUsedName,'')<>'' ORDER BY CreatedUsedName FOR JSON PATH ),
			WarehouseStatus =   (SELECT DISTINCT StatusKey,Description from WarehouseStatus Order by StatusKey For JSON PATH ),
			PropertiesList	=	(SELECT DISTINCT A.ContainerTypeKey,A.TypeID from #ContProps A Order by A.TypeID For JSON PATH ),
			SourceList		=	(SELECT DISTINCT OrderSource from #FinalData_Temp order by OrderSource FOR JSON PATH),
			OrderTypeList	=	(SELECT OrderTypeKey, OrderType AS OrderTypeDescription FROM OrderType WITH(NOLOCK)
									ORDER BY OrderType FOR JSON PATH)
			FOR JSON PATH
		)
		FOR JSON PATH
	END
	--INSERT INTO SqlExecutionTimeLog
	--(UserKEY,ProcedureName,CommentText,AdditionalInfo,CreatedDate)
	--VALUes (@UserKey,'Get_OrderList_V2','Procedure Execution end','',GETDATE())

	SET @Status = 1
	SET @Reason = 'Success'
	SET ARITHABORT OFF;

	drop table #ContainerCount
	drop table #CSRKeyList 
	drop table #CustomerKeyList
	drop table #DashBoard
	drop table #FinalData_Temp
	drop table #MarketLocationKeyList
	drop table #OrderListData
	drop table #UserKeyList
	drop table #ContProps
	--drop table #OrderListData_Final
	Drop table #OrdersWithProps
	drop table #PropsKeyList
END
