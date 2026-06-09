
CREATE Procedure [dbo].[GetYardByKey]  --[GetYardByKey] 1
(
	@YardId			SMALLINT
)
AS

BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT				YardId,ShortName,[Name],MarketLocationKey,IsActive,IsDeleted,y.AddrKey,
						[Address] = (SELECT AddrName,Address1,Address2,City,State,ZipCode AS Zip,Country, AddrKey, Phone,Phone2,
									 Email,Email2,Fax,Website
						FROM Address A WHERE (Y.AddrKey=A.AddrKey)
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM				Yard Y
	WHERE (YardId=@YardId)
	ORDER BY			[Name]
						FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

END
