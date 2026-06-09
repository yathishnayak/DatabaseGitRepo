




 
CREATE View [dbo].[VDriver]

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

L.displayname,

--, case when charindex('-',d.DriverID) > 0 then 

--      CONVERT(VARCHAR, CAST(LEFT(D.DriverID,charindex('-',d.DriverID)-1) AS INT))

--else 

--       D.DriverID

--end

'0' AS DriverID1,

D.PayTypeKey, PT.PayTypeName,

STUFF((SELECT distinct ', ' + CMT.MoveTypeName

         from CarrierMoveType CMT

		 INNER JOIN Driver_MoveType DM WITH (NOLOCK) ON DM.MoveTypeKey=CMT.MoveTypeKey AND IsSelected=1

         where D.DriverKey = DM.DriverKey

            FOR XML PATH(''), TYPE

            ).value('.', 'NVARCHAR(MAX)') 

        ,1,2,'') MoveTypes,

TruckTypeKey,MarketLocationKey

from Driver D  WITH (NOLOCK) 

inner join Address A WITH (NOLOCK)  on D.AddrKey = A.AddrKey

Left join DriverInfo I WITH (NOLOCK)  on D.DriverKey = I.DriverKey

Left join DriverInsuranceInfo II WITH (NOLOCK)  on D.DriverKey = II.DriverKey

LEft join DriverTruckInfo TI WITH (NOLOCK)  on D.DriverKey = TI.DriverKey

LEft join DriverLicenseInfo LI WITH (NOLOCK)  on D.DriverKey = LI.DriverKey

LEft join DriverLicences L WITH (NOLOCK)  on D.DriverKey = L.DriverKey

LEFT JOIN [Status] S WITH (NOLOCK)  ON S.StatusKey=D.StatusKey

LEFT JOIN Carrier_PayTypes PT WITH (NOLOCK) ON D.PayTypeKey = PT.PayTypeKey

WHERE --S.StatusName='ACTIVE'
ISNULL(D.IsActive,1)=1 AND ISNULL(D.IsDelete,0)=0 AND D.Statuskey=1

--ORDER BY DRIVERID1
order by DriverKey asc 

