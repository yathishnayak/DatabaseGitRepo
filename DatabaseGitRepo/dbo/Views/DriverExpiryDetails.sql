

CREATE view [dbo].[DriverExpiryDetails]
as
select D.DriverKey, D.DriverID, D.FirstName, D.LastName, D.OrgName, 
	DT.DriverTypeName, 
	isnull(D.DrivingLicenseExpiryDate,getdate()-100) as DrivingLicenseExpiryDate,
	isnull(I.DriverMedicalCardExpDate,getdate()-100) as DriverMedicalCardExpDate, 
	isnull(I.CoLiabInsuEndDate,getdate() - 100)  as CoLiabInsuEndDate, 
	isnull(I.CoOccuInsuEndDate, getdate()-100) as CoOccuInsuEndDate, 
	isnull(I.DriverLiabInsuranceExpDate,getdate()-100) as DriverLiabInsuranceExpDate,
	isnull(TI.CHPInspectionDate, getdate()-100) as CHPInspectionDate, 
	isnull(TI.SmokeCheckDate, getdate()-100) as SmokeCheckDate, 
	isnull(TI.TruckInspectionDate, getdate()-100) as TruckInspectionDate,
	isnull(dateadd(D, 365, T.InspectionDate), getdate()-100) as InspectionDate, 
	isnull(L.TruckRegExpiryDate, getdate()-100) as TruckRegExpiryDate, 
	isnull(L.TwicExpiryDate, getdate()-100) as TwicExpiryDate,
	isnull(DATEADD(d,365,S.ScreenDate),getdate()-100)  as ScreenDate,
	isnull(L.ApportionedPlateExpiry, getdate()-100) as ApportionedPlateExpiry, 
	isnull(L.LeaseDateExpiry, getdate()-100) as LeaseDateExpiry, 
	isnull(L.PDTRLA, getdate()-100) as PDTRLA, 
	isnull(L.PDTRLB,getdate()-100) as PDTRLB, 
	D.StatusKey,
	90 as TruckValidityDays , 
	isnull(Dateadd(d, 90, TI.TruckInspectionDate),getdate()-100) as TruckExpiry, 
	365 as CHPValididyDays, 
	isnull(dateadd(d,365,TI.CHPInspectionDate), getdate()-100) as CHPExpiryDate,
	730 as SmokeCheckValididyDays, 
	isnull(DATEADD(d,730,TI.SmokeCheckDate), GetDate()-100) as SmokeCheckExpiry
from Driver D WITH (NOLOCK) 
Left join DriverInsuranceInfo I WITH (NOLOCK)  on D.DriverKey = I.DriverKey
Left join DriverTruckInspectionInfo T WITH (NOLOCK)  on D.DriverKey = T.DriverKey and dateadd(d,365,T.InspectionDate) > getdate() and T.IsPass = 1
Left join DriverScreeningInfo S WITH (NOLOCK)  on D.DriverKey = S.DriverKey and DATEADD(d,365,S.ScreenDate) > getdate() and S.IsPass = 1
Left join DriverTruckInfo TI WITH (NOLOCK)  on D.DriverKey = TI.DriverKey
Left join DriverLicenseInfo L WITH (NOLOCK)  on D.DriverKey = L.DriverKey
Left join DriverType DT WITH (NOLOCK)  on TI.DriverType = DT.DriverTypeKey
