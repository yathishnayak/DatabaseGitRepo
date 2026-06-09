CREATE PROCEDURE [dbo].[Get_LocationByCity]
@City VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SELECT DISTINCT CityKey,Country,[State],City, ZipCode
	FROM dbo.LocationData A 
		INNER JOIN dbo.[Status] S ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND A.City LIKE '%' +LTRIM(RTRIM(@City)) +'%';
END
