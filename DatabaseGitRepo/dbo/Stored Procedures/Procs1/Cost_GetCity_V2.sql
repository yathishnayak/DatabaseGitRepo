/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX) = '{"MarketKey" : 0}'
	EXEC [Cost_GetCity_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
**/
CREATE PROCEDURE [dbo].[Cost_GetCity_V2] -- Cost_GetCity 3
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
		as
		begin
			set nocount on
			set fmtonly off

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

			select TOP 1000 CityKey, Country, State, City, ZipCode
			from LocationData WITH (NOLOCK)
			where state in (
				select distinct state 
				from COST_CostDataOutput CO WITH (NOLOCK)
				inner join MarketLocation ML WITH (NOLOCK) on CO.Market = ML.MarketLocation
				where (@MarketKey = 0 OR MarketLocationKey = @MarketKey))
			FOR JSON PATH;

			SET @Status = 1
			SET @Reason = 'Success'
		end