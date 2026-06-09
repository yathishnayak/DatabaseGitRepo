/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketKey" : 3}'
	EXEC [Cost_GetCity_V3] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Cost_GetCity_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT = 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;

		IF ISNULL(@JSONString, '') = ''
			BEGIN
				SET		@Status = 0
				SET		@Reason = 'Parameters not found'
				RETURN
			END	

		DECLARE
			@MarketKey		int

		SELECT 
			@MarketKey	= MarketKey
		FROM OPENJSON(@JSONString)
		WITH
		(
			MarketKey		INT			'$.MarketKey'
		)

	SELECT
		L.CityKey,
		L.Country,
		L.State,
		L.City,
		L.ZipCode
	FROM LocationData L WITH (NOLOCK)
	WHERE L.State IN
	(
		SELECT DISTINCT CO.State
		FROM COST_CostDataOutput CO WITH (NOLOCK)
		INNER JOIN MarketLocation ML WITH (NOLOCK)
			ON CO.Market = ML.MarketLocation
		WHERE ML.MarketLocationKey = @MarketKey
	)
	FOR JSON PATH

	SET @Status = 1
	SET @Reason = 'Success'
END
