

CREATE PROCEDURE [dbo].[Get_OrderListJSON_Shiva_20240401]
/*
Order Screen List
*/
	@CustomerKey		INT=0,
	@OrderDateFrom		DATE='01/01/2020',
	@OrderDateTo		DATE='01/01/2099',
	@CSRKey				INT = 0,
	@StatusKey			INT = 0,
	@marketLocationKey		INT = 0,
	@PageNo					INT = 1,
	@PageSize				INT	= 10,
	@SorField				varchar(50) = 'OrderNo',
	@IsAscending			bit = 1,
	@SearchText				varchar(50) =''
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

	-- Created from Get_OrderHeaderSearchWithAddress
	SELECT 
        OrderNo ,  OrderDate ,  CustKey,  
        BillToAddressKey,  
		BillToAddrName,
        SourceAddressKey, 
		SourceAddrName,
        DestinationAddressKey,
		DestinationAddrName,
        ReturnAddressKey, 
        OrderTypeKey,
		PriorityKey,
        [Status] ,  
		StatusDate,
        HoldReason ,
        HoldDate ,
        BrokerName,
        BrokerID ,
		BrokerKey,
        BrokerRefNo ,
        PortoForiginKey ,
        CarrierKey,
        VesselName ,
        BillOfLading ,
        BookingNo ,
        CreateDate ,
        CreateUserKey,
        OrderKey,
		ETADate,
        OrderTypeDescription,
        StatusDescription,    
		NextAction,
		ContainerCount,
		PickupLocation,
		DeliveryLocation,
		CustName,
		--************Customer Adress************
		CusAddress1,
		CusAddress2,
		CusAddrName,
		CusCity,
		CusCountry,
		CusEmail,
		CusEmail2,
		CusFax,
		CusState,
		CusZipCode,
		--****************Source Address***********
		SRAddress1,
		SRAddress2,
		SRAddrName,
		SRCity,
		SRCountry,
		SREmail,
		SREmail2,
		SRFax,
		SRState,
		SRZipCode,
		--****************Destination Address********
		DTAddress1,
		DTAddress2,
		DTAddrName,
		DTCity,
		DTCountry,
		DTEmail,
		DTEmail2,
		DTFax,
		DTState,
		DTZipCode,
		--******************Return Address***************
		RTAddress1,
		RTAddress2,
		RTAddrName,
		RTCity,
		RTCountry,
		RTEmail,
		RTEmail2,
		RTFax,
		RTState,
		RTZipCode,
		--******************Broker Adress******************
		BAAddress1,
		BAAddress2,
		BAAddrName,
		BACity,
		BACountry,
		BAEmail,
		BAEmail2,
		BAFax,
		BAState,
		BAZipCode,
		--******************************
		CreatedUsedName,
		AllowOrderDelete,
		CSRKey,
		CSRName,
		SalesPersonKey,
		SalesPersonName,
		CSRManagerKey,
		CSRManagerName,
		MarketLocationKey,
		MarketLocation,
		OrderSource,
		Consignee
	into #OrderFinal
    FROM OrderListData  			
    WHERE 
		( @OrderDateTo	IS NULL OR @OrderDateFrom IS NULL OR OrderDate IS NULL OR OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
		--AND ( @OrderDateTo	IS NULL OR OrderDate IS NULL OR OrderDate<=@OrderDateTo)
		AND ( ISNULL(@CustomerKey,0)=0 OR CustKey IS NULL OR CustKey= @CustomerKey)
		AND ( ISNULL(@CSRKey,0)=0 OR CsrKey IS NULL OR CsrKey= @CSRKey )	
		AND ( ISNULL(@StatusKey,0) = 0 OR [Status] IS NULL OR [Status] = @StatusKey)
		AND (  ISNULL(@marketLocationKey,0) = 0 OR  CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(MarketLocationKey,0) END = @marketLocationKey )
	ORDER BY OrderDate,OrderNo
	
	declare @cnt int
	select @cnt = count(1) from #OrderFinal 
	declare @STRSQL nvarchar(max) = ''

	SELECT Status, StatusDescription, COUNT(1) AS OrderCount, 'I' as Level
	INTO #StatusCount
	FROM #OrderFinal
	GROUP BY Status, StatusDescription

	insert into #StatusCount (Status, StatusDescription, OrderCount, Level )
	SELECT 0, 'All', SUM(OrderCount) AS StatusCount, 'S' AS Level FROM #StatusCount

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
END
