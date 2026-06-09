
CREATE PROCEDURE [dbo].[Get_Location]
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT Country,[State],City, ZipCode,CityKey
	FROM dbo.LocationData A 
		INNER JOIN dbo.[Status] S ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND A.IsActive= 1;
END
