CREATE PROCEDURE [dbo].[Get_AppConfigAll]
AS
BEGIN
	SELECT ConfigName,ConfigValue1 , ConfigId, CompanyKey, ConfigValue1, ConfigValue2, ConfigValue3
		FROM AppConfig 
	order by ConfigName
END