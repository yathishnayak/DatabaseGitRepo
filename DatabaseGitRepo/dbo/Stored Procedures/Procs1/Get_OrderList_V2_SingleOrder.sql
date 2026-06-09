/**
DECLARE 
	@UserKey INT=952,
	@JSONString NVARCHAR(MAX)='{"OrderKey":36653}',
	@Status		BIT				=	0,
	@IsDebug	BIT				=	1,
	@Reason		VARCHAR(100)	=	''
	Exec [Get_OrderList_V2_SingleOrder] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT,@IsDebug
	Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_OrderList_V2_SingleOrder]
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

	Declare
		@OrderKey		varchar(50) = ''	
		

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
		@OrderKey		=	OrderKey		
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		OrderKey			int		'$.OrderKey'
	)

	
	SELECT COUNT (1) AS ContainerCount ,OrderKey,
		(SELECT STRING_AGG(ContainerNo,',')within  GROUP (ORDER BY OrderKey ASC)) AS ContainerNos 
	INTO #ContainerCount
	FROM OrderDetail where status<>15	
	GROUP BY OrderKey;
	

	SELECT top 1
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
		CS.CsrKey as CsrKey,
		CS.CsrName as CsrName,
		oh.SalesPersonKey,
		SP.SalesPersonName,
		CM.CsrKey as CSRManagerKey,
		CM.CsrName as CSRManagerName,
		ML.MarketLocationKey,
		ML.MarketLocation,
		OH.OrderSource,
		CONS.ConsigneeName ,
		OH.ConsigneeKey,
		CT.ContainerNos,
		--IsSelectedStatusKey = Case when OH.Status = @StatusKey then 1 else 0 end
		CTO.Properties
		--CP.OrderKey as ContPropsFiltered
    FROM dbo.OrderHeader OH   with ( NOLOCK) 			
        LEFT JOIN dbo.Customer CUS	 with ( NOLOCK)		ON CUS.CustKey = OH.CustKey      
        LEFT JOIN dbo.[Broker] BR	 with ( NOLOCK)		ON OH.BrokerKey = BR.BrokerKey
        LEFT JOIN dbo.OrderType OT	 with ( NOLOCK)		ON OH.OrderTypeKey = OT.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus OS with ( NOLOCK)		ON OS.[Status] = OH.[Status]
		LEFT JOIN Dbo.Holdreason	HR with ( NOLOCK)		ON HR.HoldReasonKey=OH.HoldReasonKey
		LEft join SalesPerson SP with ( NOLOCK) on OH.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CS with ( NOLOCK) on OH.CSRKey = CS.CSRKey
		Left join CSR CM with ( NOLOCK) on OH.CSRManagerKey = CM.CsrKey
		LEFT JOIN #ContainerCount CT with ( NOLOCK)		ON CT.OrderKey=OH.OrderKey
		--LEFT JOIN #OrdersWithProps CP WITH (NOLOCK) on OH.OrderKey = CP.OrderKey
		LEFT JOIN vContainerTypeByOrder CTO WITH (NOLOCK) on OH.OrderKey = CTO.OrderKey
		LEFT JOIN [Address] SR	 with ( NOLOCK)			ON	SR.AddrKey=OH.SourceAddrKey
		LEFT JOIN [Address] DT	 with ( NOLOCK)			ON	DT.AddrKey=OH.DestinationAddrKey
		LEFT JOIN [Address] CA	 with ( NOLOCK)			ON CUS.AddrKey = CA.AddrKey
		LEFT JOIN [Address] RT	 with ( NOLOCK)			ON OH.ReturnAddrKey = RT.AddrKey
		LEFT JOIN [Address] BA	 with ( NOLOCK)			ON BR.AddrKey = BA.AddrKey
		LEFT JOIN [User] U	 with ( NOLOCK)				ON OH.CreateUserKey = U.UserKey
		LEFT JOIN MarketLocation ML WITH (NOLOCK) ON OH.MarketLocationKey =  ML.MarketLocationKey
		LEFT JOIN Customer_Consignee CONS WITH (NOLOCK) ON OH.ConsigneeKey =  CONS.ConsigneeKey
		where  OH.OrderKey = @OrderKey
		FOR JSON PATH, without_array_wrapper
		--, Include_null_values

	SET @Status = 1
	SET @Reason = 'Success'
	SET ARITHABORT OFF;

	
END