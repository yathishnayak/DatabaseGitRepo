CREATE PROCEDURE [dbo].[Get_TruckDetail]
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT TR.TruckKey,TR.TruckNo
	FROM dbo.Truck TR 
		INNER JOIN [Status] S ON S.Statuskey= TR.StatusKey 
	WHERE  S.StatusName='Active'
END
