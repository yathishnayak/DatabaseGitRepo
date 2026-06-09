CREATE PROCEDURE [dbo].[CustomerCompany_GetList]

AS

BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SELECT CustomerCompanyKey,CompanyName,IsActive,IsDeleted 
		FROM CustomerCompany
		WHERE IsActive=1 AND IsDeleted=0
	FOR JSON PATH;
END


