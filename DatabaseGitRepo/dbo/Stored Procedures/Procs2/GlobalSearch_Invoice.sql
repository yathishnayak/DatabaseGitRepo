/*
Declare @UserKey INT = 486, @JsonString NVARCHAR(MAX) = '', @Status BIT = 0, @Reason VARCHAR(100) = '', @IsDebug BIT = 0
Set @JsonString = '[{"InvoiceNo":"47133"}]' 
Exec GlobalSearch_Invoice @UserKey, @JsonString, @Status output, @Reason output, @IsDebug
Select @Status Status, @Reason Reason
*/

CREATE PROCEDURE [dbo].[GlobalSearch_Invoice]
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

	DECLARE @InvoiceNo VARCHAR(50);

	IF(@IsDebug = 1)
	BEGIN
		SET @Status = 0
		SET @Reason = 'In Debug mode'
	END

	SELECT @InvoiceNo = InvoiceNo
	FROM OPENJSON(@JSONString, '$')
	WITH ( InvoiceNo	VARCHAR(50)	 '$.InvoiceNo' )

	IF(ISNULL(@InvoiceNo, '') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'filter is null'
		Print @Reason
	  RETURN
	END
	  
	SELECT distinct  IH.InvoiceKey,IH.InvoiceNo,OD.OrderDetailKey,OrderNo,OD.OrderKey,OD.ContainerNo,C.CustName,InvoiceAmount,CU.UserName AS InvoiceCreatedBy,IH.CreateDate AS InvoiceCreatedDate,
	       IU.UserName AS InvoiceApprovedBy,InvoiceApprovedDate,TruckType,OD.LinkedContainerNo,MarketLocation,CompanyName,[Description] AS InvoiceStatus,C.IsFactored,
		   IH.InternalNote,IH.CustomerNote,PaymentRecdDate,A.ArchivedDate,
	RoutesInfo =(
		SELECT RouteKey,CarrierAssignedBy,UserName AS Dispatchers 
		FROM [Routes] RT WITH(NOLOCK)
		INNER JOIN  [User] CA WITH(NOLOCK) ON CA.UserKey = CarrierAssignedBy
		WHERE  OD.OrderDetailKey= RT.OrderDetailKey
	    FOR JSON PATH
	),
	StopInfo=(
		SELECT OrderDetailKey,ODS.StopTypeKey,SM.StopTypeName,ODS.CreateDate,SM.StopTypeShortcode,LocationType,AddrName,Address1,City,State,ZipCode
		FROM OrderDetailStops ODS WITH (NOLOCK)
		LEFT JOIN Address A WITH(NOLOCK) ON A.AddrKey = ODS.StopAddrKey
		LEFT JOIN StopsMaster SM WITH(NOLOCK) ON SM.StopTypeKey = ODS.StopTypeKey
		WHERE ODS.OrderDetailKey =  OD.OrderDetailKey AND SM.StopTypeKey IN(1,3,5)    
		FOR JSON PATH
		)
	FROM  InvoiceHeader IH
	inner JOIN OrderHeader OH WITH (NOLOCK) ON IH.OrderKey = OH.OrderKey
	inner JOIN OrderDetail OD WITH (NOLOCK) ON OD.OrderKey = OH.OrderKey
	LEFT JOIN Customer C WITH(NOLOCK) ON C.CustKey = IH.CustKey
	LEFT JOIN [Routes] R WITH (NOLOCK) ON OD.RouteKey= R.RouteKey
	LEFT JOIN Driver D WITH(NOLOCK) ON D.DriverKey = R.DriverKey
	LEFT JOIN TruckType T WITH(NOLOCK) ON T.TruckTypeKey = D.TruckTypeKey
	LEFT JOIN MarketLocation M WITH(NOLOCK) ON M.MarketLocationKey = OH.MarketLocationKey
	LEFT JOIN BillingCompanyInfo B WITH(NOLOCK) ON B.Companykey = OH.Companykey
	LEFT JOIN InvoiceStatus S WITH (NOLOCK) ON S.StatusKey = IH.StatusKey
	LEFT JOIN ArchivedInvoiceHistory A WITH(NOLOCK) ON A.InvoiceKey = IH.InvoiceKey
	LEFT JOIN [User] CU WITH(NOLOCK) ON CU.UserKey = IH.CreateUserkey
	LEFT JOIN [User] IU WITH(NOLOCK) ON IU.UserKey = IH.InvoiceApprovedUserKey						
	WHERE  IH.InvoiceNo LIKE '%' + @InvoiceNo + '%' 
 FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END 


	--select * from  ArchivedInvoiceHistory order by ArchivedKey desc
	--searchcolumn_sumantha 'Archive'


	-- Alter table ArchivedInvoiceHistory add ArchivedDate datetime
