/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_AllMarketLocation_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_AllMarketLocation_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SET @Status = 1;
	SET @Reason = 'Success';

	SELECT 
    ML.MarketLocationKey,
    ML.MarketLocation,
    ML.AddrKey,
    ML.IsActive,
    ML.IsDeleted,

    JSON_QUERY(
        (
            SELECT 
                A.AddrKey,
                A.AddrName,
                ISNULL(A.Address1,'') AS Address1,
                ISNULL(A.Address2,'') AS Address2,
                ISNULL(A.City,'') AS City,
                A.CityKey,
                ISNULL(A.ZipCode,'') AS Zip,
                ISNULL(A.State,'') AS State,
                ISNULL(A.Country,'') AS Country,
                ISNULL(A.Email,'') AS Email,
                ISNULL(A.Email2,'') AS Email2,
                ISNULL(A.Phone,'') AS Phone,
                ISNULL(A.Phone2,'') AS Phone2,
                ISNULL(A.Fax,'') AS Fax
            FROM Address A WITH (NOLOCK)
            WHERE A.AddrKey = ML.AddrKey
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    ) AS [Address]

FROM MarketLocation ML WITH (NOLOCK)
--WHERE ML.IsActive = 1
ORDER BY ML.MarketLocation
FOR JSON PATH;

END