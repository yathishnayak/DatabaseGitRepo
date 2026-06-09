
CREATE PROC [dbo].[TMS_INTEGRATION_InsertRTStops_CNB]
as
insert into		Integration_JCB.DBO.CNB_StopList (ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber,
				address1, Address2, city, state, country, postalCode, equipmentNumber, equipmentTypeCode)
SELECT			CL.ContainerKey,'Returned To', SD.AddrName, 3, 'RT', 3,
				SD.address1, SD.Address2, SD.City, SD.State, SD.Country, SD.ZipCode, CL.equipmentNumber, CL.equipmentTypeCode
FROM			TKT_RouteDataNew RTN WITH (NOLOCK)
INNER JOIN		Integration_JCB.DBO.CNB_Header FH WITH (NOLOCK) ON RTN.OrderKey = FH.TMS_OrderKey
INNER JOIN		Integration_JCB.DBO.CNB_ContainerList CL WITH (NOLOCK) ON  FH.DATAKEY = CL.DataKey
inner join		routes RT WITH (NOLOCK) on rtn.RouteKey = RT.RouteKey
inner join		Address SD WITH (NOLOCK) on RT.DestinationAddrKey = SD.AddrKey
LEFT JOIN		Integration_JCB.DBO.CNB_StopList SL WITH (NOLOCK) ON CL.ContainerKey = SL.ContainerKey AND RTN.LocationType = SL.facilityCode
WHERE			rtn.LocationType = 'RT' and sl.stopkey is null -- and FH.DataKey = 13142  
				and  convert(Datetime, FH.workOrderDate) > convert(Date, '2024-01-01')
