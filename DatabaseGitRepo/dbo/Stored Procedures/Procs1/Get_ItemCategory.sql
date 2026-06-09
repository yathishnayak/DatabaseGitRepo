
CREATE PROCEDURE [dbo].[Get_ItemCategory]
AS
BEGIN
	SELECT CategoryKey,[Name] CategoryName FROM ItemCategory
	FOR JSON PATH
END
