CREATE PROCEDURE [dbo].[Get_DocumentType]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DocumentTypeKey,[Description] 
	FROM DocumenType 

END
