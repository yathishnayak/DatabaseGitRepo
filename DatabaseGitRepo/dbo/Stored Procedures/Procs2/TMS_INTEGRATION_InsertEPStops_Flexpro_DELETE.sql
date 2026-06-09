
CREATE PROC [dbo].[TMS_INTEGRATION_InsertEPStops_Flexpro_DELETE]
AS

SELECT			CL.ContainerKey,SD.AddrName,
				SD.address1, SD.Address2, SD.City, SD.State, SD.Country, SD.ZipCode, CL.equipmentNumber, CL.equipmentTypeCode 
INTO			#TMP
FROM			TKT_RouteDataNew RTN WITH (NOLOCK)
INNER JOIN		Integration_JCB.DBO.Flexpro_Header FH WITH (NOLOCK) ON RTN.OrderKey = FH.TMS_OrderKey
INNER JOIN		Integration_JCB.DBO.Flexpro_ContainerList CL WITH (NOLOCK) ON  FH.DATAKEY = CL.DataKey
INNER JOIN		routes RT WITH (NOLOCK) on rtn.RouteKey = RT.RouteKey
INNER JOIN		Address SD WITH (NOLOCK) on RT.SourceAddrKey = SD.AddrKey
LEFT JOIN		Integration_JCB.DBO.Flexpro_StopList SL WITH (NOLOCK) ON CL.ContainerKey = SL.ContainerKey AND RTN.LocationType = SL.facilityCode
WHERE			rtn.LocationType = 'EP' and sl.stopkey is null -- and FH.DataKey = 13142  
				--and  convert(Datetime, FH.workOrderDate) > convert(Date, '2024-09-01') --  AND FH.TMS_OrderKey IN (123801)


SELECT			ContainerKey, ERStopKey,RTStopKey
				,CASE WHEN ERStopNo = 0 THEN 4 ELSE 5 END RT
INTO			#TMP1				
FROM			(SELECT			TM.*, ISNULL(SL.stopNumber,0) AS EPStopNo
								,SL.StopKey AS ERStopKey
								, ISNULL(Sl.stopNumber,0) AS ERStopNo
								,SL1.StopKey AS RTStopKey
								, ISNULL(SL1.stopNumber,0) AS RTStopNo
				FROM			#TMP TM 
				LEFT JOIN		(SELECT		*
								FROM		Integration_JCB.DBO.Flexpro_StopList WITH (NOLOCK)
								WHERE		facilityCode= 'ER' ) SL ON TM.ContainerKey = SL.ContainerKey
				LEFT JOIN		(SELECT		*
								FROM		Integration_JCB.DBO.Flexpro_StopList WITH (NOLOCK)
								WHERE facilityCode = 'RT' ) SL1 ON TM.ContainerKey = SL1.ContainerKey )A

 --SELECT		* FROM #TMP
 --SELECT		* FROM #TMP1


----------------------------INSERT EP RECORD-----------------------------
INSERT INTO		Integration_JCB.DBO.Flexpro_StopList (ContainerKey, stopType, stopName, stopNumber, facilityCode, stopReferenceNumber,
				address1, Address2, city, state, country, postalCode, equipmentNumber, equipmentTypeCode,IsScheduleSent)
SELECT			DISTINCT ContainerKey,'Return Pickup (EP)', AddrName, 3, 'EP', 3,
				address1,Address2, City,State, Country, ZipCode, equipmentNumber, equipmentTypeCode,1
FROM			#TMP


--------------------------UPDATE ER STOP NUMBER----------------------
--SELECT			B.ContainerKey, StopNumber,stopreferenceNumber, 4
UPDATE			A SET StopNumber = 4, stopreferenceNumber = 4
FROM			Integration_JCB.DBO.Flexpro_StopList  A WITH (NOLOCK)
INNER JOIN		#TMP1 B ON A.StopKey = B.ERStopKey
WHERE			facilityCode = 'ER'


--------------------------UPDATE RT STOP NUMBER----------------------
--SELECT			B.ContainerKey, StopNumber,stopreferenceNumber, RT
UPDATE			A SET StopNumber = RT, stopreferenceNumber = RT
FROM			Integration_JCB.DBO.Flexpro_StopList  A WITH (NOLOCK)
INNER JOIN		#TMP1 B ON A.StopKey = B.RTStopKey
WHERE			facilityCode = 'RT'


DROP TABLE		#TMP
DROP TABLE		#TMP1
