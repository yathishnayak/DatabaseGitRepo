/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_SalesPerson_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_SalesPerson_V2]
(
    @UserKey        INT = 714,
    @JSONString     NVARCHAR(MAX) = '',
    @Status         BIT = 0 OUTPUT,
    @Reason         VARCHAR(1000) = '' OUTPUT,
    @IsDebug        BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;	

	SELECT 
		SalesPersonKey, 
		SalesPersonID, 
		SalesPersonName, 
		FirstName, 
		LastName,
		SP.IsActive,
		SP.AddrKey,

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
                ISNULL(A.State,'') AS [State],
                ISNULL(A.Country,'') AS Country,
                ISNULL(A.Email,'') AS Email,
                ISNULL(A.Email2,'') AS Email2,
                ISNULL(A.Phone,'') AS Phone,
                ISNULL(A.Phone2,'') AS Phone2,
                ISNULL(A.Fax,'') AS Fax,
				ISNULL(A.Website, '') AS Website
            FROM Address A WITH (NOLOCK)
            WHERE A.AddrKey = SP.AddrKey
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
			)
		) AS [Address],

		LinkedUserKey,
		U.UserName as LinkedUserName
	FROM SalesPerson SP WITH (NOLOCK)
	INNER JOIN [Address]  A  WITH (NOLOCK) ON SP.AddrKey = A.AddrKey
	LEFT JOIN [User] U  WITH (NOLOCK) ON SP.LinkedUserKey = U.UserKey
	ORDER BY SalesPersonID
	FOR JSON PATH;

	IF @@ROWCOUNT = 0
	BEGIN
		SET @Status = 0
		SET @Reason = 'No data found'
		RETURN
	END

	SET @Status =1;
	SET @Reason='Success';
END