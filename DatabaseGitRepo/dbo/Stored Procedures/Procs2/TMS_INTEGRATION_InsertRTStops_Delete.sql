
CREATE PROC [dbo].[TMS_INTEGRATION_InsertRTStops_Delete]
AS



SELECT			CL.ContainerKey, SD.AddrName,
				SD.address1, SD.Address2, SD.City, SD.State, SD.Country, SD.ZipCode, CL.equipmentNumber, CL.equipmentTypeCode
INTO			#TMP
FROM			TKT_RouteDataNew RTN
INNER JOIN		Integration_JCB.DBO.Flexpro_Header FH ON RTN.OrderKey = FH.TMS_OrderKey
INNER JOIN		Integration_JCB.DBO.Flexpro_ContainerList CL ON  FH.DATAKEY = CL.DataKey
INNER JOIN		routes RT on rtn.RouteKey = RT.RouteKey
INNER JOIN		Address SD on RT.DestinationAddrKey = SD.AddrKey
LEFT JOIN		Integration_JCB.DBO.Flexpro_StopList SL ON CL.ContainerKey = SL.ContainerKey AND RTN.LocationType = SL.facilityCode
WHERE			rtn.LocationType = 'RT' and CL.ContainerKey = 47386 
				-- and sl.stopkey is null 
				-- and  CONVERT(DATETIME, FH.workOrderDate) > CONVERT(DATE, '2024-01-01')

SELECT * FROM #TMP

SELECT			T.ContainerKey,CASE WHEN ISNULL(SL.stopNumber,0) = 0 AND ISNULL(SL1.stopNumber,0) = 0   THEN 3 
				WHEN ISNULL(SL.stopNumber,0) > 0 AND ISNULL(SL1.stopNumber,0) = 0   THEN 4
				WHEN ISNULL(SL.stopNumber,0) = 0 AND ISNULL(SL1.stopNumber,0) > 0   THEN 4
				ELSE 5 END RT
INTO			#TMP1
FROM			#TMP T
LEFT JOIN		(SELECT		*
				FROM		Integration_JCB.DBO.Flexpro_StopList WHERE facilityCode = 'EP') SL ON T.ContainerKey = SL.ContainerKey
LEFT JOIN		(SELECT		*
				FROM		Integration_JCB.DBO.Flexpro_StopList WHERE facilityCode = 'RT') SL1 ON T.ContainerKey = SL1.ContainerKey	



--INSERT INTO		Integration_JCB.DBO.Flexpro_StopList (ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber,
--				address1, Address2, city, state, country, postalCode, equipmentNumber, equipmentTypeCode)
SELECT			T.ContainerKey,'Returned To', AddrName, RT, 'RT', RT
				, T.address1,T.Address2, T.City,T.State, T.Country, ZipCode, T.equipmentNumber, T.equipmentTypeCode 
FROM			#TMP T
LEFT JOIN		#TMP1 T1 ON T.ContainerKey = T1.ContainerKey				

DROP TABLE #TMP