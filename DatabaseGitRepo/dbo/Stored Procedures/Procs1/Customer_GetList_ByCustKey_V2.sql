/*

DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustomerKey":3241}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec [Customer_GetList_ByCustKey_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason

*/
CREATE PROCEDURE [dbo].[Customer_GetList_ByCustKey_V2]
    (
    @UserKey    INT = 0,
    @JSONString NVARCHAR(MAX) = '',
    @Status     BIT = 0 OUTPUT,
    @Reason     VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;
    SET ARITHABORT ON;

    IF(@JSONString='' OR @JSONString IS NULL)
	BEGIN
        SET @Reason='Parameter not Present';
        SET @Status=0
        RETURN;
    END
    --SET @Status=1;
    --SET @Reason='Success';

    DECLARE @CustKey    INT=0
    SELECT @CustKey = CustKey
    FROM OPENJSON(@JSONString,'$')
	WITH (
		CustKey		INT		'$.CustomerKey'
		)

    -- print '@CustomerKey'
    -- print @CustKey
	Declare @AddrKey INT = 0,
			@BilltoAddrKey INT = 0
SELECT Customer=JSON_QUERY((
   Select
            C.CustKey CustomerKey, CustID AS CustId, CustName, C.AddrKey addrkey, C.CreateDate, CustomerGroup, 
            -- S.StatusName, 
            Ach_Required AS achrequired,
            BillToAddrKey, C.Notes, C.PaymentTermsKey, C.StatusKey, C.IsActive, C.IsDelete,
            C.StatusDate, CreditCheck, CreditLimit, CreditStatus, 
            IsFactored,
            C.SalesPersonKey , C.CSRManagerKey, 
            C.CSRKey,
          
            C.MarketLocationKey,
            -- ML.MarketLocation,
            ISNULL(C.MasterCustKey,0) MasterCustKey, C.IncludeFSF,
            C.CustomerCompanyKey,
		ISNULL(C.RateTypeKey,0) RateTypeKey,
		ISNULL(C.CustomerSegmentKey,0) CustomerSegmentKey,
            ISNULL(C.IsMaster,0) IsMaster, MasterCustID=(SELECT ISNULL(CustID,'N/A')
            FROM Customer WITH (NOLOCK)
            WHERE CustKey=ISNULL(C.MasterCustKey,0)),
		Address = JSON_QUERY(( SELECT	A.AddrKey,A.AddrName,A.Address1, A.Address2, A.City, A.CityKey,
						A.[State],A.ZipCode,A.Country,A.Website,
						A.Phone,A.Phone2,A.Email,A.Email2,A.Fax, A.IsValid, A.ValidAddressKey 
					FROM dbo.[Address] A	
					WHERE A.AddrKey = C.AddrKey
					FOR JSON PATH, Without_Array_Wrapper)),

		BillToAddress = JSON_QUERY(( SELECT	A.AddrKey,A.AddrName,A.Address1, A.Address2, A.City, A.CityKey,
						A.[State],A.ZipCode,A.Country,A.Website,
						A.Phone,A.Phone2,A.Email,A.Email2,A.Fax, A.IsValid, A.ValidAddressKey 
					FROM dbo.[Address] A	
					WHERE A.AddrKey = C.BillToAddrKey
					FOR JSON PATH, Without_Array_Wrapper))
        FROM dbo.Customer C  WITH ( NOLOCK)
            -- LEFT JOIN PaymentTerms P  WITH ( NOLOCK) ON P.PaymentTermsKey=C.PaymentTermsKey
            -- LEFT JOIN [Status] S  WITH ( NOLOCK) ON S.Statuskey=C.StatusKey
            -- LEFT JOIN SalesPerson SP WITH ( NOLOCK) on C.SalesPersonKey = SP.SalesPersonKey
            -- Left JOIN CSR CA WITH ( NOLOCK) on C.CSRKey = CA.CsrKey
            -- Left JOIN CSR CM WITH ( NOLOCK) on C.CSRManagerKey = CM.CsrKey
            -- LEFT JOIN Address A1 WITH (NOLOCK) ON C.AddrKey = A1.AddrKey
            -- leFT JOIN CustomerAddress CA1 WITH (nolock) on C.AddrKey = CA1.AddrKey and C.CustKey = CA1.CustKey
            -- LEFT JOIN Address A2 WITH (NOLOCK) ON C.AddrKey = A2.AddrKey
            -- leFT JOIN CustomerAddress CA2 WITH (nolock) on C.AddrKey = CA2.AddrKey and C.CustKey = CA2.CustKey
            -- LEFT JOIN MarketLocation ML WITH (NOLOCK) ON C.MarketLocationKey = ML.MarketLocationKey
            -- LEFT JOIN CustomerCompany CC ON CC.CustomerCompanyKey = C.CompanyKey
        WHERE ISNULL(C.IsActive,1)=1 AND ISNULL(C.IsDelete,0)=0
            AND C.CustKey = @CustKey
        --AND	(@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(C.MarketLocationKey,0) END = @marketLocationKey)
        --AND ISNULL(C.MarketLocationKey,0)=0
        --ORDER BY CustName

		FOR JSON PATH, WITHOUT_Array_WRAPPER)),

        DropDownList =
            JSON_QUERY((Select
                MarketLocationList =
                (SELECT MarketLocationKey, MarketLocation, IsActive
                    FROM MarketLocation
                    WHERE IsActive=1
                    FOR JSON PATH ),
                CustomerCompanyList =
                (SELECT CustomerCompanyKey, CompanyName, IsActive, IsDeleted
                    FROM CustomerCompany
                    FOR JSON PATH ),
                CustomerRateTypeList =
                (SELECT RateTypeKey, RateType
                    FROM CustomerRateType
                    FOR JSON PATH ),
                CustomerSegmentList =
                (SELECT CustomerSegmentKey, CustomerSegment
                    FROM CustomerSegments
                    FOR JSON PATH ),
                PaymentTermsList =
                (SELECT PaymentTermsKey, PaymentTermsID, Days, Description, CompanyKey, StatusKey
                    FROM PaymentTerms
                    FOR JSON PATH ),
                StatusList =
                (SELECT StatusKey, StatusName, CompanyKey, IsActive, CreateDate, [Type]
                    FROM [Status]
                    FOR JSON PATH ),
                CustomerMasterList = 
                (Select CustKey, CustName from Customer 
                    WHERE StatusKey = 1 AND CustKey <> @CustKey FOR JSON PATH)
            FOR JSON PATH, Without_Array_Wrapper))
			FOR JSON PATH, Without_Array_Wrapper

    SET @Status = 1;
    SET @Reason = 'Success';

END
