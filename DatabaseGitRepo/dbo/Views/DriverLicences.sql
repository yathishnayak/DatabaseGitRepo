


CREATE view [dbo].[DriverLicences]
as
SELECT a.DriverKey, a.DriverID, displayname = 
STUFF((SELECT DISTINCT ', ' + LT.LicenseTypeName
        FROM driver D WITH (NOLOCK) 
		LEft join DriverLicenseTypes DLT WITH (NOLOCK)  on D.DriverKey = DLT.DriverKey
		LEft join LicenseTypes LT WITH (NOLOCK)  on DLT.LicenseType = LT.LicenseTypeKey
        WHERE D.DriverKey = a.DriverKey and DLT.IsSelected = 1
        FOR XML PATH('')), 1, 2, '')
FROM driver a  WITH (NOLOCK) 
GROUP BY DriverKey, DriverID
