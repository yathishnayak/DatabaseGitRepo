CREATE PROCEDURE [dbo].[Get_Address]
@Addrkey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT	A.Addrkey,A.AddrName,A.Address1, A.Address2, A.City,
			A.[State],A.ZipCode,A.Country,A.Website,
			A.Phone,A.Phone2,A.Email,A.Email2,A.Fax 
	FROM dbo.[Address] A	
	WHERE A.Addrkey = @Addrkey
END
