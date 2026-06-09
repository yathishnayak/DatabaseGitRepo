/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"BrokerKey":7}'
 
EXEC [Get_BrokerByKey_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_BrokerByKey_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
As
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @BrokerKey	INT;

	-- Initialize default output values
	SET @Reason  = 'Something went wrong, Contact system administrator';
	SET @Status = 0;

	SELECT @BrokerKey =  BrokerKey
	FROM OpenJSON(@JSONString, '$')
	WITH (
		BrokerKey			INT				'$.BrokerKey'
	)

	DECLARE @JSONOutput NVARCHAR(MAX) = ''

	SET @JSONOutput = (
		SELECT B.BrokerKey,B.BrokerID,B.BrokerName,B.AddrKey,B.MarketLocationKey,
	[Address] = JSON_QUERY(
    (
        SELECT AddrKey, AddrName, Address1, Address2,City, State,ZipCode AS Zip,Country, Website,  Phone, Email,Fax, Phone2,Email2,CityKey
        FROM Address A WITH(NOLOCK)
        WHERE A.AddrKey = B.AddrKey
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    )
)
		FROM [Broker] B WITH(NOLOCK)
		WHERE B.BrokerKey = @BrokerKey
		For JSON PATH
	);

	SELECT @JSONOutput AS JSONOutput

	SET @Status = 1;
	SET @Reason = 'Success';
END