CREATE PROCEDURE [dbo].[Get_PickUpType]
/*
Dispatch Screen
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT PickupTypeKey, PickUpType
	FROM dbo.PickUpType
END
