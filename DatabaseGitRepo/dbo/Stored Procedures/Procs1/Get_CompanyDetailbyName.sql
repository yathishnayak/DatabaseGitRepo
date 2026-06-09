
CREATE PROCEDURE [dbo].[Get_CompanyDetailbyName]
@CompanyName  VARCHAR(50)=''
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT CompanyKey, CompanyID,CompanyName, AddrKey
	FROM dbo.Company 
	WHERE CompanyName like '%'+@CompanyName+'%'
END
