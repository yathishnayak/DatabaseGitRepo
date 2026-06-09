
CREATE VIEW FilterOrdersTest -- SELECT * FROM FilterOrdersTest WHERE CreateDate > GETDATE() - 1

AS

WITH FilteredOrders AS (
    SELECT OD.OrderDetailKey, OD.ContainerNo, OD.OrderKey, OD.Status, OD.CurrentRouteKey, ContainerID, ContainerSizeKey, LastFreeDay, IsLinked,LinkedContainerNo
	,[Weight],SealNo,CutOffDate,IsEmpty,DriverNotes,SchedulerNotes,IsTMF,CurrentLegNo,TotalLegs
	,CompleteDate, isStreetTurn, StreetTurnSetDate, SourceAddrKey, DestinationAddrKey, CreateUserKey,CreateDate, StreetTurnSetUser, PUDelayedCodeKEy,PrepullDelayedCodeKEy
    FROM OrderDetail  OD  WITH (NOLOCK)
    WHERE OD.Status IN (1, 2, 3, 6, 7, 9, 12, 14)  -- AND OD.CreateDate > GETDATE() - 1
    
), FilterAddress AS(
SELECT AddrKey,AddrName,Address1,City,State, ZipCode,Country FROM ADDRESS WITH (NOLOCK)
), FiltervContainerType AS (

SELECT TypeID, OrderDetailKey, ContainerTypeKey FROM vContainerType  WITH (NOLOCK) WHERE TypeID IN ('Transload', 'Hazard')
), FilterRoutes AS (
SELECT RouteKey, SourceAddrKey, DestinationAddrKey,PickupDateFrom,DeliveryDateFrom , LegKey, ScheduledDeparture FROM Routes WITH (NOLOCK)
), FilterOrderHeader AS (

SELECT OH.OrderKey, OrderDate, OrderNo,BillOfLading, BrokerRefNo,BookingNo,CustKey, VesselName, OH.Status, BrokerKey,BillToAddrKey,ReturnAddrKey,OH.SourceAddrKey, OH.DestinationAddrKey
, CsrKey,OrderTypeKey, PriorityKey, CSRManagerKey,SalesPersonKey, MarketLocationKey,SteamShipLinekey, SenderInfo, Consignee
FROM OrderHeader OH WITH (NOLOCK)  INNER JOIN
FilteredOrders O ON OH.OrderKey  = O.OrderKey
),  FilterGnosis_VContainerTrackingToDisplay AS(
SELECT  OrderDetailKey, Remarks FROM TrackingData_Delete D WITH (NOLOCK)  
), FilterData AS (SELECT A.* FROM FilteredOrders A
LEFT OUTER JOIN FilterGnosis_VContainerTrackingToDisplay B On A.OrderDetailKey = B.OrderDetailKey ),
JoinTables AS (

SELECT
 isnull(OH.OrderKey,0) OrderKey,
 OD.CreateDate,
			isnull(OH.OrderDate,'1900-01-01') as OrderDate,
			isnull(OD.OrderDetailkey,0) as OrderDetailkey,
			isnull(OT.OrderTypeKey,0) as OrderTypeKey,
			isnull(OH.OrderNo,'') as OrderNo,
			isnull(OD.ContainerNo,'') as ContainerNo,
			isnull(OD.ContainerID, '') as ContainerID,
			isnull(OD.ContainerSizeKey,0) as ContainerSizeKey,
			--ISNULL(isnull(OD.LastFreeDay,Last_free_demurrage_day_dt),'') as LastFreeDay,
			convert(Datetime,ISNULL(isnull(OD.LastFreeDay,Last_free_demurrage_day_dt ),'1900-01-01')) as LastFreeDay,
			RT.PickupDateFrom AS PickupDate ,
			CONVERT(VARCHAR(10), CAST(RT.PickupDateFrom AS TIME), 0) PickupTime,		
			RT.DeliveryDateFrom AS DropOffDate,
			CONVERT(VARCHAR(10), CAST(RT.DeliveryDateFrom AS TIME), 0) DropOffTime,	
			isnull(OSD.[Description],'') AS [Status],
			Case   when OD.Status = 6 then 12
				when OD.Status =14 then 12 else OD.Status  end as StatusKey,
			isnull(OT.OrderType,'') AS OrderType,
			isnull(OH.BillOfLading,'') AS BillOfLading,
			isnull(OH.BookingNo,'') AS BookingNo,
			isnull(OH.BrokerRefNo,'') as BrokerRefNo,
			isnull(CS.[Description],'') AS ContainerSize,
			isnull(PT.[Description],'')  AS [Priority],
			isnull(CSR.AddrName,SR.AddrName) AS S_AddrName,
			isnull(CSR.Address1,SR.Address1) AS S_Address1,
			isnull(CSR.City,SR.City)  AS S_City,
			isnull(CSR.[State],SR.[State])  AS S_State,
			isnull(CSR.ZipCode,SR.ZipCode)  AS S_ZipCode,
			isnull(CSR.Country,SR.Country)  AS S_Country,
			isnull(CDT.AddrName,DT.AddrName)  AS D_AddrName,
			isnull(CDT.Address1,DT.Address1)  AS D_Address1,
			isnull(CDT.City,DT.City)  AS D_City,
			isnull(CDT.[State],DT.[State])  AS D_State,
			isnull(CDT.ZipCode,DT.ZipCode)  AS D_ZipCode,
			isnull(CDT.Country,DT.Country)  AS D_Country,
			isnull(CSR.AddrName,SR.AddrName) AS Source_AddrName,
			isnull(CSR.Address1,SR.Address1) AS Source_Address1,
			isnull(CSR.City,SR.City)  AS Source_City,
			isnull(CSR.[State],SR.[State])  AS Source_State,
			isnull(CSR.ZipCode,SR.ZipCode)  AS Source_ZipCode,
			isnull(CSR.Country,SR.Country)  AS Source_Country,
			isnull(CDT.AddrName,DT.AddrName)  AS Destination_AddrName,
			isnull(CDT.Address1,DT.Address1)  AS Destination_Address1,
			isnull(CDT.City,DT.City)  AS Destination_City,
			isnull(CDT.[State],DT.[State])  AS Destination_State,
			isnull(CDT.ZipCode,DT.ZipCode)  AS Destination_ZipCode,
			isnull(CDT.Country,DT.Country)  AS Destination_Country,
			isnull(BT.AddrName,'')  AS B_AddrName,
			isnull(BT.Address1,'')  AS B_Address1,
			isnull(BT.City,'')  AS B_City,
			isnull(BT.[State],'')  AS B_State,
			isnull(BT.ZipCode,'')  AS B_ZipCode,
			isnull(BT.Country,'')  AS B_Country,
			isnull(RET.AddrName,'') AS R_AddrName,
			isnull(RET.Address1,'') AS R_Address1,
			isnull(RET.City,'') AS R_City,
			isnull(RET.[State],'') AS R_State,
			isnull(RET.ZipCode,'') AS R_ZipCode,
			isnull(RET.Country,'') AS R_Country,	
			--ISNULL(isnull(OD.VesselETA,Gnosis_vessel_eta_dt),'') AS VesselETA,
			CAST(ISNULL(isnull(GICF.Vessel_eta_dt,Gnosis_vessel_eta_dt),'')AS DATETIME) AS VesselETA,
			isnull(OD.IsLinked,0) AS IsLinked,
			isnull(OD.LinkedContainerNo,'') AS LinkedContainerNo,
			CASE 
				WHEN OD.status = 1 THEN 'Proceed to Schedule' 
				WHEN OD.status = 3 THEN 'Complete Schedule'          
				WHEN OD.status = 4 THEN 'Confirm/Complete Schedule' 
				WHEN OD.status = 5 THEN 'Process Dispatch' 
				WHEN OD.status = 7 THEN 'Complete Dispatch'   
				WHEN OD.status = 8 THEN 'Confirm/Complete Dispatch'  
				WHEN OD.status = 9 THEN 'Approve Invoice/Driver Pay'  
				WHEN OD.status = 10 THEN 'Closed' 
				WHEN OD.status = 6 THEN 'Approve for Invoice/Driver Pay' 
				WHEN OD.status = 2 THEN 'Proceed to Dispatch'
				END AS NextAction,
			OH.custKey,BR.BrokerName,OD.[Weight],OH.VesselName,OD.SealNo,OD.CutOffDate 
			, isnull(OD.IsEmpty,0) as IsEmpty
			, OD.DriverNotes , OD.SchedulerNotes
			, isnull(OD.IsTMF,0) as IsTMF
			, case when ISNULL(Ct.ContainerTypeKey,0) = 0 then 0 else 1 end  as isTransLoad 
			, isnull(CU.CustName,'''') as  CustName,
			isnull(CU.CustID,'''') as CustID,
			ISNULL(UU.UserName,'''') AS CreatedUser,
			CAST(ISNULL(od.CurrentLegNo,0) AS VARCHAR(10))+' [ ' + ISNULL(CAST(od.CurrentLegNo AS VARCHAR(10)),0)+ ' of '+ CAST(od.TotalLegs AS VARCHAR(10))+' ]' AS CurLeg,
			l.FromLocation  AS LocationType ,
			RA.AddrName AS CurLocation, RT.RouteKey, RP.AddrName, 
			case when ISNULL(Hz.ContainerTypeKey,0) = 0 then 0 else 1 end AS IsHazardous,
			isnull(CDC.DocumentCount,0) as DocumentCount,
			B.LastFreeDay as  Int_LFD, convert(bit, case when isnull(B.OrderDetailKey,0) = 0 then 0 else 1 end) as IntDataExists ,
			od.CompleteDate as TerminationDate,
			od.isStreetTurn,
			ISNULL(u2.UserName,'') AS StreetTurnSetUser,
			OD.StreetTurnSetDate,
			CR.CsrKey,
			CM.CsrKey AS CSManagerKey,
			SP.LinkedUserKey as SalePersonKey,
			isnull(CR.CsrName,'') as CsrName,
			isnull(CM.CsrName,'') as CSManagerName,
			isnull(OH.CSRManagerKey ,CM.CsrKey) as CSRManagerKey,
			isnull(SP.SalesPersonName,'') as SalesPersonName,
			CR.LinkedUserKey AS CSRUser, CM.LinkedUserKey AS CMUser, SP.LinkedUserKey AS SPUser, 
			ISNULL(ML.MarketLocationKey,0) MarketLocationKey
			, ISNULL(ML.MarketLocation,'') MarketLocation
			, OH.Consignee, SL.LineName AS SteamShipLine, OH.SenderInfo,
			GICF.Ocean_carrier_scac AS SCAC, GICF.Discharged_dt AS Dischargedate, 
			GICF.HoldStatus,'' LiveDrop,
			--PDC.Code AS DelayReasonCode,
			Stuff((SELECT ', ' + PUD.Code
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPURC
			 INNER JOIN PUScheduleDelayCode PUD WITH (NOLOCK) ON (PUD.CodeKey=ODPURC.PUScheduleRCKey)
			   WHERE OD.OrderDetailKey = ODPURC.OrderDetailKey 
			 FOR XML PATH('')),1,1,'') AS DelayReasonCode,
			OD.PUDelayedCodeKey,
			GICF.Available_for_pickup AS AvailableforPickup,
			GICF.Available_dt AS AvailableforPickupDate,
			CAST(0 AS BIT) IsEditDelayReasonCode,
			OD.PrepullDelayedCodeKEy,
			--PPDC.Code AS PrepullDelayedCode,
			Stuff((SELECT ', ' + PPR.Code
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPPRC
			 INNER JOIN PrePullReasonCodes PPR  WITH (NOLOCK) ON (PPR.CodeKey=ODPPRC.PrepullRCKey)
			   WHERE OD.OrderDetailKey = ODPPRC.OrderDetailKey 
			 FOR XML PATH('')),1,1,'') AS PrepullDelayedCode,
			CAST(0 AS BIT) IsEditPrepullReasonCode,
			
			Location_at_terminal,
			CASE WHEN ISNULL(GICF.OrderDetailKey,0)=0 THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END AS [Tracking],
			GICF.Pod_terminal_name,
			--H.CTF, H.Customs, H.Line, H.Other, H.TMF,
			--HoldType= (case when isnull(H.CTF,'') = 'true' then 'CTF;' else '' END )+
			--		(case when isnull(H.TMF,'') = 'true' then 'TMF;' else '' END )+
			--		(case when isnull(H.Customs,'') = 'true' then 'Customs;' else '' END )+
			--		(case when isnull(H.Line,'') = 'true' then 'Line;' else '' END )+
			--		(case when isnull(H.Other,'') = 'true' then 'Other;' else '' END )
			--		,
			CU.CustName as Customer,
			CR.CsrName as OrderCSR,
			OH.SalesPersonKey,
			Isnull(GICF.Pickup_appointment_dt,RT.ScheduledDeparture) as Pickup_appointment_dt,
			ISNULL(ISNULL(CR.LinkedUserKey, CM.LinkedUserKey),   SP.LinkedUserKey) as LinkedUserKey,
			ISNULL(CDT.AddrKey,DT.AddrKey) as DeliveryLocationKey
			,-- ISNULL(GVTD.Remarks,'N/A') As NoTrackingRemarks,
			PrepullRCKeys=(Stuff((SELECT ', ' + CAST(ODPPRC.PrepullRCKey AS VARCHAR)
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPPRC WITH (NOLOCK)
			   WHERE OD.OrderDetailKey = ODPPRC.OrderDetailKey 
			 FOR XML PATH('')),1,2,'')),

			 Stuff((SELECT ', ' + CAST(ODPURC.PUScheduleRCKey AS VARCHAR)
			 FROM OrderDetail_Prepull_PUDelayed_RCKeys ODPURC  WITH (NOLOCK)
			   WHERE OD.OrderDetailKey = ODPURC.OrderDetailKey 
			 FOR XML PATH('')),1,2,'') AS PUDealyedRCKeys,
			 convert(bit, 0) as IsDataSelected,
			 convert(bit,0) as IsSelectedStatusKey,
			 ROW_Number() Over(order by OD.OrderDetailKey) as ID
	
FROM  FilterData OD  
INNER JOIN	FilterOrderHeader OH  ON OH.OrderKey = OD.OrderKey
INNER JOIN	dbo.OrderStatus OS WITH (NOLOCK) ON OS.[Status] = OH.[Status]
LEFT JOIN	dbo.Broker BR WITH (NOLOCK) ON BR.BrokerKey = OH.BrokerKey
INNER JOIN	dbo.OrderDetailStatus OSD WITH (NOLOCK) ON OSD.[Status] = OD.[Status]
INNER JOIN	dbo.ContainerSize CS WITH (NOLOCK) ON CS.ContainerSizeKey = OD.ContainerSizeKey
LEFT JOIN	DBO.Customer CU				WITH (NOLOCK)	ON OH.CustKey = CU.CustKey
LEFT JOIN	dbo.CSR CR					WITH (NOLOCK)	ON CR.CsrKey= ISNULL(OH.CsrKey, CU.CSRKey)
LEFT JOIN	dbo.OrderType OT				WITH (NOLOCK)	ON OT.OrderTypeKey = OH.OrdertypeKey 
LEft join	FilterRoutes RT								on OD.CurrentRouteKey = Rt.RouteKey
LEFT JOIN	FilterAddress SR			 					ON	SR.AddrKey=isnull(OD.SourceAddrKey, OH.SourceAddrKey)
LEFT JOIN	FilterAddress DT				 				ON	DT.AddrKey=isnull(OD.DestinationAddrKey, OH.DestinationAddrKey)
LEFT JOIN	FilterAddress BT				 				ON	BT.AddrKey=OH.BillToAddrKey
LEFT JOIN	FilterAddress RET				 				ON	RET.AddrKey=OH.ReturnAddrKey
LEFT JOIN	FilterAddress CSR				 				ON  RT.SourceAddrKey = CSR.AddrKey
LEFT JOIN	FilterAddress CDT				 				ON  RT.DestinationAddrKey = CDT.AddrKey
LEFT JOIN	dbo.[Priority] PT			WITH (NOLOCK)	ON PT.PriorityKey=OH.PriorityKey
LEFT Join	DBO.[User] UU				WITH (NOLOCK)	ON OD.CreateUserKey = uu.UserKey
LEft join	FiltervContainerType CT						on CT.OrderDetailKey = OD.OrderDetailKey  
LEft join	FilterAddress RA								on RT.DestinationAddrKey = RA.AddrKey
LEFT join	Leg L						WITH (NOLOCK)	ON RT.LegKey = l.LegKey
LEFT JOIN	FilterAddress RP								ON RT.SourceAddrKey = RP.AddrKey
LEFT JOIN	FiltervContainerType HZ						ON HZ.OrderDetailKey = OD.OrderDetailKey  
LEFT JOIN	ContainerDocumentCount CDC	WITH (NOLOCK)	ON OD.OrderDetailKey = CDC.OrderDetailKey
LEft join	Int_ContainerAvailability B	with (NOLOCK)	on OD.OrderDetailkey  = B.OrderDetailKey
lEFT jOIN	[USER] u2					WITH (NOLOCK)	ON OD.StreetTurnSetUser = U2.UserKey
LEft Join	CSR CM						WITH (NOLOCK)	ON CM.CsrKey = isnull(ISNULL(OH.CSRManagerKey,CU.CSRManagerKey),CR.CsrKey)
LEFT JOIN	SalesPerson SP				WITH (NOLOCK)	ON SP.SalesPersonKey =  ISNULL( OH.SalesPersonKey, CU.SalesPersonKey)
LEFT JOIN	MarketLocation ML				WITH (NOLOCK)	ON OH.MarketLocationKey =  ML.MarketLocationKey
LEFT JOIN	SteamShipLine SL				WITH(NOLOCK)	ON SL.LineKey = OH.SteamShipLinekey
LEFT JOIN	Gnosis_Integration_Container_Final GICF WITH (NOLOCK) ON GICF.OrderDetailKey=OD.OrderDetailKey
LEFT JOIN	PUScheduleDelayCode PDC		WITH (NOLOCK) ON PDC.CodeKey=PUDelayedCodeKEy
LEFT JOIN	PrePullReasonCodes PPDC	WITH (NOLOCK) ON PPDC.CodeKey=PrepullDelayedCodeKEy
LEFT JOIN	VGnosis_MarketLocation MLT   On GICF.Final_dest_city = MLT.Final_dest_city
-- LEFT JOIN	FilterGnosis_VContainerTrackingToDisplay GVTD WITH (NOLOCK) ON (GVTD.OrderDetailKey=OD.OrderDetailKey)
) 

SELECT * FROM JoinTables






