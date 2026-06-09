
CREATE PROCEDURE [dbo].[Get_ItemType]
/*
 dbo.fn_getitemtypes
*/
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT I.ItemTypeKey,I.ItemType,I.Description AS ItemTypeDescription,CreateDate
	 FROM dbo.ItemType I;
END
