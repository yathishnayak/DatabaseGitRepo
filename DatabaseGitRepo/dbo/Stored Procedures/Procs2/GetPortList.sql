CREATE PROCEDURE [dbo].[GetPortList]  --GetPortList 
@MarketLocationKey	INT=0
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	DECLARE @JsonOutPut NVARCHAR(MAX)
	SET @JsonOutPut=(SELECT		top 1185		ShippingPortKey,ShippingPortID,S.MarketLocationKey,S.IsActive,S.IsDeleted,StatusKey,MarketLocation,
						[Address] = (SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey
						FROM Address A WHERE (S.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				ShippingPort S
	LEFT JOIN MarketLocation ML WITH (NOLOCK) ON ML.MarketLocationKey=S.MarketLocationKey
	WHERE (@MarketLocationKey=0 OR CASE WHEN @marketLocationKey=0 THEN 0 ELSE ISNULL(S.MarketLocationKey,0) END = @marketLocationKey)
	AND ISNULL(S.IsDeleted,0)=0
	ORDER BY			ShippingPortID
						FOR JSON PATH)
						
	SELECT REPLACE(REPLACE(@JsonOutPut,'\n',''),'\t','') JsonOutPut

END