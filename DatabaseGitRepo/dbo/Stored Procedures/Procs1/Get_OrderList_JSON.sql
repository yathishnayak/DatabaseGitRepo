

CREATE PROCEDURE [dbo].[Get_OrderList_JSON] -- [Get_OrderList_JSON] @statuskey = 1, @MarketLocationKey = 2, @SearchText = 'Flexport', @Pageno = 3, @IsAscending = 0
/*
Order Screen List
*/
(
	@CustomerKey			INT=0,
	@OrderDateFrom			DATE='01/01/2020',
	@OrderDateTo			DATE='01/01/2099',
	@CSRKey					INT = 0,
	@StatusKey				INT = 0,
	@marketLocationKey		INT = 0,
	@PageNo					INT = 1,
	@PageSize				INT	= 10,
	@SorField				varchar(50) = 'OrderNo',
	@IsAscending			bit = 1,
	@SearchText				varchar(50) =''
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

	SELECT COUNT (1) AS ContainerCount,od.OrderKey 
	INTO #ContainerCount
	FROM OrderDetail OD with ( NOLOCK)
	inner join OrderHeader OH with ( NOLOCK) on Od.OrderKey = OH.OrderKey
	GROUP BY od.OrderKey;

	--select count(1) as ContCount from #ContainerCount

	--IF(@OrderDateFrom='01/01/2020')
	--BEGIN
	--	SET @OrderDateFrom='01/01/2023'
	--END

	DECLARE @StrSql nvarchar(max) = ''

	
    SELECT 
        OH.OrderNo ,  OH.OrderDate ,  OH.CustKey,  
        CUS.AddrKey AS BillToAddressKey,  
		CUS.CustName AS BillToAddrName,
        OH.SourceAddrKey AS SourceAddressKey, 
		SR.AddrName AS SourceAddrName,
        OH.DestinationAddrKey AS DestinationAddressKey,
		DT.AddrName AS DestinationAddrName,
        OH.ReturnAddrKey AS ReturnAddressKey, 
        OH.OrderTypeKey ,oh.PriorityKey,
        OH.[Status] ,  
		OH.StatusDate    AS StatusDate,
        HR.[Description] AS HoldReason ,
        oh.HoldDate ,
        BR.BrokerName,
        BR.BrokerID ,
		BR.BrokerKey,
        OH.BrokerRefNo ,
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
		OH.Consignee, 
		CUS.CustID
	INTO #ORDERS
    FROM dbo.OrderHeader OH   			
        LEFT JOIN dbo.Customer CUS		with ( NOLOCK)	ON CUS.CustKey = OH.CustKey      
        LEFT JOIN dbo.[Broker] BR		with ( NOLOCK)	ON OH.BrokerKey = BR.BrokerKey
        LEFT JOIN dbo.OrderType OT		with ( NOLOCK)	ON OH.OrderTypeKey = OT.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus OS	with ( NOLOCK)	ON OS.[Status] = OH.[Status]
		LEFT JOIN Dbo.Holdreason HR		with ( NOLOCK)	ON HR.HoldReasonKey=OH.HoldReasonKey
		LEft join SalesPerson SP		with ( NOLOCK)  on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CS				with ( NOLOCK)  on OH.CSRKey = CS.CSRKey
		Left join CSR CM				with ( NOLOCK)  on OH.CSRManagerKey = CM.CsrKey
		LEFT JOIN #ContainerCount CT	with ( NOLOCK)	ON CT.OrderKey=OH.OrderKey
		LEFT JOIN [Address] SR			with ( NOLOCK)	ON SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] DT			with ( NOLOCK)	ON DT.AddrKey=OH.DestinationAddrKey
		LEFT JOIN [Address] CA			with ( NOLOCK)	ON CUS.AddrKey = CA.AddrKey
		LEFT JOIN [Address] RT			with ( NOLOCK)	ON OH.ReturnAddrKey = RT.AddrKey
		LEFT JOIN [Address] BA			with ( NOLOCK)	ON BR.AddrKey = BA.AddrKey
		LEFT JOIN [User] U				with ( NOLOCK)	ON OH.CreateUserKey = U.UserKey
		LEFT JOIN MarketLocation ML		WITH (NOLOCK)	ON OH.MarketLocationKey =  ML.MarketLocationKey
	 WHERE
		 (  ISNULL(@marketLocationKey,0) = 0 OR   ISNULL(OH.MarketLocationKey,0)  = @marketLocationKey )

	--select count(1) OrderCountBefore  from #ORDERS

	SELECT Status, StatusDescription, COUNT(1) AS OrderCount, 'I' as Level
	INTO #StatusCount
	FROM #ORDERS
	GROUP BY Status, StatusDescription

	insert into #StatusCount (Status, StatusDescription, OrderCount, Level )
	SELECT 0, 'All', SUM(OrderCount) AS StatusCount, 'S' AS Level FROM #StatusCount

	--select * from #StatusCount

	select *
	into #OrderFinal
	from #ORDERS
	WHERE ( @OrderDateTo	IS NULL OR @OrderDateFrom IS NULL OR OrderDate IS NULL OR OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
		AND ( ISNULL(@CustomerKey,0)=0 OR CustKey IS NULL OR CustKey= @CustomerKey)
		AND ( ISNULL(@CSRKey,0)=0 OR CsrKey IS NULL OR CsrKey= @CSRKey )	
		AND ( ISNULL(@StatusKey,0) = 0 OR [Status] IS NULL OR [Status] = @StatusKey)
		AND (  ISNULL(@marketLocationKey,0) = 0 OR  CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(MarketLocationKey,0) END = @marketLocationKey )
		AND	(isnull(@SearchText,'') =  '' OR (OrderNo like '%' + @SearchText + '%' OR OrderTypeDescription  like '%' + @SearchText + '%'  OR 
				BrokerRefNo like '%' + @SearchText + '%' OR BillOfLading  like '%' + @SearchText + '%'  OR BookingNo  like '%' + @SearchText + '%' 
				OR Consignee like '%' + @SearchText + '%' OR PickupLocation  like '%' + @SearchText + '%'  OR DeliveryLocation  like '%' + @SearchText + '%'
				OR CustID  like '%' + @SearchText + '%'  OR CustName  like '%' + @SearchText + '%' OR CSRName  like '%' + @SearchText + '%' ))

	--select count(1) FinalOrdercount  from #OrderFinal 
	--select * into OrderListData from #OrderFinal

	declare @cnt int
	select @cnt = count(1) from #OrderFinal 

	SET @STRSQL = '
	SELECT *, ' + convert(Varchar,@cnt) + ' as RecCount  FROM (
		select top 1000000 *, ROW_NUMBER() Over(Order by ' + @SorField + ' ' + CASE @IsAscending WHEN 0 THEN 'DESC' ELSE 'ASC' END + ' ) RowNum
		from #OrderFinal
		where (' + convert(varchar, isnull(@StatusKey,0)) + ' = 0 OR Status = ' +  convert(varchar, isnull(@StatusKey,0)) + ')'+
	+') a
	where ROWnUM  between  ' + CONVERT(VARCHAR,(((@PageNo - 1) * @PageSize) + 1))  + ' AND ' + CONVERT(VARCHAR, (((@PageNo ) * @PageSize)))
	+' Order BY ROWNUM'

	select *,0 as RowNum, 0 as RecCount into  #OrderData_temp from #OrderFinal WHERE 1 <> 1 

	PRINT (@STRSQL)
	insert into #OrderData_temp
	EXEC (@STRSQL)

	select 
	DashboardData = (
		select * from #StatusCount
		FOR JSON PATH
	),
	OrderList = (
		select * from #OrderData_temp A 
		FOR JSON PATH
	)  FOR JSON PATH
	
	drop table #ContainerCount
	drop table #ORDERS
	drop table #StatusCount
	drop table #OrderFinal
END