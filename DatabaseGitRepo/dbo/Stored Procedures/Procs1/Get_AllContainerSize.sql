CREATE PROCEDURE [dbo].[Get_AllContainerSize]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT ContainerSizeKey, [Description]
	FROM dbo.ContainerSize;
END
