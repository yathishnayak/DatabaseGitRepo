/**
DECLARE 
	@UserKey INT = 714,
	@JSONString NVARCHAR(MAX)='',
	@Status BIT = 0,  
	@IsDebug BIT = 0,
	@Reason VARCHAR(100) = ''
EXEC [GetActiveYardList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status AS Status, @Reason AS Reason 
**/

CREATE PROCEDURE [dbo].[GetActiveYardList_V2]
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

	SELECT				
		YardId,ShortName,[Name],MarketLocationKey,IsActive,IsDeleted,
		[Address] = (SELECT AddrName,Address1,Address2,City,CityKey,[State],ZipCode AS Zip,Country, AddrKey
		FROM Address A WITH (NOLOCK) WHERE (Y.AddrKey=A.AddrKey)
		FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM Yard Y WITH (NOLOCK)
	WHERE ISNULL(IsActive,0) = 1 AND ISNULL(IsDeleted,0) = 0
	ORDER BY [Name]
	FOR JSON PATH

	SET @Status = 1;
    SET @Reason = 'Success';

END