CREATE PROCEDURE [dbo].[Insert_Company]
/*
dbo.fn_insert_company
*/
@CompID			VARCHAR(20),
@CompName		VARCHAR(255),
@AddrKey		INT	,
@CompKey		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO dbo.Company(CompanyID, CompanyName, AddrKey)
	VALUES (@CompID,@CompName,@AddrKey);

	SET @CompKey=0;
	SET @CompKey = ( SELECT SCOPE_IDENTITY());		
END
