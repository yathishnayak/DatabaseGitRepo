
CREATE PROCEDURE [dbo].[Get_MarketLocation_ByKey] -- [Get_MarketLocation_ByKey]  14
(
	@MarketLocationKey INT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT		MarketLocationKey,MarketLocation,ML.AddrKey,IsActive,IsDeleted,
				[Address]= (SELECT AddrKey, AddrName,ISNULL(Address1,'') Address1,ISNULL(Address2,'') Address2,
				ISNULL(City,'') City,ISNULL(ZipCode,'') AS Zip,ISNULL(State,'') AS State,ISNULL(Country,'') Country,
				ISNULL(Email,'') Email,ISNULL(Email2,'')Email2,ISNULL(Phone,'')Phone,ISNULL(Phone2,'')Phone2,ISNULL(Fax,'')Fax
				FROM Address A
				WHERE A.AddrKey=ML.AddrKey
				FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)
	FROM		MarketLocation ML
	WHERE		MarketLocationKey = @MarketLocationKey 
	ORDER BY	MarketLocation
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
