CREATE PRocedure [dbo].[GetPortByKey_V2]  --GetPortByKey   59
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

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	--** Main Object **--
	DECLARE 	@ShippingPortKey	INT

	SELECT @ShippingPortKey = ShippingPortKey
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			ShippingPortKey		INT		'$.ShippingPortKey'
		)
	
	SET @Reason='Success'
	SET @Status=1


	SELECT				PriceGroupingKey,ShippingPortKey,ShippingPortID,MarketLocationKey,IsActive,IsDeleted,StatusKey,S.AddrKey,
						[Address] = JSON_QUERY((SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey, Phone,Phone2,
									 Email,Email2,Fax,Website
						FROM Address A WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER))
	FROM				ShippingPort S
	WHERE				ShippingPortKey = @ShippingPortKey
	ORDER BY			ShippingPortID
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
