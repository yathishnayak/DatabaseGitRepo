CREATE PROC [dbo].[GetUnProcessedAddress]
AS BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	SELECT top 500 AddrKey, Address1, Address2, City, [State], ZipCode, Country
	FROM [Address]
	WHERE IsValid = -1 AND ValidAddressKey IS NULL

END
