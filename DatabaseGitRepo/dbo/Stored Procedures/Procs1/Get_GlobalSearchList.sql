/*
Declare @UserKey INT = 486, @JsonString NVARCHAR(MAX) = '', @Status BIT = 0, @Reason VARCHAR(100) = '', @IsDebug BIT = 0
Set @JsonString = '[{"OrderNo":"GBI012409888","ContainerNo":"","InvoiceNo":"","VoucherNo":""}]' 
Exec Get_GolbalSearchList @UserKey, @JsonString, @Status output, @Reason output, @IsDebug
Select @Status Status, @Reason Reason
*/

create Procedure [dbo].[Get_GlobalSearchList] 
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

	DECLARE @OrderNo     VARCHAR(50),
			@ContainerNo VARCHAR(50),
			@InvoiceNo   VARCHAR(50),
			@VoucherNo   VARCHAR(50) ,
			@JSONOutput  NVARCHAR(MAX)=''

	IF(ISNULL(LTRIM(RTRIM(@JSONString)),'') = '')
	 BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
	  RETURN
	 END

	IF(@IsDebug = 1)
	 BEGIN
		SET @Status = 0
		SET @Reason = 'In Debug mode'
	 END

	SELECT @OrderNo = OrderNo, @ContainerNo = ContainerNo, @InvoiceNo = InvoiceNo, @VoucherNo = VoucherNo  
	FROM OPENJSON(@JSONString, '$')
	WITH ( OrderNo     VARCHAR(50) '$.OrderNo',
		   ContainerNo VARCHAR(50) '$.ContainerNo',
		   InvoiceNo   VARCHAR(50)	'$.InvoiceNo',
		   VoucherNo   VARCHAR(50)	'$.VoucherNo'
		 )

	IF(ISNULL(@OrderNo, '') = '' and Isnull(@ContainerNo, '') = '' and Isnull(@InvoiceNo, '') = '' and Isnull(@VoucherNo, '') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Atleast one filter should not be null'
		Print @Reason
	  RETURN
	END

	CREATE TABLE  #OrderKey
	(
		OrderKey		INT
	)

	CREATE TABLE  #OrderDetailKey
	(
		OrderDetailKey INT
	)

	CREATE TABLE  #InvoiceKey
	(
		InvoiceKey		INT
	)

	CREATE TABLE  #VoucherKey
	(
		VoucherKey		INT
	)

	SET @OrderNo = ISNULL(@OrderNo,'')
	SET @ContainerNo = ISNULL(@ContainerNo,'')
	SET @VoucherNo = ISNULL(@VoucherNo,'')
	SET @InvoiceNo = ISNULL(@InvoiceNo,'')

	SELECT			DISTINCT OD.Orderkey, OD.OrderDetailKey, VD.Voucherkey, ID.InvoiceKey
	INTO			#AllData
	FROM			OrderHeader OH
	INNER JOIN		OrderDetail OD ON OH.OrderKey = OD.OrderKey
	INNER JOIN		Routes RT ON OD.OrderDetailKey = RT.OrderDetailKey
	LEFT JOIN		VoucherDetail VD ON VD.RouteKey = RT.RouteKey
	LEFT JOIN		VoucherHeader VH ON VD.Voucherkey = VH.VoucherKey
	LEFT JOIN		Invoicedetail ID ON ID.OrderDetailKey = OD.OrderDetailKey
	LEFT JOIN		InvoiceHeader IH ON ID.InvoiceKey = IH.InvoiceKey
	WHERE			(OH.OrderNo LIKE '%' +  @OrderNo + '%' OR '' = @OrderNo)
					AND (VH.VoucherNo LIKE '%' +  @VoucherNo + '%' OR '' = @VoucherNo)
					AND (OD.ContainerNo LIKE '%' + @ContainerNo + '%' OR '' = @ContainerNo)
					AND (IH.InvoiceNo LIKE '%' + @InvoiceNo + '%' OR '' = @InvoiceNo)

	
	INSERT INTO #OrderKey
	SELECT DISTINCT OrderKey FROM #AllData

	INSERT INTO #OrderDetailKey
	SELECT DISTINCT OrderDetailKey FROM #AllData

	INSERT INTO #InvoiceKey
	SELECT DISTINCT InvoiceKey FROM #AllData

	INSERT INTO #VoucherKey
	SELECT DISTINCT VoucherKey FROM #AllData

	SET @JSONOutput = (
	SELECT OH.OrderKey,OrderNo,OrderDate,C.CustName,OH.OrderSource,CS.CsrName,CM.CsrName AS CSRManagerName,S.SalesPersonName,M.MarketLocation,
	       OT.OrderType,OH.BookingNo,OH.BrokerRefNo,OH.BillOfLading,OS.Description AS StatusDescription,OU.UserName AS CreatedUsedName,
		   CA.AddrName AS CusAddrName,CA.Address1 AS CusAddress1,CA.City AS CusCity,CA.[State] AS CusState,CA.Country AS CusCountry,CA.ZipCode	AS CusZipCode,
	       SR.AddrName AS SRAddrName,SR.Address1 AS SRAddress1,SR.City AS SRCity,SR.[State]	AS SRState,SR.Country AS SRCountry,SR.ZipCode AS SRZipCode,		
		   DT.Address1 AS DTAddress1,DT.AddrName AS DTAddrName,DT.City AS DTCity,DT.[State]	AS DTState,DT.Country AS DTCountry,DT.ZipCode AS DTZipCode,		
		   RT.Address1 AS RTAddress1,RT.AddrName AS RTAddrName,RT.City AS RTCity,RT.[State] AS RTState,RT.Country AS RTCountry,RT.ZipCode AS RTZipCode,
		ContainerInfo =(
			SELECT OrderDetailKey,ContainerNo,[Weight],CS.[Description] AS ContainerSize,OD.LinkedContainerNo,CU.UserName AS CreatedUsedName,CreateDate,
				   STUFF((
						SELECT ',' + CT.TypeID
						FROM ContainerTypesLink	CTL	WITH (NOLOCK)	
									LEFT JOIN ContainerTypes CT		WITH (NOLOCK)	ON CTL.ContainerTypeKey = CT.ContainerTypeKey
									WHERE OD.OrderDetailKey = CTL.OrderDetailKey
								 
						FOR XML PATH('')
                        ), 1, 1, '') AS Properties,
				VoucherInfo =(
					SELECT VH.VoucherKey,VoucherNo,VoucherAmount,'WK-' +  CONVERT(VARCHAR,DATEPART(iso_week,A.MinArrival)) AS WeekNum,
							CU.UserName AS VoucherCreatedBy,VH.VoucherDate,UU.UserName AS VoucherUpdatedBy,VH.UpdateDate AS VoucherUpdatedDate,
							VU.UserName AS PmtApprovedBy,PU.UserName AS PaidBy,PaidDate,(D.FirstName + D.LastName) AS DriverName
							FROM [Routes] R
							LEFT JOIN RouteVouchers RV WITH (NOLOCK) ON RV.RouteKey=R.RouteKey
							INNER JOIN (SELECT * FROM VoucherHeader WITH(NOLOCK) WHERE VoucherKey IN 
							(SELECT DISTINCT VoucherKey FROM #AllData WHERE ISNULL(VoucherKey,0) > 0)) VH  ON VH.Voucherkey = RV.VoucherKey
							LEFT JOIN vVoucherWeekNums A on A.VoucherKey = VH.VoucherKey
							INNER JOIN dbo.Driver D	WITH (NOLOCK) ON D.DriverKey = R.DriverKey
							--INNER JOIN VoucherDetail VD WITH(NOLOCK) ON VD.Voucherkey = VH.VoucherKey
							--INNER JOIN Item I WITH (NOLOCK) ON VD.ItemKey=I.ItemKey
							LEFT JOIN [USER] CU WITH(NOLOCK) ON CU.UserKey = VH.CreateUserKey
							LEFT JOIN [User] UU WITH(NOLOCK) ON UU.UserKey = VH.UpdateUserKey	 
							LEFT JOIN [User] VU WITH(NOLOCK) ON VU.UserKey = VH.PmtApprovedUser
							LEFT JOIN [User] PU WITH(NOLOCK) ON PU.UserKey = VH.PaidUserKey  
							WHERE OD.OrderDetailKey = R.OrderDetailKey
							FOR JSON PATH
			    )  
			FROM (SELECT * FROM OrderDetail WHERE OrderDetailKey IN (SELECT DISTINCT OrderDetailKey FROM #AllData
			WHERE ISNULL(OrderDetailKey,0) > 0)) OD 
			--INNER JOIN  OrderHeader OH WITH(NOLOCK) ON OH.OrderKey = OD.OrderKey
			LEFT JOIN ContainerSize CS WITH(NOLOCK) ON CS.ContainerSizeKey =OD.ContainerSizeKey
			LEFT JOIN [User] CU WITH(NOLOCK) ON CU.UserKey = OD.CreateUserKey  
			WHERE OD.OrderKey = OH.OrderKey
			FOR JSON PATH
	    ),
	InvoiceInfo=(
			SELECT IH.InvoiceKey,InvoiceNo,InvoiceAmount,CU.UserName AS InvoiceCreatedBy,IH.CreateDate AS InvoiceCreatedDate,
		    IU.UserName AS InvoiceApprovedBy,InvoiceApprovedDate,PU.UserName AS PaymentRecdBy,PaymentRecdDate
		    FROM (SELECT * FROM InvoiceHeader WHERE InvoiceKey IN (SELECT DISTINCT InvoiceKey FROM #AllData 
			WHERE ISNULL(InvoiceKey,0) > 0)) IH
		--	INNER JOIN Invoicedetail ID WITH(NOLOCK) ON ID.InvoiceKey = IH.InvoiceKey
			LEFT JOIN [User] CU WITH(NOLOCK) ON CU.UserKey = IH.CreateUserkey
			LEFT JOIN [User] IU WITH(NOLOCK) ON IU.UserKey = IH.InvoiceApprovedUserKey
			LEFT JOIN [User] PU WITH(NOLOCK) ON PU.UserKey = IH.PaymentRecdUserKey							
			WHERE  IH.OrderKey =  OH.OrderKey
			FOR JSON PATH
	)
	FROM OrderHeader OH 
	INNER JOIN (SELECT DISTINCT OrderKey FROM #AllData WHERE ISNULL(OrderKey,0) > 0)  TOK ON OH.OrderKey = TOK.OrderKey
	INNER JOIN Customer C WITH(NOLOCK) ON C.CustKey = OH.CustKey
	LEFT JOIN [Address] CA WITH( NOLOCK) ON CA.AddrKey = C.AddrKey
	LEFT JOIN CSR CS WITH(NOLOCK) ON CS.CsrKey = OH.CsrKey
	LEFT JOIN CSR CM WITH(NOLOCK) ON CM.CsrKey = OH.CSRManagerKey
	LEFT JOIN SalesPerson S WITH(NOLOCK) ON S.SalesPersonKey = OH.SalesPersonKey
	LEFT JOIN MarketLocation M WITH(NOLOCK) ON M.MarketLocationKey = OH.MarketLocationKey
	LEFT JOIN OrderType OT WITH(NOLOCK) ON OH.OrderTypeKey = OT.OrderTypeKey 
	LEFT JOIN OrderStatus OS WITH( NOLOCK) ON OS.[Status] = OH.[Status]
	LEFT JOIN [Address] SR WITH( NOLOCK) ON SR.AddrKey = OH.SourceAddrKey
	LEFT JOIN [Address] DT WITH( NOLOCK) ON DT.AddrKey = OH.DestinationAddrKey
	LEFT JOIN [Address] RT WITH( NOLOCK) ON RT.AddrKey = OH.ReturnAddrKey  
	LEFT JOIN [User] OU WITH(NOLOCK) ON OU.UserKey = OH.CreateUserKey  
	--WHERE OH.OrderNo = @OrderNo  
	FOR JSON PATH)

	SET @Status = 1
	SET @Reason = 'Success'

	SELECT @JSONOutput
END
