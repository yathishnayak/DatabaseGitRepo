/*
DECLARE @UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
	exec GetShippingPortTerminalList_V2 @UserKey,@JsonString,@IsDebug,@Status OUTPUT,@Reason OUTPUT
	select @Status,@Reason
	*/
CREATE PRocEDURE [dbo].[GetShippingPortTerminalList_V2]  --GetShippingPortTerminalList_V2
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS

BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	--IF(ISNULL(@JsonString,'')='')
	--BEGIN
	--	SET @Status=0;
	--	SET @Reason='Parameter not found';
	--	RETURN;
	--END
	
	SELECT				TerminalKey,TerminaID,PortKey,S.StatusKey,S.IsActive,S.IsDeleted,MarketLocation,PriceGrouping,--SP.ShippingPortID,
						[Address] = JSON_QUERY((SELECT '' as  [AddrName],Address1,Address2,City,CityKey,State,ZipCode AS Zip,Country, AddrKey
						FROM Address A WITH (NOLOCK) WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
	FROM				ShippingPortTerminals  S WITH (NOLOCK)
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=S.MarketLocationKey
	LEFT JOIN PriceGrouping PG WITH (NOLOCK) ON PG.PriceGroupingKey=S.PriceGroupingKey
	--LEFT JOIN ShippingPort SP WITH (NOLOCK) ON SP.ShippingPortKey=S.PortKey
	 WHERE			 ISNULL(S.IsDeleted,0) = 0 	 -- and ISNULL(S.IsActive,0) = 1 and

	ORDER BY			TerminaID ASC
						FOR JSON PATH


						SET @Status=1;
						SET @Reason='Success'
END