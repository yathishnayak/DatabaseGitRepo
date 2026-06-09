

CREATE View [dbo].[VDriverAll]
as
select TOP 100000 D.DriverKey, D.DriverID, FirstName, LastName, a.AddrKey, CarrierKey, 
DrivingLicenseNo, DrivingLicenseExpiryDate,
D.CreateDate, d.StatusKey, StatusDate, VendKey, D.CompanyKey, HireDate, Plate, YearMake, 
VINId, RFID, ContactNo, OrgName, OrgZipCode, 
FuelCardNo, OrgCity, OrgState, OrgCountry, 
A.AddrName, A.Address1, A.Address2, A.City, A.State, A.Country, A.ZipCode,
I.SSNNo, I.BirthDate, I.DateLeftCompany, I.Notes, I.EmmContactName, I.EmmContactPhone,
II.DriverLiabInsuranceNo, II.DriverMedicalCardNo,
TI.DriverType, TI.TruckOwnerFirstName, TI.TruckOwnerLastName, TI.TruckOwnerPhoneNo, TI.EIN,
LI.TractorLicenseNo, LI.TwicExpiryDate, LI.TruckRegExpiryDate, LI.ApportionedPlateExpiry, 
LI.GPSSerialNo, LI.LeaseDateExpiry, LI.PDTRLB, LI.PDTRLA, LI.DMVPNDateAdd, LI.DMVPNDateDelete,
L.displayname, ISNULL(D.DriverHubKey,1) AS DriverHubKey, DH.DriverHubName,
--, case when charindex('-',d.DriverID) > 0 and isnumeric(left(d.DriverID,2))=1 then 
--      CONVERT(VARCHAR, CAST(LEFT(D.DriverID,charindex('-',d.DriverID)-1) AS INT))
--else 
--       '99999'
--end 
'0' AS DriverID1,
D.PayTypeKey, PT.PayTypeName
from Driver D WITH (NOLOCK) 
inner join Address A WITH (NOLOCK)  on D.AddrKey = A.AddrKey
Left join DriverInfo I WITH (NOLOCK)  on D.DriverKey = I.DriverKey
Left join DriverInsuranceInfo II WITH (NOLOCK)  on D.DriverKey = II.DriverKey
LEft join DriverTruckInfo TI WITH (NOLOCK)  on D.DriverKey = TI.DriverKey
LEft join DriverLicenseInfo LI WITH (NOLOCK)  on D.DriverKey = LI.DriverKey
LEft join DriverLicences L WITH (NOLOCK)  on D.DriverKey = L.DriverKey
LEFT JOIN [Status] S WITH (NOLOCK)  ON S.StatusKey=D.StatusKey
LEFT JOIN DriverHUB DH ON (D.DriverHubKey=DH.DriverHubKey)
LEFT JOIN Carrier_PayTypes PT WITH (NOLOCK) ON D.PayTypeKey = PT.PayTypeKey
ORDER BY DRIVERID1 
