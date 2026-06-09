
CREATE PROCEDURE [dbo].[Get_DeletedOrders]
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

	SELECT COUNT (1) AS ContainerCount ,OrderKey 
	INTO #ContainerCount
	FROM OrderDetail_Deleted	
	GROUP BY OrderKey;
	
    SELECT 
        oh.OrderNo ,  oh.OrderDate ,  oh.CustKey,  
        cus.AddrKey AS BillToAddressKey,  
		cus.CustName AS BillToAddrName,
        oh.SourceAddrKey AS SourceAddressKey, 
		SR.AddrName AS SourceAddrName,
        oh.DestinationAddrKey AS DestinationAddressKey,
		DT.AddrName AS DestinationAddrName,
        oh.ReturnAddrKey AS ReturnAddressKey, 
        oh.OrderTypeKey ,oh.PriorityKey,
        oh.[Status] ,  
		OH.StatusDate    AS StatusDate,
        HR.[Description] AS HoldReason ,
        oh.HoldDate ,
        br.BrokerName,
        br.BrokerID ,
		br.BrokerKey,
        oh.BrokerRefNo ,
        oh.PortoForiginKey ,
        oh.CarrierKey,
        oh.VesselName ,
        oh.BillOfLading ,
        oh.BookingNo ,
        oh.CreateDate ,
        oh.CreateUserKey,
        oh.OrderKey,
		oh.ETADate,
        ot.OrderType AS OrderTypeDescription,
        os.Description AS StatusDescription,    
		'' AS NextAction,
		CSR.CsrKey AS CSRKey,
		CSR.CsrName AS CSRName,
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
		U2.UserName AS DeletedBy,
		d.DeleteDate as DeletedDate,
		CM.CsrKey AS CSRManagerKey,
		CM.CsrName AS CSRMAnagerName
		
    FROM Order_Delete D 
		LEFT JOIN dbo.OrderHeader_Deleted oh  WITH (NOLOCK) on D.OrderKey = OH.OrderKey
        LEFT JOIN dbo.Customer cus		WITH (NOLOCK)	ON cus.CustKey = oh.CustKey      
        LEFT JOIN dbo.[Broker] br		WITH (NOLOCK)	ON oh.BrokerKey = br.BrokerKey
        LEFT JOIN dbo.OrderType ot		WITH (NOLOCK)	ON oh.OrderTypeKey = ot.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus os	WITH (NOLOCK)	ON os.[Status] = oh.[Status]
		LEFT JOIN Dbo.Holdreason	HR	WITH (NOLOCK)	ON HR.HoldReasonKey=OH.HoldReasonKey
		LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CSR with ( NOLOCK) on OH.CSRKey = CSR.CsrKey
		Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
		LEFT JOIN #ContainerCount CT	WITH (NOLOCK)	ON CT.OrderKey=OH.OrderKey
		LEFT JOIN [Address] SR			WITH (NOLOCK)	ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] DT			WITH (NOLOCK)	ON	DT.AddrKey=OH.DestinationAddrKey

		LEFT JOIN [Address] CA			WITH (NOLOCK)	ON CUS.AddrKey = CA.AddrKey
		LEFT JOIN [Address] RT			WITH (NOLOCK)	ON OH.ReturnAddrKey = RT.AddrKey
		LEFT JOIN [Address] BA			WITH (NOLOCK)	ON BR.AddrKey = BA.AddrKey
		LEFT JOIN [User] U				WITH (NOLOCK)	ON OH.CreateUserKey = U.UserKey
		LEFT JOIN [USER] U2				WITH (NOLOCK)	ON D.DeleteUserKey = U2.UserKey
	ORDER BY OrderDate,OrderNo;
END
