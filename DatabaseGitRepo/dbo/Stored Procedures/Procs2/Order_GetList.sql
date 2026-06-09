CREATE PROCEDURE [dbo].[Order_GetList]
/*
Order Screen List
*/
		@CustomerKey			INT=0,
		@OrderDateFrom			DATE='01/01/2020',
		@OrderDateTo			DATE='01/01/2099',
		@CSRKey					INT = 0,
		@StatusKey				INT = 0,
		@marketLocationKey		INT = 0,
		@PageNo					INT = 5,
		@PageSize				INT	= 10
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

	SELECT			COUNT (1) AS ContainerCount ,OrderKey INTO #ContainerCount
	FROM			OrderDetail	
	GROUP BY		OrderKey;
	
    SELECT			OH.OrderNo ,  OH.OrderDate ,  OH.CustKey,  
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
					ROW_NUMBER() over (Order by OrderDate,OrderNo) as RowNum
	INTO			#TMP
    FROM			dbo.OrderHeader OH   			
	LEFT JOIN		dbo.Customer CUS			ON CUS.CustKey = OH.CustKey      
	LEFT JOIN		dbo.[Broker] BR			ON OH.BrokerKey = BR.BrokerKey
	LEFT JOIN		dbo.OrderType OT			ON OH.OrderTypeKey = OT.OrderTypeKey   
	LEFT JOIN		dbo.OrderStatus OS		ON OS.[Status] = OH.[Status]
	LEFT JOIN		Dbo.Holdreason	HR		ON HR.HoldReasonKey=OH.HoldReasonKey
	LEft join		SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
	Left join		CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
	Left join		CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
	LEFT JOIN		#ContainerCount CT		ON CT.OrderKey=OH.OrderKey
	LEFT JOIN		[Address] SR				ON	SR.AddrKey=OH.SourceAddrKey
	LEFT JOIN		[Address] DT				ON	DT.AddrKey=OH.DestinationAddrKey
	LEFT JOIN		[Address] CA				ON CUS.AddrKey = CA.AddrKey
	LEFT JOIN		[Address] RT				ON OH.ReturnAddrKey = RT.AddrKey
	LEFT JOIN		[Address] BA				ON BR.AddrKey = BA.AddrKey
	LEFT JOIN		[User] U					ON OH.CreateUserKey = U.UserKey
	LEFT JOIN		MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey		
    WHERE			( @OrderDateTo	IS NULL OR @OrderDateFrom IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
					--AND ( @OrderDateTo	IS NULL OR OH.OrderDate IS NULL OR OH.OrderDate<=@OrderDateTo)
					AND ( ISNULL(@CustomerKey,0)=0 OR OH.CustKey IS NULL OR OH.CustKey= @CustomerKey)
					AND ( ISNULL(@CSRKey,0)=0 OR OH.CsrKey IS NULL OR OH.CsrKey= @CSRKey )	
					AND ( ISNULL(@StatusKey,0) = 0 OR OH.[Status] IS NULL OR OH.[Status] = @StatusKey)
					AND (  ISNULL(@marketLocationKey,0) = 0 OR  OH.MarketLocationKey = @marketLocationKey )
	ORDER BY		OrderDate,OrderNo;

	DECLARE			@RecCount INT = 0

	SET				@RecCount = (SELECT COUNT(*) FROM #TMP )

	DECLARE			@RecFrom int, @RecTo  int
	SELECT			@RecFrom = ((@PageNo - 1) * @PageSize) + 1
	SELECT			@RecTo = (@RecFrom +  @PageSize)-1


	SELECT			*, @RecCount RecCount 
	FROM			#TMP
	WHERE			RowNum between @RecFrom and @RecTo

	DROP TABLE		#TMP

END
