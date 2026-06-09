/*
DECLARE @UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='{"TerminalKey":270}',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
	exec GetShippingPortTerminalListByKey_V2 @UserKey,@JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
	select @Status,@Reason
	*/

CREATE PRocEDURE [dbo].[GetShippingPortTerminalListByKey_V2]  --GetShippingPortTerminalListByKey_V2 148
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END

	
	DECLARE @TerminalKey INT =	0
	SELECT @TerminalKey = TerminalKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			TerminalKey			INT			'$.TerminalKey'
		)

	IF(ISNULL(@TerminalKey, 0)=0)
	BEGIN
		SET @Status = 0;
		SET @Reason = 'Invalid or missing TerminalKey in JSON';
		RETURN;
	END

	SELECT				TerminalKey,TerminaID,PortKey,StatusKey,S.IsActive,S.IsDeleted,MarketLocation,PriceGrouping,S.PriceGroupingKey,S.MarketLocationKey,
						[Address] = JSON_QUERY( (SELECT AddrName,Address1,Address2,City,CityKey,State,ZipCode AS Zip,Country, AddrKey, Email,Email2,Phone,Phone2,Fax,Website
						FROM Address A WITH (NOLOCK)  WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
	FROM				ShippingPortTerminals  S WITH (NOLOCK)
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=S.MarketLocationKey
	LEFT JOIN PriceGrouping PG WITH (NOLOCK) ON PG.PriceGroupingKey=S.PriceGroupingKey
	WHERE				TerminalKey = @TerminalKey
	ORDER BY			TerminaID
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER


						SET @Status=1;
						SET @Reason='Success';

END