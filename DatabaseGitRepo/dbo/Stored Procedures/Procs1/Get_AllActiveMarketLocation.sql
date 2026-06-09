

CREATE PROCEDURE [dbo].[Get_AllActiveMarketLocation] -- [Get_AllMarketLocation] 
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
	WHERE       IsActive=1 AND IsDeleted=0
	ORDER BY	MarketLocation
	FOR JSON PATH
END
