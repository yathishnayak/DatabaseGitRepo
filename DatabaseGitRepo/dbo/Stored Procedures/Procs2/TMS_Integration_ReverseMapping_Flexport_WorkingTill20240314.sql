
CREATE Proc [dbo].[TMS_Integration_ReverseMapping_Flexport_WorkingTill20240314] -- [TMS_Integration_ReverseMapping_Flexport] 16084
(
	@DataKey	int
)
as
Begin
	Declare @SiteId varchar(20) = 'FLEXPORT',
			@CustKey	int = 1966
	--select * from TKT_SyncData where left(TMS_BrokerRefNo,5) <> 'FLEX-'
	print '1'

	insert into TKT_SyncData (TKT_DataKey, TKT_WorkOrderNumber,  TKT_ShipmentReferenceNumber, TKT_IsAccepted, 
		TKT_ContainerKey, TKT_EquipmentNumber, TMS_OrderKey, TMS_BrokerRefNo, TMS_OrderDetailKey, TMS_ContainerNo, 
		SiteID)
	Select Kh.DataKey, Kh.workOrderNumber, KH.shipmentReferenceNumber, KH.isAccepted,
		CL.ContainerKey, CL.equipmentNumber, OH.OrderKey, OH.BrokerRefNo, OD.OrderDetailKey, OD.ContainerNo, @SiteId
	from Integration_JCB.dbo.Flexpro_Header KH  WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on KH.TMS_OrderKey = OH.orderkey
	inner join Integration_JCB.dbo.Flexpro_ContainerList CL  WITH (NOLOCK) on Kh.DataKey = CL.DataKey
	inner join OrderDetail OD  WITH (NOLOCK) on OH.orderkey = OD.OrderKey
	Left Join TKT_SyncData SD  WITH (NOLOCK) on KH.DataKey = SD.TKT_DataKey and KH.TMS_OrderKey = SD.TMS_OrderKey
	where SD.TMS_OrderKey is null and KH.DataKey = @DataKey

	SElect	IH.DataKey as TKT_DataKey, 
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
	Into #Temp_Flexport
	from Integration_JCB.dbo.Flexpro_Header IH WITH (NOLOCK) 
	Inner Join (Select datakey, ContainerKey, equipmentNumber from  Integration_JCB.dbo.Flexpro_ContainerList WITH (NOLOCK) ) IC on IH.DataKey = IC.DataKey
	LEft join OrderHeader OH  WITH (NOLOCK) on IH.TMS_OrderKey = OH.OrderKey
	LEFT join OrderHeader OH2  WITH (NOLOCK) on LEFT(IH.shipmentReferenceNumber,13) = left(OH2.BrokerRefNo,13)
	LEft join (select OrderKey,OrderDetailKey, ContainerNo from  OrderDetail  WITH (NOLOCK) ) OD on OD.OrderKey = isnull(OH.OrderKey,OH2.OrderKey)
	where  OH.OrderKey is null and isnull(IH.ProcessStatus,'') = '' and IC.equipmentNumber = OD.ContainerNo
	and OH2.OrderKey is not null and IH.isAccepted =1 and OH2.CustKey = @CustKey and IH.DataKey = @DataKey

	select '#Temp_Flexport',* from #Temp_Flexport

	print '2'
	update SD set
		TMS_OrderDetailKey = ND.TMS_OrderDetailKey,
		TMS_BrokerRefNo = ND.TMS_BrokerRefNo,
		TMS_ContainerNo = ND.TMS_ContainerNo,
		TMS_OrderKey = ND.TMS_OrderKey
	--select * 
	from TKT_SyncData SD
	inner join #Temp_Flexport ND on SD.TKT_DataKey = ND.TKT_DataKey and SD.SiteID = @SiteId
	where isnull(SD.TMS_OrderKey,0) <> isnull(ND.TMS_OrderKey,0) OR SD.TMS_OrderDetailKey <> ND.TMS_OrderDetailKey 
		and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '3'
	insert into TKT_SyncData (TKT_DataKey, TKT_WorkOrderNumber, TKT_ShipmentReferenceNumber, TKT_IsAccepted, 
				TKT_ContainerKey, TKT_EquipmentNumber, TMS_OrderKey, TMS_BrokerRefNo, TMS_OrderDetailKey, 
				TMS_ContainerNo, SiteID)
	select ND.TKT_DataKey, ND.TKT_WorkOrderNumber, ND.TKT_ShipmentReferenceNumber, ND.TKT_IsAccepted, 
				ND.TKT_ContainerKey, ND.TKT_EquipmentNumber, ND.TMS_OrderKey, ND.TMS_BrokerRefNo, ND.TMS_OrderDetailKey, 
				ND.TMS_ContainerNo, ND.SiteID 
	from #Temp_Flexport ND WITH (NOLOCK) 
	left join TKT_SyncData SD  WITH (NOLOCK) on SD.TKT_DataKey = ND.TKT_DataKey
	where SD.TKT_DataKey is null and ND.SiteID = @SiteId 

	print '4'
	update TH set TMS_OrderKey = Ts.TMS_OrderKey, DataType = 'Update'
	--select * 
	from TMS_Integration_Header TH WITH (NOLOCK) 
	inner join TKT_SyncData TS  WITH (NOLOCK) on TH.DataKey = TS.TKT_DataKey
	where TH.SiteID = TS.SiteID  and TS.TMS_OrderKey <> TH.TMS_OrderKey and TH.SiteID = @SiteId
		and TH.DataKey = @DataKey

	print '5'
	insert into TMS_Integration_Header(SiteID, DataKey, WorkOrdernumber,  TMS_OrderKey, DataType)
	select distinct SD.Siteid, TKT_DataKey, TKT_WorkOrderNumber, SD.TMS_OrderKey, 'UPDATE'
	from TKT_SyncData SD WITH (NOLOCK) 
	inner join OrderHeader OH  WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey and OH.custkey = @CustKey
	left join TMS_Integration_Header TH  WITH (NOLOCK) on SD.TKT_DataKey = TH.DataKey and SD.SiteID = TH.SiteID
	where TH.SiteID is null  and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '6'
	insert into TMS_Integration_Container ( SiteID, DataKey, ContainerKey, ContainerNo,TMS_OrderDetailKey)
	select SD.SiteID, TKT_DataKey, TKT_ContainerKey, TMS_ContainerNo, SD.TMS_OrderDetailKey
	from TKT_SyncData SD WITH (NOLOCK) 
	inner join OrderDetail OD  WITH (NOLOCK) on SD.TMS_OrderDetailKey = OD.OrderDetailKey  and SD.SiteID = @SiteId
	inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey and OH.custkey = @CustKey
	LEft join TMS_Integration_Container TC  WITH (NOLOCK) on SD.TKT_ContainerKey = TC.ContainerKey and SD.SiteID = Tc.SiteID
	where TC.siteid is null and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '7'
	update H set TMS_OrderKey = A.TMS_OrderKey, TMS_CSRKey = OH.CsrKey, TMS_CarrierKey = OH.CarrierKey,
		TMS_DestinationAddrKey = OH.DestinationAddrKey, TMS_OrderDate = OH.OrderDate, 
		TMS_OrderNo = OH.OrderNo, TMS_OrderTypeKey = OH.OrderTypeKey, TMS_SourceAddrKey  = OH.SourceAddrKey
	--select *
	from Integration_JCB.dbo.Flexpro_Header H 
	inner join TKT_SyncData A  WITH (NOLOCK) on A.TKT_DataKey = H.DataKey
	inner join Orderheader OH  WITH (NOLOCK) on A.TMS_OrderKey = OH.OrderKey 
	where OH.custkey = @CustKey and isnull(H.TMS_OrderKey ,0) = 0 and isnull(ProcessStatus ,'') = ''
		and A.SiteID = @SiteId and H.DataKey = @DataKey

	print '8'
	update H set TMS_OrderKey = A.TMS_OrderKey, TMS_CSRKey = OH.CsrKey, TMS_CarrierKey = OH.CarrierKey,
		TMS_DestinationAddrKey = OH.DestinationAddrKey, TMS_OrderDate = OH.OrderDate, 
		TMS_OrderNo = OH.OrderNo, TMS_OrderTypeKey = OH.OrderTypeKey, TMS_SourceAddrKey  = OH.SourceAddrKey
	--select *
	from Integration_JCB.dbo.Flexpro_Header H
	inner join TKT_SyncData A  WITH (NOLOCK) on A.TKT_DataKey = H.DataKey
	inner join Orderheader OH  WITH (NOLOCK) on A.TMS_OrderKey = OH.OrderKey
	where OH.custkey = @CustKey and isnull(H.TMS_OrderKey ,0) <> 0 and isnull(ProcessStatus ,'') = '' 
		and H.TMS_OrderKey <> A.TMS_OrderKey and A.SiteID = @SiteId and H.DataKey = @DataKey

	print '9'
	update C set TMS_ContainerSizeKey = OD.ContainerSizeKey, TMSOrderDetailKey = OD.OrderDetailKey
	--select *
	from Integration_JCB.dbo.Flexpro_ContainerList C
	inner join TKT_SyncData A  WITH (NOLOCK) on TKT_DataKey = C.DataKey and TKT_ContainerKey = C.ContainerKey and A.siteid = @SiteId
	inner join OrderDetail OD  WITH (NOLOCK) on A.TMS_OrderDetailKey = OD.OrderDetailKey
	inner join Integration_JCB.dbo.Flexpro_Header H  WITH (NOLOCK) on C.DataKey  = H.DataKey
	where isnull(H.TMS_OrderKey ,0) > 0-- and isnull(H.ProcessStatus ,'') = '' 
		and C.TMSOrderDetailKey <> OD.OrderDetailKey and A.SiteID = @SiteId and A.TKT_DataKey = @DataKey

	print '10'
	update  SL set TMS_LegKey = RD.legKey, TMS_RouteKey = RD.RouteKey, TMS_SourceAddrKey = RT.SourceAddrKey,
		TMS_DestinationAddrKey = RT.DestinationAddrKey
	--select *
	from Integration_JCB.dbo.Flexpro_StopList SL
	inner join Integration_JCB.dbo.Flexpro_ContainerList FC  WITH (NOLOCK) on SL.ContainerKey = FC.ContainerKey
	inner join TKT_SyncData A  WITH (NOLOCK) on FC.DataKey = TKT_DataKey and FC.ContainerKey = TKT_ContainerKey and A.SiteID = @SiteId
	inner join TKT_RouteData RD  WITH (NOLOCK) on  A.TMS_OrderDetailKey = RD.orderDetailKey and RD.stoptype = SL.stopNumber
	inner join Routes RT  WITH (NOLOCK) on RD.RouteKey = RT.Routekey and isnull(RT.IsDryRun,0) = 0
	where isnull(SL.TMS_RouteKey,0) <> RD.RouteKey OR isnull(SL.TMS_LegKey,0) <> RD.legKey and A.SiteID = @SiteId
		and A.TKT_DataKey = @DataKey

	print '11'
	select A.* , Case A.StopType when 1 then 'SF' when 2 then 'ST' when 3 then 'RT' else '' end as FacilityCode
	into #Temp_RouteData
	from (
		select * , Row_number() over(partition by OrderDetailKey Order by OrderDetailKey, LegNo ) as StopType
		from (
			select distinct RT.OrderDetailKey, DT.RouteKey, OH.OrderTypeKey, OT.OrderType, L.FromLocation, 
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID
			--case when L.from then 'ShipFrom'
			from Routes_DateTracker DT WITH (NOLOCK) 
			inner join Routes RT  WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD  WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD  WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH  WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT   WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L  WITH (NOLOCK) on RT.LegKey = L.LegKey
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0
			and (L.FromLocation = 'PORT' OR L.ToLocation = 'Consignee' OR  L.ToLocation = 'Customer' 
				OR L.ToLocation = 'PORT')
			and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey
		) A
	) A

	select '#Temp_RouteData', * from #Temp_RouteData

	print '12'
	delete from TKT_RouteData
	where routekey in (
	select rd.routekey  
	from TKT_RouteData RD WITH (NOLOCK) 
	inner join OrderDetail OD  WITH (NOLOCK) on RD.OrderDetailKey = OD.OrderDetailKey
	inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey and OH.OrderTypeKey = 1
	inner join TKT_SyncData SD  WITH (NOLOCK) on SD.TMS_OrderDetailKey = RD.OrderDetailKey
	LEft join #Temp_RouteData A on A.OrderDetailKey = RD.OrderDetailKey and A.RouteKey = RD.RouteKey
	where A.OrderDetailKey is null  and OH.CustKey = @CustKey and SD.TKT_DataKey = @DataKey )

	print '13'
	insert into TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
		LegNo, IsEmpty, LegKey, StopType, FacilityCode, SITEID)
	select A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
		A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.Siteid
	from #Temp_RouteData A
	inner join TKT_SyncData SD  WITH (NOLOCK) on A.OrderDetailKey = SD.TMS_OrderDetailKey
	LEft join TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey 
	where RD.OrderDetailKey is null and A.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '14'
	insert into TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
		LegNo, IsEmpty, LegKey, StopType, FacilityCode, siteid)
	select A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
		A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.SiteID
	from #Temp_RouteData A
	inner join TKT_SyncData SD  WITH (NOLOCK) on A.OrderDetailKey = SD.TMS_OrderDetailKey
	LEft join TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey and RD.RouteKey= A.RouteKey
	where RD.OrderDetailKey is null and A.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '15'
	select A.* , Case A.StopType when 1 then 'SF' when 2 then 'ST' when 3 then 'RT' else '' end as FacilityCode
	into #Temp_RouteDataExport
	from (
		select * , Row_number() over(partition by OrderDetailKey Order by OrderDetailKey, LegNo ) as StopType
		from (
			select distinct RT.OrderDetailKey, DT.RouteKey, OH.OrderTypeKey, OT.OrderType, L.FromLocation, 
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID
			--case when L.from then 'ShipFrom'
			from Routes_DateTracker DT WITH (NOLOCK) 
			inner join Routes RT  WITH (NOLOCK) on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD  WITH (NOLOCK) on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD  WITH (NOLOCK) on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH  WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT   WITH (NOLOCK) on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L  WITH (NOLOCK) on RT.LegKey = L.LegKey
			where OT.OrderType = 'EXPORT' and isnull(RT.IsDryRun,0) = 0
			and ((L.FromLocation in ('Shipper','Consignee','Customer'))
				OR ( L.ToLocation = 'PORT')
				OR ( RT.LegNo = 1 and RT.IsEmpty =1 and L.FromLocation in ('Yard','Port')))
				and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey
		) A
	) A

	select '#Temp_RouteDataExport', * from #Temp_RouteDataExport

	print '16'
	delete from TKT_RouteData
	where routekey in (
		select rd.routekey  
		from #Temp_RouteDataExport RD
		inner join orderDetail OD  WITH (NOLOCK) on RD.OrderDetailKey = OD.OrderDetailKey
		inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey and OH.OrderTypeKey = 2
		inner join TKT_SyncData SD  WITH (NOLOCK) on OH.OrderKey = SD.TMS_OrderKey
		LEft join #Temp_RouteDataExport A on A.OrderDetailKey = RD.OrderDetailKey and A.RouteKey = RD.RouteKey
		where A.OrderDetailKey is null and OH.custkey = @CustKey and SD.TKT_DataKey = @DataKey
	)

	print '17'
	insert into TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
		LegNo, IsEmpty, LegKey, StopType, FacilityCode, Siteid)
	select A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
		A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.SiteID
	from #Temp_RouteDataExport A 
	LEft join TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey 
	inner join TKT_SyncData SD  WITH (NOLOCK) on A.OrderDetailKey = SD.TMS_OrderDetailKey
	where RD.OrderDetailKey is null and A.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '18'
	insert into TKT_RouteData  (OrderDetailKey, RouteKey, OrderTypeKey, OrderType, FromLocation, ToLocation,
		LegNo, IsEmpty, LegKey, StopType, FacilityCode, Siteid)
	select A.OrderDetailKey, A.RouteKey, A.OrderTypeKey, A.OrderType, A.FromLocation, A.ToLocation,
		A.LegNo, A.IsEmpty, A.LegKey, A.StopType, A.FacilityCode, A.siteid
	from #Temp_RouteDataExport A
	inner join TKT_SyncData SD  WITH (NOLOCK) on A.OrderDetailKey = SD.TMS_OrderDetailKey
	LEft join TKT_RouteData RD  WITH (NOLOCK) on A.OrderDetailKey = RD.OrderDetailKey and RD.RouteKey= A.RouteKey
	where RD.OrderDetailKey is null and A.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	Exec TMS_Integration_Flexport_UpdateMissingRoute @dataKey

	delete from TMS_Integration_Routes where Siteid = 'Flexport' and  TMS_RouteKey in (
		select distinct TMS_RouteKey 
		from TMS_Integration_Routes TR WITH (NOLOCK) 
		left join Routes RT  WITH (NOLOCK) on TR.TMS_RouteKey = RT.routekey
		where TR.SiteID = @SiteId and RT.routeKey is null)

	print '19'
		delete from TMS_Integration_Routes where TMS_Routekey in (
		select TMS_Routekey
		from tms_integration_routes TR WITH (NOLOCK) 
		left join Routes RT  WITH (NOLOCK) on TR.Tms_routeKey  = RT.RouteKey
		where TR.DataKey = @DataKey and RT.Routekey is null)

	Insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey)
	select SD.siteid, SD.TKT_DataKey, TKT_ContainerKey, SL.StopKey, RD.RouteKey, RD.LegKey
	from TKT_RouteData RD WITH (NOLOCK) 
	inner join TKT_SyncData SD  WITH (NOLOCK) on SD.TMS_OrderDetailKey = RD.OrderDetailKey
	inner join Integration_JCB.dbo.Flexpro_StopList SL  WITH (NOLOCK) on SL.ContainerKey = SD.TKT_ContainerKey and RD.StopType = SL.stopNumber
	LEft join TMS_integration_routes TR  WITH (NOLOCK) on SD.TKT_DataKey = TR.DataKey and SD.SiteID = TR.SiteID and TR.TMS_RouteKey = RD.RouteKey
	where TR.DataKey is null and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	Print '20'
	update  SL set TMS_LegKey = RD.legKey, TMS_RouteKey = RD.RouteKey, TMS_SourceAddrKey = RT.SourceAddrKey,
		TMS_DestinationAddrKey = RT.DestinationAddrKey
	--select *
	from Integration_JCB.dbo.Flexpro_StopList SL
	inner join Integration_JCB.dbo.Flexpro_ContainerList FC  WITH (NOLOCK) on SL.ContainerKey = FC.ContainerKey
	inner join TKT_SyncData A  WITH (NOLOCK) on FC.DataKey = TKT_DataKey and FC.ContainerKey = TKT_ContainerKey and A.SiteID = @SiteId
	inner join TKT_RouteData RD  WITH (NOLOCK) on  A.TMS_OrderDetailKey = RD.orderDetailKey and RD.stoptype = SL.stopNumber
	inner join Routes RT  WITH (NOLOCK) on RD.RouteKey = RT.Routekey 
	where SL.TMS_RouteKey <> RD.RouteKey OR SL.TMS_LegKey <> RD.legKey and A.SiteID = @SiteId and A.TKT_DataKey = @DataKey

	Exec  TMS_Integration_Flexport_PortToConsignee @datakey

	select 'TKT_SyncData', * from TKT_SyncData where tkt_datakey = @DataKey
	select 'TMS_Integration_Header', * from TMS_Integration_Header where datakey = @DataKey
	select 'TMS_Integration_Container', * from TMS_Integration_Container where datakey = @DataKey
	select 'TMS_Integration_Routes', * from TMS_Integration_Routes where datakey = @DataKey

	select 'Flexpro_Header', * from Integration_JCB.dbo.Flexpro_Header where DataKey = @DataKey
	select 'Flexpro_ContainerList',* from Integration_JCB.dbo.Flexpro_ContainerList where datakey = @DataKey

	select 'Flexpro_StopList', b.* from Integration_JCB.dbo.Flexpro_ContainerList A
	inner join Integration_JCB.dbo.Flexpro_StopList B on A.ContainerKey = B.ContainerKey
	where A.DataKey = @DataKey

	drop table #Temp_Flexport
	drop table #Temp_RouteDataExport
	drop table #Temp_RouteData
END
