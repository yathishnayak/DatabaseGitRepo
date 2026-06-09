/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"MarketLocationKey": 0}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_AllCustomers_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[Get_AllCustomers_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '{"MarketLocationKey": 0}',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    SET @Status = 0;
    SET @Reason = 'Failed';
    
    DECLARE @MarketLocationKey INT = 0;
    
    -- Parse JSON input
    SELECT @MarketLocationKey = ISNULL(MarketLocationKey, 0)
    FROM OPENJSON(@JSONString)
    WITH (
        MarketLocationKey INT '$.MarketLocationKey'
    );
    
    --IF(ISNULL(@MarketLocationKey, 0) = 0)
    --BEGIN
    --    SET @Status = 0;
    --    SET @Reason = 'Failed to get MarketLocationKey data';
    --    RETURN;
    --END
	 
    SELECT 
        C.CustKey AS CustKey,
        C.CustID AS CustID,
        C.CustName AS CustName,
        C.StatusKey AS StatusKey,
        0 AS CompanyKey,
        C.CustName AS CustAddrName,
        ISNULL(S.StatusName, '') AS StatusName,
        C.CustomerGroup AS CustomerGroup,
        C.StatusDate AS StatusDate,
        ISNULL(C.CreditCheck, 0) AS CreditCheck,
        ISNULL(C.CreditLimit, 0.00) AS CreditLimit,
        ISNULL(C.CreditStatus, 0) AS CreditStatus,
        ISNULL(C.Ach_Required, 0) AS AchRequired,
        ISNULL(C.PaymentTermsKey, 0) AS PaymentTermsKey,
        ISNULL(P.PaymentTermsID, '') AS PaymentTermsID,
        
        -- Address object with all required fields
        JSON_QUERY((
            SELECT 
                ISNULL(A1.Address1, '') AS Address1,
                ISNULL(A1.Address2, '') AS Address2,
                A1.AddrName AS AddrName,
                ISNULL(A1.City, '') AS City,
                ISNULL(A1.CityKey, 0) AS CityKey,
                ISNULL(A1.State, '') AS State,
                ISNULL(A1.ZipCode, '') AS Zip,
                ISNULL(A1.Phone, '') AS Phone,
                A1.Phone2 AS Phone2,
                ISNULL(A1.Fax, '') AS Fax,
                ISNULL(A1.Email, '') AS Email,
                A1.Email2 AS Email2,
                ISNULL(A1.Country, '') AS Country,
                A1.Website AS Website,
                ISNULL(A1.AddrKey, 0) AS AddrKey,
                ISNULL(A1.AddrName, '') AS Name,
                ISNULL(CA1.AddrType, '') AS AddressType,
                C.CustKey AS CustomerKey,
                0 AS OrderTypeKey,
                0 AS LegKey,
                CAST(NULL AS VARCHAR(50)) AS LoationType,
                0 AS UserKey
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS Address,
        
        C.AddrKey AS AddrKey,
        
        -- BillToAddress object with all required fields
        JSON_QUERY((
            SELECT 
                ISNULL(A2.Address1, '') AS Address1,
                ISNULL(A2.Address2, '') AS Address2,
                A2.AddrName AS AddrName,
                ISNULL(A2.City, '') AS City,
                ISNULL(A2.CityKey, 0) AS CityKey,
                ISNULL(A2.State, '') AS State,
                ISNULL(A2.ZipCode, '') AS Zip,
                ISNULL(A2.Phone, '') AS Phone,
                A2.Phone2 AS Phone2,
                ISNULL(A2.Fax, '') AS Fax,
                ISNULL(A2.Email, '') AS Email,
                A2.Email2 AS Email2,
                ISNULL(A2.Country, '') AS Country,
                A2.Website AS Website,
                ISNULL(A2.AddrKey, 0) AS AddrKey,
                ISNULL(A2.AddrName, '') AS Name,
                ISNULL(CA2.AddrType, '') AS AddressType,
                C.CustKey AS CustomerKey,
                0 AS OrderTypeKey,
                0 AS LegKey,
                CAST(NULL AS VARCHAR(50)) AS LoationType,
                0 AS UserKey
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )) AS BillToAddress,
        
        ISNULL(C.BillToAddrKey, 0) AS BillToAddrKey,
        C.IsFactored AS IsFactored,
        C.Notes AS Notes,
        ISNULL(C.IsActive, 1) AS IsActive,
        ISNULL(C.IsDelete, 0) AS IsDelete,
        CAST(NULL AS DECIMAL(18,2)) AS PendingTotal,
        CAST(NULL AS VARCHAR(MAX)) AS SalesPersonKeys,
        ISNULL(C.SalesPersonKey, 0) AS SalesPersonKey,
        ISNULL(C.CSRManagerKey, 0) AS CSRManagerKey,
        ISNULL(SP.SalesPersonName, '') AS SalesPersonName,
        ISNULL(CA.CsrName, '') AS CsrName,
        ISNULL(CM.CsrName, '') AS CSRManagerName,
        ISNULL(C.CSRKey, 0) AS CsrKey,
        ISNULL(C.MarketLocationKey, 0) AS MarketLocationKey,
        ISNULL(ML.MarketLocation, '') AS MarketLocation,
        0 AS CustomerCompanyKey,
        CAST(NULL AS VARCHAR(200)) AS CompanyName,
        0 AS RateTypeKey,
        CAST(NULL AS VARCHAR(100)) AS RateType,
        CAST(NULL AS BIT) AS IncludeFSF,
        0 AS CustomerSegmentKey,
        CAST(NULL AS VARCHAR(100)) AS CustomerSegment,
        0.0 AS RatePercent,
        CAST(NULL AS VARCHAR(MAX)) AS SellContacts,
        ISNULL(C.IsMaster, 0) AS IsMaster,
        ISNULL(C.MasterCustKey, 0) AS MasterCustKey,
        CASE 
            WHEN C.MasterCustKey IS NULL OR C.MasterCustKey = 0 THEN NULL
            ELSE (SELECT CustID FROM Customer WITH (NOLOCK) WHERE CustKey = C.MasterCustKey)
        END AS MasterCustID
        
    FROM dbo.Customer C WITH (NOLOCK)
        LEFT JOIN PaymentTerms P WITH (NOLOCK) ON P.PaymentTermsKey = C.PaymentTermsKey
        LEFT JOIN [Status] S WITH (NOLOCK) ON S.Statuskey = C.StatusKey
        LEFT JOIN SalesPerson SP WITH (NOLOCK) ON C.SalesPersonKey = SP.SalesPersonKey
        LEFT JOIN CSR CA WITH (NOLOCK) ON C.CSRKey = CA.CsrKey
        LEFT JOIN CSR CM WITH (NOLOCK) ON C.CSRManagerKey = CM.CsrKey
        LEFT JOIN Address A1 WITH (NOLOCK) ON C.AddrKey = A1.AddrKey
        LEFT JOIN CustomerAddress CA1 WITH (NOLOCK) ON C.AddrKey = CA1.AddrKey AND C.CustKey = CA1.CustKey
        LEFT JOIN Address A2 WITH (NOLOCK) ON C.BillToAddrKey = A2.AddrKey
        LEFT JOIN CustomerAddress CA2 WITH (NOLOCK) ON C.BillToAddrKey = CA2.AddrKey AND C.CustKey = CA2.CustKey
        LEFT JOIN MarketLocation ML WITH (NOLOCK) ON C.MarketLocationKey = ML.MarketLocationKey
    WHERE 
        ISNULL(C.IsActive, 1) = 1 
        AND ISNULL(C.IsDelete, 0) = 0
        AND (ISNULL(@MarketLocationKey, 0) = 0 OR ISNULL(C.MarketLocationKey, 0) = @MarketLocationKey)
    ORDER BY C.CustName
    FOR JSON PATH;
    
    SET @Status = 1;
    SET @Reason = 'Success';
END;
