
CREATE Proc [dbo].[TMS_Integration_ReverseMapping_Century_Delete] -- TMS_Integration_ReverseMapping_Century_Delete 1195
(
	@DataKey		INT
)
as

Begin

	Declare @CustKey INT = 3402

	Declare @SiteID varchar(20) = 'Century'

	EXEC		TMS_INTEGRATION_InsertCBStops_Century
	EXEC		TMS_INTEGRATION_InsertCEStops_Century
	EXEC		TMS_INTEGRATION_InsertRTStops_Century
	EXEC		TMS_INTEGRATION_InsertSTStops_Century

	EXEC UPDATE_TKT_ROUTESDATANEW_ONReverseMapping @dataKey

	SELECT		*
	INTO		#TMP_Century_Header
	FROM		Integration_JCB.dbo.Century_Header
	WHERE		DataKey = @DataKey


	INSERT INTO	TKT_SyncData (TKT_DataKey, TKT_WorkOrderNumber,  TKT_ShipmentReferenceNumber, TKT_IsAccepted, 
				TKT_ContainerKey, TKT_EquipmentNumber, TMS_OrderKey, TMS_BrokerRefNo, TMS_OrderDetailKey, TMS_ContainerNo, 
				SiteID)
	SELECT		Kh.DataKey, Kh.workOrderNumber, KH.shipmentReferenceNumber, KH.isAccepted,
				CL.ContainerKey, CL.equipmentNumber, OH.OrderKey, OH.BrokerRefNo, OD.OrderDetailKey, OD.ContainerNo, @SiteId
	FROM		#TMP_Century_Header KH WITH (NOLOCK) 
	INNER JOIN	OrderHeader OH  WITH (NOLOCK) on KH.TMS_OrderKey = OH.orderkey
	INNER JOIN	Integration_JCB.dbo.Century_ContainerList CL  WITH (NOLOCK) on Kh.DataKey = CL.DataKey
	INNER JOIN	OrderDetail OD  WITH (NOLOCK) on OH.orderkey = OD.OrderKey
	LEFT JOIN	TKT_SyncData SD WITH (NOLOCK)  on KH.DataKey = SD.TKT_DataKey and KH.TMS_OrderKey = SD.TMS_OrderKey
	WHERE		SD.TMS_OrderKey is null


	PRINT '1'
	SELECT		IH.DataKey as TKT_DataKey, 
				IH.workOrderNumber as TKT_WorkOrderNumber, 
				IH.shipmentReferenceNumber as TKT_ShipmentReferenceNumber, 
				IH.isAccepted as TKT_IsAccepted, 
				IC.ContainerKey as TKT_ContainerKey, 
				IC.equipmentNumber as TKT_EquipmentNumber, 
				isnull(OH.ORderKey, OH2.OrderKey) as TMS_OrderKey, 
				Isnull(OH.BrokerRefNo, OH2.BrokerRefNo) As TMS_BrokerRefNo,
				OD.OrderDetailKey as TMS_OrderDetailKey, 
				OD.ContainerNo as TMS_ContainerNo,
				OH2.CustKey,
				@SiteId as SiteID
	INTO		#Temp_Century
	FROM		#TMP_Century_Header IH
	INNER JOIN	(Select datakey, ContainerKey, equipmentNumber from  Integration_JCB.dbo.Century_ContainerList WITH (NOLOCK) ) IC on IH.DataKey = IC.DataKey
	LEFT JOIN	OrderHeader OH  WITH (NOLOCK) on IH.TMS_OrderKey = OH.OrderKey
	LEFT JOIN	OrderHeader OH2  WITH (NOLOCK) on (OH2.BrokerRefNo = IH.shipmentReferenceNumber) OR ( OH2.BrokerRefNo like IH.shipmentReferenceNumber + '%')
	LEFT JOIN	(select OrderKey,OrderDetailKey, ContainerNo from  OrderDetail  WITH (NOLOCK) ) OD on OD.OrderKey = isnull(OH.OrderKey,OH2.OrderKey)
	WHERE		IC.equipmentNumber = OD.ContainerNo
				and IH.isAccepted =1 and OH.CustKey = @CustKey
	

	-- SELECT '1',* FROM #Temp_Century

	PRINT '2'
	UPDATE		SD 
	SET			TMS_OrderDetailKey = ND.TMS_OrderDetailKey,
				TMS_BrokerRefNo = ND.TMS_BrokerRefNo,
				TMS_ContainerNo = ND.TMS_ContainerNo,
				TMS_OrderKey = ND.TMS_OrderKey
	FROM		TKT_SyncData SD
	INNER JOIN	#Temp_Century ND on SD.TKT_DataKey = ND.TKT_DataKey and SD.SiteID = @SiteId
	WHERE		SD.TMS_OrderKey <> ND.TMS_OrderKey OR SD.TMS_OrderDetailKey <> ND.TMS_OrderDetailKey 
				and SD.SiteID = @SiteId
	
	-- SELECT '2',* FROM #Temp_Century

	PRINT '3'
	INSERT INTO	TKT_SyncData (TKT_DataKey, TKT_WorkOrderNumber, TKT_ShipmentReferenceNumber, TKT_IsAccepted, 
				TKT_ContainerKey, TKT_EquipmentNumber, TMS_OrderKey, TMS_BrokerRefNo, TMS_OrderDetailKey, 
				TMS_ContainerNo, SiteID)
	SELECT		ND.TKT_DataKey, ND.TKT_WorkOrderNumber, ND.TKT_ShipmentReferenceNumber, ND.TKT_IsAccepted, 
				ND.TKT_ContainerKey, ND.TKT_EquipmentNumber, ND.TMS_OrderKey, ND.TMS_BrokerRefNo, ND.TMS_OrderDetailKey, 
				ND.TMS_ContainerNo, ND.SiteID 
	FROM		#Temp_Century ND
	LEFT JOIN	TKT_SyncData SD  WITH (NOLOCK) on SD.TKT_DataKey = ND.TKT_DataKey and SD.SiteID = @SiteId
	WHERE		SD.TKT_DataKey is null and ND.SiteID = @SiteId

	PRINT '4'
	UPDATE		TH set TMS_OrderKey = Ts.TMS_OrderKey, DataType = 'Update'
	FROM		TMS_Integration_Header TH
	INNER JOIN	TKT_SyncData TS  WITH (NOLOCK) on TH.DataKey = TS.TKT_DataKey
	INNER JOIN	#Temp_Century ND  WITH (NOLOCK) ON TS.TKT_DataKey = ND.TKT_DataKey
	WHERE		TH.SiteID = TS.SiteID  and TS.TMS_OrderKey <> TH.TMS_OrderKey and TH.SiteID = @SiteId

	PRINT '5'
	INSERT INTO		TMS_Integration_Header(SiteID, DataKey, WorkOrdernumber,  TMS_OrderKey, DataType)
	SELECT DISTINCT	SD.Siteid, SD.TKT_DataKey, SD.TKT_WorkOrderNumber, SD.TMS_OrderKey, 'UPDATE'
	FROM			TKT_SyncData SD WITH (NOLOCK) 
	INNER JOIN		#Temp_Century ND  WITH (NOLOCK) ON SD.TKT_DataKey = ND.TKT_DataKey
	INNER JOIN		OrderHeader OH  WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey and OH.custkey = @CustKey
	LEFT JOIN		TMS_Integration_Header TH  WITH (NOLOCK) on SD.TKT_DataKey = TH.DataKey and SD.SiteID = TH.SiteID
	WHERE			TH.SiteID is null  and SD.SiteID = @SiteId

	PRINT '6'
	DELETE FROM	TMS_Integration_Container 
	WHERE		TMS_OrderDetailKey in 
				(SELECT DISTINCT	TMS_OrderDetailKey
				FROM				TMS_Integration_Container TC WITH (NOLOCK) 
				LEFT JOIN			OrderDetail OD  WITH (NOLOCK) on TC.TMS_OrderDetailKey = OD.OrderDetailKey
				WHERE				SiteID = @SiteID and OD.OrderDetailKey is null
				)
	
	--SELECT * FROM #Temp_Century

	INSERT INTO	TMS_Integration_Container ( SiteID, DataKey, ContainerKey, ContainerNo,TMS_OrderDetailKey)
	SELECT		SD.SiteID, SD.TKT_DataKey, SD.TKT_ContainerKey, SD.TMS_ContainerNo, SD.TMS_OrderDetailKey
	FROM		TKT_SyncData SD
	INNER JOIN	#Temp_Century ND ON SD.TKT_DataKey = ND.TKT_DataKey
	INNER JOIN	OrderDetail OD  WITH (NOLOCK) on SD.TMS_OrderDetailKey = OD.OrderDetailKey  and SD.SiteID =  @SiteId
	INNER JOIN	OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey and OH.custkey = @CustKey
	LEFT JOIN	TMS_Integration_Container TC  WITH (NOLOCK) on SD.TKT_ContainerKey = TC.ContainerKey and SD.SiteID = Tc.SiteID
	WHERE		TC.siteid is null and SD.SiteID = @SiteId

	
	PRINT '7'
	UPDATE		H 
	SET			TMS_OrderKey = A.TMS_OrderKey, TMS_CSRKey = OH.CsrKey, TMS_CarrierKey = OH.CarrierKey,
				TMS_DestinationAddrKey = OH.DestinationAddrKey, TMS_OrderDate = OH.OrderDate, 
				TMS_OrderNo = OH.OrderNo, TMS_OrderTypeKey = OH.OrderTypeKey, TMS_SourceAddrKey  = OH.SourceAddrKey
	FROM		Integration_JCB.dbo.Century_Header H
	INNER JOIN	TKT_SyncData A  WITH (NOLOCK) on A.TKT_DataKey = H.DataKey
	INNER JOIN	#Temp_Century ND  WITH (NOLOCK) ON A.TKT_DataKey = ND.TKT_DataKey
	INNER JOIN	OrderHeader OH  WITH (NOLOCK) on A.TMS_OrderKey = OH.OrderKey 
	WHERE		OH.custkey = @CustKey and isnull(H.TMS_OrderKey ,0) = 0 
				and A.SiteID = @SiteId

	PRINT '8'
	UPDATE		H 
	SET			TMS_OrderKey = A.TMS_OrderKey, TMS_CSRKey = OH.CsrKey, TMS_CarrierKey = OH.CarrierKey,
				TMS_DestinationAddrKey = OH.DestinationAddrKey, TMS_OrderDate = OH.OrderDate, 
				TMS_OrderNo = OH.OrderNo, TMS_OrderTypeKey = OH.OrderTypeKey, TMS_SourceAddrKey  = OH.SourceAddrKey
	FROM		Integration_JCB.dbo.Century_Header H
	INNER JOIN	TKT_SyncData A  WITH (NOLOCK) on A.TKT_DataKey = H.DataKey
	INNER JOIN	#Temp_Century ND  WITH (NOLOCK) ON A.TKT_DataKey = ND.TKT_DataKey
	INNER JOIN	Orderheader OH  WITH (NOLOCK) on A.TMS_OrderKey = OH.OrderKey
	WHERE		OH.custkey = @CustKey and isnull(H.TMS_OrderKey ,0) <> 0 
				and H.TMS_OrderKey <> A.TMS_OrderKey and A.SiteID = @SiteId

	PRINT '9'
	UPDATE		C 
	SET			TMS_ContainerSizeKey = OD.ContainerSizeKey, TMSOrderDetailKey = OD.OrderDetailKey
	FROM		Integration_JCB.dbo.Century_ContainerList C
	INNER JOIN	TKT_SyncData A  WITH (NOLOCK) on TKT_DataKey = C.DataKey and TKT_ContainerKey = C.ContainerKey and A.siteid = @SiteId
	INNER JOIN	OrderDetail OD  WITH (NOLOCK) on A.TMS_OrderDetailKey = OD.OrderDetailKey
	INNER JOIN	#TMP_Century_Header H WITH (NOLOCK)  on C.DataKey  = H.DataKey
	WHERE		isnull(H.TMS_OrderKey ,0) > 0 
				and C.TMSOrderDetailKey <> OD.OrderDetailKey and A.SiteID = @SiteId

	PRINT '10'
	UPDATE		SL 
	SET			TMS_LegKey = RD.legKey, TMS_RouteKey = RD.RouteKey, TMS_SourceAddrKey = RT.SourceAddrKey,
				TMS_DestinationAddrKey = RT.DestinationAddrKey
	FROM		Integration_JCB.dbo.Century_StopList SL
	INNER JOIN	Integration_JCB.dbo.Century_ContainerList FC  WITH (NOLOCK) on SL.ContainerKey = FC.ContainerKey
	INNER JOIN	TKT_SyncData A  WITH (NOLOCK) on FC.DataKey = TKT_DataKey and FC.ContainerKey = TKT_ContainerKey and A.SiteID = @SiteId
	INNER JOIN	#Temp_Century ND  WITH (NOLOCK) ON A.TKT_DataKey = ND.TKT_DataKey
	INNER JOIN	TKT_RouteData RD  WITH (NOLOCK) on  A.TMS_OrderDetailKey = RD.orderDetailKey and RD.stoptype = SL.stopNumber
	INNER JOIN	Routes RT  WITH (NOLOCK) on RD.RouteKey = RT.Routekey and isnull(Rt.IsDryRun,0) = 0
	WHERE		ISNULL(SL.TMS_RouteKey,0) <> RD.RouteKey OR ISNULL(SL.TMS_LegKey,0) <> RD.legKey and A.SiteID = @SiteId

	PRINT '11'
	SELECT		A.* , Case A.StopType when 1 then 'SF' when 2 then 'ST' when 3 then 'RT' else '' end as FacilityCode
	INTO		#Temp_RouteData
	FROM		(select	* , Row_number() over(partition by OrderDetailKey Order by OrderDetailKey, LegNo ) as StopType
				from	(SELECT DISTINCT	RT.OrderDetailKey, DT.RouteKey, OH.OrderTypeKey, OT.OrderType, L.FromLocation, 
										L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID
													--case when L.from then 'ShipFrom'
						FROM		Routes_DateTracker DT WITH (NOLOCK) 
						INNER JOIN	Routes RT  WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
						INNER JOIN	OrderDetail OD  WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
						INNER JOIN	TKT_SyncData SD  WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
						INNER JOIN	#Temp_Century ND  WITH (NOLOCK) ON SD.TKT_DataKey = ND.TKT_DataKey
						INNER JOIN	OrderHeader OH  WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
						INNER JOIN	OrderType OT   WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
						INNER JOIN	Leg L  WITH (NOLOCK) on RT.LegKey = L.LegKey
						WHERE	OT.OrderType = 'Import'  and isnull(Rt.IsDryRun,0) = 0
								and (L.FromLocation = 'PORT' OR L.ToLocation = 'Consignee' OR  L.ToLocation = 'Customer' 
								OR L.ToLocation = 'PORT') and SD.SiteID = @SiteId
						) A
				) A

	PRINT '12'
	DELETE FROM	TKT_RouteData
	WHERE		routekey in (SELECT			rd.routekey  
							FROM			TKT_RouteData RD WITH (NOLOCK) 
							INNER JOIN		OrderDetail OD  WITH (NOLOCK) on RD.OrderDetailKey = OD.OrderDetailKey
							INNER JOIN		OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey and OH.OrderTypeKey = 1
							LEFT JOIN		#Temp_RouteData A on A.OrderDetailKey = RD.OrderDetailKey and A.RouteKey = RD.RouteKey
							WHERE			A.OrderDetailKey is null  and OH.CustKey = @CustKey)

	PRINT '13'
	INSERT INTO	TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
				LegNo, IsEmpty, LegKey, StopType, FacilityCode, SITEID)
	SELECT		A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
				A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.SiteID
	FROM		#Temp_RouteData A
	LEFT JOIN	TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey 
	WHERE		RD.OrderDetailKey is null and A.SiteID = @SiteId

	PRINT '14'
	INSERT INTO	TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
				LegNo, IsEmpty, LegKey, StopType, FacilityCode, Siteid)
	SELECT		A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
				A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.SiteID
	FROM		#Temp_RouteData A
	LEFT JOIN	TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey and RD.RouteKey= A.RouteKey
	WHERE		RD.OrderDetailKey is null and A.SiteID = @SiteId

	PRINT '15'
	SELECT		A.* , Case A.StopType when 1 then 'SF' when 2 then 'ST' when 3 then 'RT' else '' end as FacilityCode
	INTO		#Temp_RouteDataExport
	FROM		(select	* , Row_number() over(partition by OrderDetailKey Order by OrderDetailKey, LegNo ) as StopType
				from	(SELECT DISTINCT	RT.OrderDetailKey, DT.RouteKey, OH.OrderTypeKey, OT.OrderType, L.FromLocation, 
										L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID
										--case when L.from then 'ShipFrom'
						FROM			Routes_DateTracker DT WITH (NOLOCK) 
						INNER JOIN		Routes RT  WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
						INNER JOIN		OrderDetail OD  WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
						INNER JOIN		TKT_SyncData SD  WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
						INNER JOIN		#Temp_Century ND  WITH (NOLOCK) ON SD.TKT_DataKey = ND.TKT_DataKey
						INNER JOIN		OrderHeader OH  WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
						INNER JOIN		OrderType OT   WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
						INNER JOIN		Leg L  WITH (NOLOCK) on RT.LegKey = L.LegKey
						WHERE			OT.OrderType = 'EXPORT' and isnull(Rt.IsDryRun,0) = 0
										and ((L.FromLocation in ('Shipper','Consignee','Customer'))
										OR ( L.ToLocation = 'PORT')
										OR ( RT.LegNo = 1 and RT.IsEmpty =1 and L.FromLocation in ('Yard','Port')))
										and SD.SiteID = @SiteId
						) A
				) A

	PRINT '16'
	DELETE FROM	TKT_RouteData
	WHERE		routekey in (SELECT			rd.routekey  
							FROM			#Temp_RouteDataExport RD
							INNER JOIN		orderDetail OD  WITH (NOLOCK) on RD.OrderDetailKey = OD.OrderDetailKey
							INNER JOIN		OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey and OH.OrderTypeKey = 2
							LEFT JOIN		#Temp_RouteDataExport A on A.OrderDetailKey = RD.OrderDetailKey and A.RouteKey = RD.RouteKey
							WHERE			A.OrderDetailKey is null and OH.custkey = @CustKey
							)

	PRINT '17'
	INSERT INTO	TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
				LegNo, IsEmpty, LegKey, StopType, FacilityCode, siteid)
	SELECT		A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
				A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.siteid
	FROM		#Temp_RouteDataExport A
	LEFT JOIN	TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey 
	WHERE		RD.OrderDetailKey is null and A.SiteID = @SiteId

	PRINT '18'
	INSERT INTO	TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
				LegNo, IsEmpty, LegKey, StopType, FacilityCode, siteid)
	SELECT		A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
				A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.siteid
	FROM		#Temp_RouteDataExport A
	LEFT JOIN	TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey and RD.RouteKey= A.RouteKey
	WHERE		RD.OrderDetailKey is null and A.SiteID = @SiteId

	PRINT '19'
	DELETE FROM	TMS_INTEGRATION_ROUTES 
	WHERE		TMS_RouteKey in (SELECT DISTINCT		TMS_RouteKey
								FROM					TMS_Integration_Routes TR WITH (NOLOCK) 
								LEFT JOIN				Routes RT WITH (NOLOCK)  on TR.TMS_RouteKey = RT.RouteKey
								WHERE					SiteID = @siteID and (RT.routekey is null OR ISNULL(RT.IsDryrun,0) = 1)
								)
	
	-- SELECT  * FROM #Temp_Century

	PRINT '20'
	INSERT INTO	TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey, StopType)
	SELECT		SD.siteid, SD.TKT_DataKey, SD.TKT_ContainerKey, SL.StopKey, RD.RouteKey, R.LegKey, RD.LocationType
	FROM		TKT_RouteDataNew RD WITH (NOLOCK) 
	INNER JOIN	vRoutes_Century R  WITH (NOLOCK) ON RD.RouteKey = R.RouteKey 
	INNER JOIN	TKT_SyncData SD  WITH (NOLOCK) on SD.TMS_OrderDetailKey = R.AppliedOrderDetailKey
	INNER JOIN	#Temp_Century ND  WITH (NOLOCK) ON SD.TKT_DataKey = ND.TKT_DataKey
	INNER JOIN	Integration_JCB.dbo.Century_StopList SL on SL.ContainerKey = SD.TKT_ContainerKey and RD.LocationType = SL.facilityCode
	LEFT JOIN	TMS_integration_routes TR  WITH (NOLOCK) on SD.TKT_DataKey = TR.DataKey AND R.RouteKey = TR.TMS_RouteKey and SD.SiteID = TR.SiteID 	
				AND SL.StopKey = TR.StopKey
	WHERE		TR.TMS_RouteKey is null and SD.SiteID = @SiteID AND ISNULL(R.IsDryRun,0) = 0
	

	PRINT '21'
	UPDATE		SL 
	SET			TMS_LegKey = RD.legKey, TMS_RouteKey = RD.RouteKey, TMS_SourceAddrKey = RT.SourceAddrKey,
				TMS_DestinationAddrKey = RT.DestinationAddrKey
				--select *
	FROM		Integration_JCB.dbo.Century_StopList SL WITH (NOLOCK) 
	INNER JOIN	Integration_JCB.dbo.Century_ContainerList FC  WITH (NOLOCK) on SL.ContainerKey = FC.ContainerKey
	INNER JOIN	TKT_SyncData A  WITH (NOLOCK) on FC.DataKey = TKT_DataKey and FC.ContainerKey = TKT_ContainerKey and A.SiteID = @SiteId
	INNER JOIN	#Temp_Century ND  WITH (NOLOCK) ON A.TKT_DataKey = ND.TKT_DataKey
	INNER JOIN	TKT_RouteData RD  WITH (NOLOCK) on  A.TMS_OrderDetailKey = RD.orderDetailKey and RD.stoptype = SL.stopNumber
	INNER JOIN	Routes RT  WITH (NOLOCK) on RD.RouteKey = RT.Routekey 
	WHERE		(SL.TMS_RouteKey <> RD.RouteKey OR SL.TMS_LegKey <> RD.legKey) and A.SiteID = @SiteId


	drop table			#Temp_Century
	drop table			#Temp_RouteDataExport
	drop table			#Temp_RouteData
END
