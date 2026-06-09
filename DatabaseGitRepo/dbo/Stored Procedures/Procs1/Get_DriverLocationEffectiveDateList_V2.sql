/*
DECLARE @UserKey INT = 488, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 0
  SET @JSONString ='{"DriverKey":0, "CityKey":10198}'

  EXEC [Get_DriverLocationEffectiveDateList_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
  SELECT @Status Status, @Reason Reason
*/

CREATE PROCEDURE [dbo].[Get_DriverLocationEffectiveDateList_V2]
(
	@UserKey      INT=488,
	@JSONString   NVARCHAR(MAX)='',
	@Status       BIT = 0 OUTPUT,
	@Reason       VARCHAR(1000) = '' OUTPUT,
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
		@driverKey	INT     = 15,
		@CityKey		INT		= 10198

	SELECT 
	@driverKey = driverKey,
	@CityKey	 = CityKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		driverKey	INT		'$.DriverKey',
		CityKey		INT		'$.CityKey'
	)

	SELECT DISTINCT  CONVERT(VARCHAR,EffectiveDate,101) AS EffectiveDate
	FROM dbo.DriverLocationItem WITH (NOLOCK) 
	WHERE (@driverKey = 0 OR  Driverkey=@driverKey)
		AND CityKey=@CityKey 
	ORDER BY EffectiveDate DESC
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END