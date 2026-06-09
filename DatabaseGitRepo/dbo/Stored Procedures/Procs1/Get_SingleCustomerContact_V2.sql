/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustKey": 1561}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_SingleCustomerContact_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_SingleCustomerContact_V2]
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
        ISNULL(C.Ach_Required,0) AS AchRequired,
        ISNULL(C.CreditCheck,0) AS CreditCheck,
        ISNULL(C.CreditLimit,0) AS CreditLimit,
        C.CreditStatus,
        C.CustName,
        C.CustKey, 
        C.StatusKey,
        C.CustID,
        S.StatusName,
        -- Address object with all required fields
        JSON_QUERY((
            SELECT 
                ISNULL(Z.AddrKey,0) AS AddrKey,
                ISNULL(Z.AddrName,'') AS AddrName,
                ISNULL(Z.Address1,'') AS Address1,
                ISNULL(Z.Address2,'') AS Address2,
                ISNULL(Z.City,'') AS City,
                ISNULL(Z.CityKey, 0) AS CityKey,
                ISNULL(Z.State,'') AS State,
                ISNULL(Z.ZipCode,'') AS Zip,
                ISNULL(Z.Country,'') AS Country,
                ISNULL(Z.Phone,'') AS Phone,
                ISNULL(Z.Email,'') AS Email,
                ISNULL(Z.Email2,'') AS Email2,
                ISNULL(Z.Phone2,'') AS Phone2,
                ISNULL(Z.Fax,'') AS Fax,
                ISNULL(C.CustName,'') AS CustAddrName,
                CA.AddrType AS AddressType
            FROM CustomerAddress CA WITH (NOLOCK)
            INNER JOIN [Address] Z WITH (NOLOCK) ON Z.AddrKey = CA.AddrKey
            WHERE CA.CustKey = @CustKey
            ORDER BY AddrName
            FOR JSON PATH
        )) AS Address

    FROM dbo.Customer C WITH (NOLOCK)
    INNER JOIN [Status] S WITH (NOLOCK) ON S.StatusKey = C.StatusKey 
    WHERE C.CustKey = @CustKey
      AND S.StatusName = 'Active'
    ORDER BY CustName
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;