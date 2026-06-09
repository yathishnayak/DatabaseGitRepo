/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_DeletedOrders_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_DeletedOrders_V2]
(
    @UserKey        INT = 952,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

	SELECT COUNT(1) AS ContainerCount, OrderKey 
	INTO #ContainerCount
	FROM dbo.OrderDetail_Deleted	
	GROUP BY OrderKey;
	
    SELECT 
        oh.OrderNo,  
        oh.OrderDate,  
        oh.CustKey,  
        cus.AddrKey AS BillToAddressKey,  
		cus.CustName AS BillToAddrName,
        oh.SourceAddrKey AS SourceAddressKey, 
		SR.AddrName AS SourceAddrName,
        oh.DestinationAddrKey AS DestinationAddressKey,
		DT.AddrName AS DestinationAddrName,
        oh.ReturnAddrKey AS ReturnAddressKey, 
        oh.OrderTypeKey,
        oh.PriorityKey,
        oh.[Status],  
		OH.StatusDate AS StatusDate,
        HR.[Description] AS HoldReason,
        oh.HoldDate,
        br.BrokerName,
        br.BrokerID,
		br.BrokerKey,
        oh.BrokerRefNo,
        oh.PortoForiginKey,
        oh.CarrierKey,
        oh.VesselName,
        oh.BillOfLading,
        oh.BookingNo,
        oh.CreateDate AS CreatedDate,
        oh.CreateUserKey AS CreatedBy,
        oh.OrderKey,
		oh.ETADate,
        ot.OrderType AS OrderTypeDescription,
        os.[Description] AS StatusDescription,    
		'' AS NextAction,
		CSR.CsrKey AS CSRKey,
		CSR.CsrName AS CSRName,
		CT.ContainerCount,
		SR.City AS PickupLocation,
		DT.City AS DeliveryLocation,
		CUS.CustName,
		--************Customer Address************
		JSON_QUERY((
					SELECT
						CA.Address1 ,
						CA.Address2 ,
						CA.AddrName ,
						CA.City		,
						CA.CityKey	,
						CA.Country	,
						CA.Email	,
						CA.Email2	,
						CA.Fax		,
						CA.[State]	,
						CA.ZipCode	AS Zip
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					)) AS CustAddress,
		--****************Source Address***********
		JSON_QUERY((
					SELECT
						SR.Address1,
						SR.Address2,
						SR.AddrName,
						SR.City		,
						SR.CityKey	,
						SR.Country	,
						SR.Email	,
						SR.Email2	,
						SR.Fax		,
						SR.[State]	,
						SR.ZipCode	AS Zip
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
					)) AS SourceAddress,
		--****************Destination Address********
		JSON_QUERY((
					SELECT
					DT.Address1,
					DT.Address2,
					DT.AddrName,
					DT.City		,
					DT.CityKey	,
					DT.Country	,
					DT.Email	,
					DT.Email2	,
					DT.Fax		,
					DT.[State]	,
					DT.ZipCode	AS Zip
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)) AS DestinationAddress,
		--******************Return Address***************
		JSON_QUERY((
					SELECT
					RT.Address1,
					RT.Address2,
					RT.AddrName,
					RT.City	   ,
					RT.CityKey	,
					RT.Country ,
					RT.Email   ,
					RT.Email2  ,
					RT.Fax	   ,
					RT.[State] ,
					RT.ZipCode AS Zip
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)) AS ReturnAddress,
		--******************Broker Address******************
		JSON_QUERY((
					SELECT
					BA.Address1 ,
					BA.Address2 ,
					BA.AddrName ,
					BA.City		,
					BA.CityKey	,
					BA.Country	,
					BA.Email	,
					BA.Email2	,
					BA.Fax		,
					BA.[State]	,
					BA.ZipCode  AS Zip
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)) AS BrokerAddress,
		--******************************
		U.UserName AS CreatedUser,
		U2.UserName AS DeletedBy,
		D.DeleteDate AS DeletedDate,
		CM.CsrKey AS CSRManagerKey,
		CM.CsrName AS CSRManagerName
		
    FROM dbo.Order_Delete D
		INNER JOIN dbo.OrderHeader_Deleted oh ON D.OrderKey = oh.OrderKey
        LEFT JOIN dbo.Customer cus ON cus.CustKey = oh.CustKey      
        LEFT JOIN dbo.[Broker] br ON oh.BrokerKey = br.BrokerKey
        LEFT JOIN dbo.OrderType ot ON oh.OrderTypeKey = ot.OrderTypeKey   
        LEFT JOIN dbo.OrderStatus os ON os.[Status] = oh.[Status]
		LEFT JOIN dbo.Holdreason HR ON HR.HoldReasonKey = oh.HoldReasonKey
		LEFT JOIN dbo.SalesPerson SP ON oh.SalesPersonKey = SP.SalesPersonKey
		LEFT JOIN dbo.CSR CSR ON oh.CSRKey = CSR.CsrKey
		LEFT JOIN dbo.CSR CM ON oh.CSRManagerKey = CM.CsrKey
		LEFT JOIN #ContainerCount CT ON CT.OrderKey = oh.OrderKey
		LEFT JOIN dbo.[Address] SR ON SR.AddrKey = oh.SourceAddrKey
		LEFT JOIN dbo.[Address] DT ON DT.AddrKey = oh.DestinationAddrKey
		LEFT JOIN dbo.[Address] CA ON cus.AddrKey = CA.AddrKey
		LEFT JOIN dbo.[Address] RT ON oh.ReturnAddrKey = RT.AddrKey
		LEFT JOIN dbo.[Address] BA ON br.AddrKey = BA.AddrKey
		LEFT JOIN dbo.[User] U ON oh.CreateUserKey = U.UserKey
		LEFT JOIN dbo.[User] U2 ON D.DeleteUserKey = U2.UserKey
	WHERE D.DeleteDate >= DATEADD(DAY,-180,CAST(GETDATE() AS DATE))
	ORDER BY oh.OrderDate, oh.OrderNo
	FOR JSON PATH;

	SET @Status = 1;
	SET @Reason = 'Success';

	DROP TABLE #ContainerCount;
END