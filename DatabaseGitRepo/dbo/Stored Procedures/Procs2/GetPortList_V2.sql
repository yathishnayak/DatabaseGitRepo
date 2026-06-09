/*
DECLARE @UserKey INT = 953, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{"MarketLocationKey":3}'
 
EXEC [GetPortList_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[GetPortList_V2] 
(
	@UserKey		INT = 953,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0

)
AS
BEGIN

	SET NOCOUNT ON;
	SET FMTONLY OFF

	--DECLARE @JsonOutPut NVARCHAR(MAX)


	
	DECLARE  @MarketLocationKey INT,@JsonOutPut NVARCHAR(MAX);
	SELECT @MarketLocationKey = MarketLocationKey
	from OPENJSON(@JSONString, '$')
	with (
			MarketLocationKey int '$.MarketLocationKey'
		 )
	SET @JsonOutPut=(SELECT		top 1185		ShippingPortKey,ShippingPortID,S.MarketLocationKey,S.IsActive,S.IsDeleted,StatusKey,MarketLocation,
						[Address] =  JSON_QUERY( (
        SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
        FROM Address A WITH (NOLOCK) 
        WHERE S.AddrKey = A.AddrKey
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
    ))
	FROM				ShippingPort S WITH (NOLOCK)
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=S.MarketLocationKey
	WHERE (@MarketLocationKey=0 OR CASE WHEN @MarketLocationKey=0 THEN 0 ELSE ISNULL(S.MarketLocationKey,0) END = @MarketLocationKey)
	AND ISNULL(S.IsDeleted,0)=0
	ORDER BY			ShippingPortID
						FOR JSON PATH)
						
	SELECT REPLACE(REPLACE(@JsonOutPut,'\n',''),'\t','') JsonOutPut
    
END