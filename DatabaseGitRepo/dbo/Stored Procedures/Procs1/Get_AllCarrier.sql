CREATE PROCEDURE [dbo].[Get_AllCarrier]
/*
Order Screen
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT c.CarrierKey, c.CarrierID, c.CarrierName, c.IsSteamLine, c.AddrKey
		, c.ScacCode, c.LicensePlate
		,c.LicensePlateExpiryDate, c.CreateDate, c.StatusKey
	FROM dbo.Carrier C			WITH (NOLOCK)
		INNER JOIN [Status] S	WITH (NOLOCK) ON S.StatusKey=C.StatusKey
	WHERE c.CarrierKey = CarrierKey AND S.StatusName = 'Active'
	ORDER BY CarrierName
END
