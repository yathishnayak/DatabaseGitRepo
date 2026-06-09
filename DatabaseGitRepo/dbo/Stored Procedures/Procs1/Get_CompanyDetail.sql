CREATE PROCEDURE [dbo].[Get_CompanyDetail]
/*
dbo.fn_getcompanydetailbykey
*/
@CompanyKey INT=0
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT c.CompanyKey, c.CompanyID, c.CompanyName, c.AddrKey
	FROM dbo.Company c 
	WHERE c.CompanyKey = @CompanyKey
END
