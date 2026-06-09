/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustKey": 1561}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_CustomerDetailbyCustKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_CustomerDetailbyCustKey_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"CustKey": 0}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
    SET FMTONLY OFF;
    
    DECLARE @CustKey INT = 0;
    
    -- Parse JSON input
    SELECT @CustKey = ISNULL(CustKey, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        CustKey INT '$.CustKey'
    );

	IF (@CustKey IS NULL OR @CustKey = 0)
    BEGIN
        SET @Status = 0;
        SET @Reason = 'CustKey is required and cannot be NULL or 0';
        RETURN;
    END

	SET @Status = 1;
    SET @Reason = 'Success';

	SELECT
		ISNULL(Ach_Required,0)AchRequired,
		C.AddrKey,
		C.BillToAddrKey,
		C.CreditCheck, C.CreateDate, C.CustomerGroup, S.StatusName, 
		C.CustKey, C.CustID, C.CustName, --CustomerKey alias removed
		C.Notes, C.PaymentTermsKey,C.StatusKey, C.IsActive, 
		C.IsDelete,
		C.StatusDate, 
		C.CreditLimit, C.CreditStatus, P.PaymentTermsID, IsFactored,
		C.SalesPersonKey ,C.CSRManagerKey, SP.SalesPersonName, CA.CsrName, CM.CsrName as CSRManagerName, C.CSRKey as CsrKey,
		ISNULL(C.MarketLocationKey,0) MarketLocationKey,
		CustomerCompanyKey,
		ISNULL(C.RateTypeKey,0) RateTypeKey,
		RateType,
		ISNULL(C.CustomerSegmentKey,0) CustomerSegmentKey,
		CS.CustomerSegment,
		RatePercent,IncludeFSF,CAST(ISNULL(IsMaster,0) AS BIT)IsMaster,MasterCustKey,		

		JSON_QUERY((
            SELECT 
				C.AddrKey,
                A1.AddrName		AS AddrName,
				A1.Address1		AS Address1,
				A1.Address2		AS Address2,
				CA1.AddrType	AS AddressType,
				A1.City			AS City,
				ISNULL(A1.CityKey, 0) AS CityKey,
				A1.[State]		AS [State] ,
				A1.ZipCode		AS Zip,
				A1.Country		AS Country,
				A1.Website		AS Website,
				A1.Phone,
				A1.Email,
				A1.Fax,
				A1.Phone2,
				A1.Email2
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS [Address],

		JSON_QUERY((
            SELECT 
				C.AddrKey,
                A2.AddrName		AS AddrName,
				A2.Address1		AS Address1,
				A2.Address2		AS Address2,
				CA2.AddrType	AS AddressType,
				A2.City			AS City,
				A2.CityKey		AS CityKey,
				A2.[State]		AS [State] ,
				A2.ZipCode		AS Zip,
				A2.Country		AS Country,
				A2.Website		AS Website,
				A2.Phone,
				A2.Email,
				A2.Fax,
				A2.Phone2,
				A2.Email2
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS BillToAddress,

		--Table(Customer_SellContacts) is EMPTY
		SellContacts=(SELECT ContactKey,ContactName,ContactEmail,CustomerKey 
					 FROM Customer_SellContacts WITH(NOLOCK)
					 WHERE CustomerKey=@CustKey FOR JSON PATH)

	FROM dbo.Customer C  with ( NOLOCK) 
		LEFT JOIN PaymentTerms P  with ( NOLOCK)  ON P.PaymentTermsKey=C.PaymentTermsKey
		LEFT JOIN [Status] S  with ( NOLOCK) ON S.Statuskey=C.StatusKey
		LEft join SalesPerson SP with ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
		Left join CSR CA with ( NOLOCK) on C.CSRKey = CA.CsrKey
		Left join CSR CM with ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
		LEft join Address A1 WITH (NOLOCK) ON C.AddrKey = A1.AddrKey
		leFT JOIN CustomerAddress CA1 with (nolock) on C.AddrKey = CA1.AddrKey and C.CustKey = CA1.CustKey
		LEft join Address A2 WITH (NOLOCK) ON C.BillToAddrKey = A2.AddrKey
		leFT JOIN CustomerAddress CA2 with (nolock) on C.AddrKey = CA2.AddrKey and C.CustKey = CA2.CustKey
		LEFT JOIN CustomerSegments CS WITH (NOLOCK) ON CS.CustomerSegmentKey=C.CustomerSegmentKey
		LEFT JOIN CustomerRateType CR WITH (NOLOCK) on CR.RateTypeKey=C.RateTypeKey
	WHERE C.custkey =  @CustKey
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END