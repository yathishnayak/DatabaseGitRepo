/*
DECLARE @UserKey INT = 1144, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"MarketLocationKey":0}'
 
EXEC [Get_AllBrokerList_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Get_AllBrokerList_V2]
(
	@UserKey   INT,
	@JSONString NVARCHAR(MAX) = '',
	@Status    BIT OUTPUT,
	@Reason    NVARCHAR(MAX) OUTPUT,
	@IsDebug   BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @MarketLocationKey INT;

	-- Initialize default output values
	SET @Reason  = N'Something went wrong, Contact system administrator';
	SET @Status  = 0;

	SELECT @MarketLocationKey = MarketLocationKey
	FROM OPENJSON(@JSONString, '$')
	WITH (
		MarketLocationKey INT '$.MarketLocationKey'
	);

	DECLARE @JSONOutput NVARCHAR(MAX) = N'';

	SET @JSONOutput = (
		SELECT
			  B.BrokerKey
			, B.BrokerID
			, B.BrokerName
			, B.AddrKey
			, B.MarketLocationKey
			, ML.MarketLocation
			, [Address] =JSON_QUERY(
				(
					SELECT
						  A.AddrKey
						, A.AddrName
						, A.Address1
						, A.Address2
						, A.City
						, A.State
						, A.ZipCode AS Zip
						, A.Country
						, A.Website
						, A.Phone
						, A.Email
						, A.Fax
						, A.Phone2
						, A.Email2
						, A.CityKey
					FROM dbo.Address AS A WITH (NOLOCK)
					WHERE A.AddrKey = B.AddrKey
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				)
				)
		FROM dbo.Broker AS B WITH (NOLOCK)
		LEFT JOIN dbo.MarketLocation AS ML WITH (NOLOCK)
			ON B.MarketLocationKey = ML.MarketLocationKey
		--WHERE B.IsActive = 1 AND ISNULL(@MarketLocationKey, 0) = 0
		--   OR CASE WHEN ISNULL(@MarketLocationKey, 0) = 0
		--		   THEN 0
		--		   ELSE ISNULL(B.MarketLocationKey, 0)
		--	  END = @MarketLocationKey
		WHERE B.IsActive = 1
		  AND (
				@MarketLocationKey IS NULL
				OR @MarketLocationKey = 0
				OR B.MarketLocationKey = @MarketLocationKey
			  )
		FOR JSON PATH
	);

	-- If no brokers matched, @JSONOutput will be NULL
	IF @JSONOutput IS NULL OR @JSONOutput = N'' OR @JSONOutput = N'[]'
	BEGIN
		SET @Status = 0;
		SET @Reason = N'No data found.';
		RETURN;
	END;

	SELECT @JSONOutput AS JSONOutput;

	SET @Status = 1;
	SET @Reason = N'Success';
END;