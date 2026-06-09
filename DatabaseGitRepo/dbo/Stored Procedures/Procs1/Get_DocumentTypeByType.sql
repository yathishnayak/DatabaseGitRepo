
CREATE PROCEDURE [dbo].[Get_DocumentTypeByType]
@type varchar(20)='Order'
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DocumentTypeKey,[Description] 
	FROM dbo.DocumenType 
	WHERE [LinkTo] = @type

END
