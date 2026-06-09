/*
DECLARE @UserKey INT = 1144, 
@JSONString NVARCHAR(MAX),
@Status BIT = 0,
@Reason VARCHAR(1000), 
@IsDebug BIT = 1 
SET @JSONString ='{}' 
EXEC [Get_AllBaseRates_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason
*/
CREATE PROCEDURE [dbo].[Get_AllBaseRates_V2]
(	
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
AS 
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT top 500
		baseratekey AS BaseRateKey,
		BrokerOrClientName,
		citykey AS CityKey,		
		City as CityName,
		ClientOrBrokerKey, 
		Country,
		ZipCode, 
		B.createdate AS CreateDate, 
		B.CustID AS CustId, 
		C.CustKey,
		B.CustName as CustName, 
		EffectiveDate, 
		B.UnitPrice	,EmailContact as EmailContact
	FROM BaseRateView_V2  B
	INNER JOIN Customer C WITH(NOLOCK) ON C.CustID = B.CustID
	ORDER BY BaseRateKey  DESC 
	FOR JSON PATH;

	SET @Status = 1;
	SET @Reason = 'Success';

END