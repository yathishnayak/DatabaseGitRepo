/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"CustKey" : 3206, "CityKey" : 44385}'
	EXEC [Get_CustomerLocationEffectiveDateList_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Get_CustomerLocationEffectiveDateList_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@CustomerKey	INT     = 15,
		@CityKey		INT		= 10198

	SELECT 
	@CustomerKey = CustomerKey,
	@CityKey	 = CityKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		CustomerKey	INT		'$.CustKey',
		CityKey		INT		'$.CityKey'
	)

	SELECT DISTINCT  CONVERT(VARCHAR,EffectiveDate,101) AS EffectiveDate
	FROM dbo.CustomerItemRate WITH (NOLOCK) 
	WHERE CustomerKey=@CustomerKey AND CityKey=@CityKey 
	ORDER BY EffectiveDate DESC
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END