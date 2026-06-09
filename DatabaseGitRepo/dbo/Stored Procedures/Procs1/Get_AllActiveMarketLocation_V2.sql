/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{}',
	@Status BIT = 0,  @IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [Get_AllActiveMarketLocation_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_AllActiveMarketLocation_V2]
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

	SELECT		MarketLocationKey,MarketLocation,ML.AddrKey,IsActive,IsDeleted,
				[Address]= (SELECT AddrKey, AddrName,ISNULL(Address1,'') Address1,ISNULL(Address2,'') Address2,
				ISNULL(City,'') City,ISNULL(ZipCode,'') AS Zip,ISNULL(State,'') AS State,ISNULL(Country,'') Country,
				ISNULL(Email,'') Email,ISNULL(Email2,'')Email2,ISNULL(Phone,'')Phone,ISNULL(Phone2,'')Phone2,ISNULL(Fax,'')Fax
				FROM Address A WITH(NOLOCK)
				WHERE A.AddrKey=ML.AddrKey
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM		MarketLocation ML WITH(NOLOCK)
	WHERE       IsActive=1 AND IsDeleted=0
	ORDER BY	MarketLocation
	FOR JSON PATH
END