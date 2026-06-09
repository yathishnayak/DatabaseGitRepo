/*
Declare @UserKey INT = 486, @JsonString NVARCHAR(MAX) = '', @Status BIT = 0, @Reason VARCHAR(100) = '', @IsDebug BIT = 0
Set @JsonString = '[{"OrderNo":"FL01230307"}]' 
Exec GlobalSearch_Order @UserKey, @JsonString, @Status output, @Reason output, @IsDebug
Select @Status Status, @Reason Reason
*/

CREATE PROCEDURE [dbo].[GlobalSearch_Order]
(
	@UserKey	 INT = 0,
	@JSONString  NVARCHAR(MAX) = '',
	@Status      BIT = 0 OUTPUT,
	@Reason		 VARCHAR(100) = '' OUTPUT,
	@IsDebug     BIT = 0
)AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @OrderNo VARCHAR(50);

	IF(@IsDebug = 1)
	BEGIN
		SET @Status = 0
		SET @Reason = 'In Debug mode'
	END

	IF(ISNULL(LTRIM(RTRIM(@JSONString)),'') = '')
	 BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
	  RETURN
	 END

	SELECT @OrderNo = OrderNo
	FROM OPENJSON(@JSONString, '$')
	WITH ( OrderNo	VARCHAR(50)	 '$.OrderNo' )

	IF(ISNULL(@OrderNo, '') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'filter is null'
		Print @Reason
	  RETURN
	END

	SELECT OH.OrderKey,OrderNo,OrderDate,C.CustName,OH.OrderSource,CS.CsrName,CM.CsrName AS CSRManagerName,S.SalesPersonName,M.MarketLocation,
	       OT.OrderType,OH.BookingNo,OH.BrokerRefNo,OH.BillOfLading,OS.Description AS StatusDescription,OU.UserName AS CreatedUsedName,
		   CA.AddrName AS CusAddrName,CA.Address1 AS CusAddress1,CA.City AS CusCity,CA.[State] AS CusState,CA.Country AS CusCountry,CA.ZipCode	AS CusZipCode,
	       --SR.AddrName AS SRAddrName,SR.Address1 AS SRAddress1,SR.City AS SRCity,SR.[State]	AS SRState,SR.Country AS SRCountry,SR.ZipCode AS SRZipCode,		
		   --DT.Address1 AS DTAddress1,DT.AddrName AS DTAddrName,DT.City AS DTCity,DT.[State]	AS DTState,DT.Country AS DTCountry,DT.ZipCode AS DTZipCode,		
		   --RT.Address1 AS RTAddress1,RT.AddrName AS RTAddrName,RT.City AS RTCity,RT.[State] AS RTState,RT.Country AS RTCountry,RT.ZipCode AS RTZipCode,
    ContainerInfo =(
		  SELECT OrderDetailKey,ContainerNo
		  FROM OrderDetail OD 
		  WHERE OD.OrderKey = OH.OrderKey
		  FOR JSON PATH
	 ),
	 StopInfo=(
		SELECT OrderKey,ODS.StopTypeKey,SM.StopTypeName,ODS.CreateDate,SM.StopTypeShortcode,LocationType,AddrName,Address1,City,State,ZipCode
		FROM OrderStops ODS WITH (NOLOCK)
		LEFT JOIN Address A WITH(NOLOCK) ON A.AddrKey = ODS.StopAddrKey
		LEFT JOIN StopsMaster SM WITH(NOLOCK) ON SM.StopTypeKey = ODS.StopTypeKey
		WHERE ODS.OrderKey =  OH.OrderKey AND SM.StopTypeKey IN(1,3,5)    
		FOR JSON PATH
	)
	FROM OrderHeader OH 
	INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = OH.CustKey
	LEFT JOIN [Address] CA WITH( NOLOCK) ON CA.AddrKey = C.AddrKey
	LEFT JOIN CSR CS WITH(NOLOCK) ON CS.CsrKey = OH.CsrKey
	LEFT JOIN CSR CM WITH(NOLOCK) ON CM.CsrKey = OH.CSRManagerKey
	LEFT JOIN SalesPerson S WITH(NOLOCK) ON S.SalesPersonKey = OH.SalesPersonKey
	LEFT JOIN MarketLocation M WITH(NOLOCK) ON M.MarketLocationKey = OH.MarketLocationKey
	LEFT JOIN OrderType OT WITH(NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey 
	LEFT JOIN OrderStatus OS WITH( NOLOCK) ON OS.[Status] = OH.[Status]
	--LEFT JOIN [Address] SR WITH( NOLOCK) ON SR.AddrKey = OH.SourceAddrKey
	--LEFT JOIN [Address] DT WITH( NOLOCK) ON DT.AddrKey = OH.DestinationAddrKey
	--LEFT JOIN [Address] RT WITH( NOLOCK) ON RT.AddrKey = OH.ReturnAddrKey  
	LEFT JOIN [User] OU WITH(NOLOCK) ON OU.UserKey = OH.CreateUserKey
	WHERE OH.OrderNo LIKE '%' + @OrderNo + '%'
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END

--select  * from OrderStops where stoptypekey = 5
--select * from OrderDetail where orderkey = 77142