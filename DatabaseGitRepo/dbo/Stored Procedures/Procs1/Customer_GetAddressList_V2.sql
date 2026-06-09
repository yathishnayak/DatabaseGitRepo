/**
DECLARE 
	@UserKey INT=714,
	@JSONString NVARCHAR(MAX)='{"CustomerKey":3241}',
	@Status BIT=0,@IsDebug		BIT = 1,
	@Reason VARCHAR(100)=''
EXec [Customer_GetAddressList_V2] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
Select @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Customer_GetAddressList_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET CONCAT_NULL_YIELDS_NULL ON

	Declare	@CustomerKey		int	= 0;

	Select @CustomerKey = CustomerKey
	FROM	OPENJSON(@JsonString, '$')
	WITH (
		CustomerKey		INT		'$.CustomerKey'
		)

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0;
		SET		@Reason = 'Parameters not found';
		RETURN;
	END	

	SET		@Status = 1;
	SET		@Reason = 'Success';

	SELECT	@CustomerKey AS CustomerKey, 
			CustAddressList = JSON_QUERY((SELECT ISNULL(Z.AddrName,'') AS AddrName,ISNULL(Z.Address1,'') AS Address1,
							ISNULL(Z.Address2,'') AS Address2,ISNULL(Z.City,'') AS City, ISNULL(Z.CityKey,'') AS CityKey,
							ISNULL(Z.State,'')AS State,
							ISNULL(Z.ZipCode,'') AS ZipCode
							,ISNULL(Z.Country,'')AS Country,ISNULL(Z.Phone,'' ) AS Phone,ISNULL(Z.Email,'') AS Email,
							ISNULL(Z.Email2,'') AS Email2 ,ISNULL(Z.Phone2,'') AS Phone2 ,ISNULL(Z.Fax,'')AS Fax,
							CA.AddrType as AddressType,Z.AddrKey
							FROM CustomerAddress CA WITH(NOLOCK) 
							INNER JOIN [Address] Z WITH(NOLOCK) ON Z.AddrKey=CA.AddrKey 
							WHERE CA.CustKey = @CustomerKey  	
							ORDER BY AddrName
							FOR JSON PATH))
			FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
