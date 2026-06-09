CREATE PROCEDURE [dbo].[Get_OrderHeaderSearchWithAddress_Sumantha]
/*
Order Screen List
*/
@CustomerKey		INT = 0,
@OrderDateFrom		DATE='01/01/2020',
@OrderDateTo		DATE='01/01/2099',
@CSRKey				INT = 0,
@StatusKey			INT = 12,
@marketLocationKey	INT = 2,
@SearchText			varchar(50) ='',
@PageNO				INT = 122,
@Limit				INT = 1000
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
	SET ARITHABORT ON;

	-- Prevent invalid values
	SET @PageNo = CASE WHEN ISNULL(@PageNo, 0) <= 0 THEN 1 ELSE @PageNo END;
	SET @Limit  = CASE WHEN ISNULL(@Limit, 0) <= 0 THEN 10000 ELSE @Limit END;

	Select AddrKey, Address1,Address2,AddrName,City,Country,Email,Email2,Fax,[State],ZipCode
	into #AddressTemp
	From DBO.[Address];

	CREATE NONCLUSTERED INDEX IX_#AddressTemp_AddrKey ON #AddressTemp(AddrKey);

	PRINT 'StatusKey: ' + CAST(ISNULL(@StatusKey, -1) AS VARCHAR)
	PRINT 'CustomerKey: ' + CAST(ISNULL(@CustomerKey, -1) AS VARCHAR)
	PRINT 'OrderDateFrom: ' + CAST(@OrderDateFrom AS VARCHAR)
	PRINT 'OrderDateTo: ' + CAST(@OrderDateTo AS VARCHAR);

	With ContainerCountCTE as (
	SELECT COUNT (1) AS ContainerCount ,OrderKey,(SELECT STRING_AGG(ContainerNo,',')within  GROUP (ORDER BY OrderKey ASC)) AS ContainerNos
	FROM OrderDetail	
	GROUP BY OrderKey),

	FilteredOH AS (
	SELECT 
		OH.OrderNo, OH.OrderDate, OH.CustKey, OH.SourceAddrKey, OH.DestinationAddrKey, OH.ReturnAddrKey,
		OH.OrderTypeKey, OH.PriorityKey, OH.[Status], OH.StatusDate, OH.HoldDate, OH.BrokerRefNo,
		OH.PortoForiginKey, OH.CarrierKey, OH.VesselName, OH.BillOfLading, OH.BookingNo, OH.CreateDate,
		OH.CreateUserKey, OH.OrderKey, OH.ETADate, OH.OrderSource, OH.Consignee, OH.SalesPersonKey,
		OH.CSRKey, OH.CSRManagerKey, OH.HoldReasonKey, OH.BrokerKey, OH.MarketLocationKey
	FROM OrderHeader OH
	
		)

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
		CT.ContainerNos
	--into OrderListData
    FROM FilteredOH OH   with ( NOLOCK) 			
        LEFT JOIN dbo.Customer CUS	 with ( NOLOCK)		ON CUS.CustKey = OH.CustKey      
        LEFT JOIN dbo.[Broker] BR	 with ( NOLOCK)		ON OH.BrokerKey = BR.BrokerKey
        LEFT JOIN dbo.OrderType OT	 with ( NOLOCK)		ON OH.OrderTypeKey = OT.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus OS with ( NOLOCK)		ON OS.[Status] = OH.[Status]
		LEFT JOIN Dbo.Holdreason	HR with ( NOLOCK)		ON HR.HoldReasonKey=OH.HoldReasonKey
		LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
		Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
		LEFT JOIN ContainerCountCTE CT with ( NOLOCK)		ON CT.OrderKey=OH.OrderKey
		LEFT JOIN [#AddressTemp] SR	 with ( NOLOCK)			ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [#AddressTemp] DT	 with ( NOLOCK)			ON	DT.AddrKey=OH.DestinationAddrKey
		LEFT JOIN [#AddressTemp] CA	 with ( NOLOCK)			ON CUS.AddrKey = CA.AddrKey
		LEFT JOIN [#AddressTemp] RT	 with ( NOLOCK)			ON OH.ReturnAddrKey = RT.AddrKey
		LEFT JOIN [#AddressTemp] BA	 with ( NOLOCK)			ON BR.AddrKey = BA.AddrKey
		LEFT JOIN [User] U	 with ( NOLOCK)				ON OH.CreateUserKey = U.UserKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
    WHERE ( OH.OrderDate BETWEEN @OrderDateFrom AND @OrderDateTo)
		AND case when isnull(@StatusKey, 0) = 0 then 0 else OH.Status end = isnull(@StatusKey, 0)
		AND case when isnull(@CustomerKey, 0) = 0 then 0 else OH.CustKey end = isnull(@CustomerKey, 0)
		AND	case when isnull(@CSRKey, 0) = 0 then 0 else OH.CsrKey end = isnull(@CSRKey, 0)
		AND case when isnull(@marketLocationKey, 0) = 0 then 0 else OH.MarketLocationKey end = isnull(@marketLocationKey, 0)
		AND
	(@SearchText is NULL) OR
		OH.OrderNo like '%' +  @SearchText + '%'  OR
		CUS.CustName like '%' +  @SearchText + '%'  OR
		SR.AddrName like '%' +  @SearchText + '%'  OR
		BR.BrokerName like '%' +  @SearchText + '%'  OR
		OH.BookingNo like '%' +  @SearchText + '%'  OR
		--ContainerNos like '%' +  @SearchText + '%' OR
		OH.BillOfLading LIKE '%' +  @SearchText + '%'
	ORDER BY OH.OrderDate, OH.OrderNo
	OFFSET (@PageNo - 1) * @Limit ROWS
	FETCH NEXT @Limit ROWS ONLY;

	Drop Table #AddressTemp
END
