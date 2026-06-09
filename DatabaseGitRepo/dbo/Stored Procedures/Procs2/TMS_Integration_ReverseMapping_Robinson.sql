

CREATE Proc [dbo].[TMS_Integration_ReverseMapping_Robinson] -- [TMS_Integration_ReverseMapping_Robinson_New] 1505 
(
	@DataKey	int
)
as
Begin
	Declare @SiteId varchar(20) = 'Robinson'
			--@CustKey	int = 3170
	select custkey into #RobinsonCustKeys from Customer where custname like '%robins%'

	--select * from TKT_SyncData where left(TMS_BrokerRefNo,5) <> 'FLEX-'
	print '1'
	EXEC UPDATE_TKT_ROUTESDATANEW_ONReverseMapping @dataKey

	insert into TKT_SyncData (TKT_DataKey, TKT_WorkOrderNumber,  TKT_ShipmentReferenceNumber, TKT_IsAccepted, 
		TKT_ContainerKey, TKT_EquipmentNumber, TMS_OrderKey, TMS_BrokerRefNo, TMS_OrderDetailKey, TMS_ContainerNo, 
		SiteID)
	Select Kh.DataKey, Kh.workOrderNumber, KH.shipmentReferenceNumber, KH.isAccepted,
		CL.ContainerKey, CL.equipmentNumber, OH.OrderKey, OH.BrokerRefNo, OD.OrderDetailKey, OD.ContainerNo, @SiteId
	from Integration_JCB.dbo.Robinson_Header KH  WITH (NOLOCK)
	inner join OrderHeader OH  WITH (NOLOCK) on KH.TMS_OrderKey = OH.orderkey
	inner join Integration_JCB.dbo.Robinson_ContainerList CL  WITH (NOLOCK) on Kh.DataKey = CL.DataKey
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
	Into #Temp_Robinson
	from Integration_JCB.dbo.Robinson_Header IH WITH (NOLOCK) 
	Inner Join (Select datakey, ContainerKey, equipmentNumber from  Integration_JCB.dbo.Robinson_ContainerList WITH (NOLOCK) ) IC on IH.DataKey = IC.DataKey
	LEft join OrderHeader OH  WITH (NOLOCK) on IH.TMS_OrderKey = OH.OrderKey
	LEFT join OrderHeader OH2  WITH (NOLOCK) on LEFT(IH.shipmentReferenceNumber,13) = left(OH2.BrokerRefNo,13)
	LEft join (select OrderKey,OrderDetailKey, ContainerNo from  OrderDetail  WITH (NOLOCK) ) OD on OD.OrderKey = isnull(OH.OrderKey,OH2.OrderKey)
	where  OH.OrderKey is null and isnull(IH.ProcessStatus,'') = '' and IC.equipmentNumber = OD.ContainerNo
	and OH2.OrderKey is not null and IH.isAccepted =1 and OH2.CustKey IN (SELECT CustKey FROm #RobinsonCustKeys) and IH.DataKey = @DataKey

	select '#Temp_Robinson',* from #Temp_Robinson

	print '2'
	update SD set
		TMS_OrderDetailKey = ND.TMS_OrderDetailKey,
		TMS_BrokerRefNo = ND.TMS_BrokerRefNo,
		TMS_ContainerNo = ND.TMS_ContainerNo,
		TMS_OrderKey = ND.TMS_OrderKey
	--select * 
	from TKT_SyncData SD
	inner join #Temp_Robinson ND on SD.TKT_DataKey = ND.TKT_DataKey and SD.SiteID = @SiteId
	where isnull(SD.TMS_OrderKey,0) <> isnull(ND.TMS_OrderKey,0) OR SD.TMS_OrderDetailKey <> ND.TMS_OrderDetailKey 
		and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '3'
	insert into TKT_SyncData (TKT_DataKey, TKT_WorkOrderNumber, TKT_ShipmentReferenceNumber, TKT_IsAccepted, 
				TKT_ContainerKey, TKT_EquipmentNumber, TMS_OrderKey, TMS_BrokerRefNo, TMS_OrderDetailKey, 
				TMS_ContainerNo, SiteID)
	select ND.TKT_DataKey, ND.TKT_WorkOrderNumber, ND.TKT_ShipmentReferenceNumber, ND.TKT_IsAccepted, 
				ND.TKT_ContainerKey, ND.TKT_EquipmentNumber, ND.TMS_OrderKey, ND.TMS_BrokerRefNo, ND.TMS_OrderDetailKey, 
				ND.TMS_ContainerNo, ND.SiteID 
	from #Temp_Robinson ND WITH (NOLOCK) 
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
	inner join OrderHeader OH  WITH (NOLOCK) on SD.TMS_OrderKey = OH.OrderKey and OH.custkey IN (SELECT CustKey FROm #RobinsonCustKeys)
	left join TMS_Integration_Header TH  WITH (NOLOCK) on SD.TKT_DataKey = TH.DataKey and SD.SiteID = TH.SiteID
	where TH.SiteID is null  and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	print '6'
	insert into TMS_Integration_Container ( SiteID, DataKey, ContainerKey, ContainerNo,TMS_OrderDetailKey)
	select SD.SiteID, TKT_DataKey, TKT_ContainerKey, TMS_ContainerNo, SD.TMS_OrderDetailKey
	from TKT_SyncData SD WITH (NOLOCK) 
	inner join OrderDetail OD  WITH (NOLOCK) on SD.TMS_OrderDetailKey = OD.OrderDetailKey  and SD.SiteID = @SiteId
	inner join OrderHeader OH  WITH (NOLOCK) on OD.OrderKey = OH.OrderKey and OH.custkey IN (SELECT CustKey FROm #RobinsonCustKeys)
	LEft join TMS_Integration_Container TC  WITH (NOLOCK) on SD.TKT_ContainerKey = TC.ContainerKey and SD.SiteID = Tc.SiteID
	where TC.siteid is null and SD.SiteID = @SiteId and SD.TKT_DataKey = @DataKey

	delete from TMS_Integration_Routes where Datakey = @DataKey and Siteid = @SiteId and Stopkey in (
	select distinct StopKey 
	from tms_integration_routes TR
	Left Join Routes RT on TR.TMS_RouteKey = RT.routekey and TR.TMS_LegKey = RT.LegKey
	where TR.datakey =@Datakey and TR.siteid = @SiteId and RT.routekey is null )

	insert into TMS_Integration_routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey, StopType )
	select TH.SiteID, TH.DataKey, TC.ContainerKey, SL.StopKey, RD.RouteKey, RD.TMS_LegKey, SL.facilityCode
	from TKT_RouteDataNew RD
	inner join TMS_Integration_Header TH on RD.OrderKey = TH.TMS_OrderKey 
	inner join TMS_Integration_Container TC on TH.DataKey = TC.DataKey and TH.SiteID = TC.SiteID
	inner join Integration_JCB.dbo.Robinson_StopList SL on TC.ContainerKey = SL.ContainerKey and RD.LocationType = SL.facilityCode
		LEft join TMS_Integration_Routes TRT on Tc.DataKey = TRT.DataKey and TC.ContainerKey = TRT.ContainerKey 
		and TC.SiteID = TRT.SiteID and SL.StopKey = TRT.StopKey
	where TH.DataKey = @DataKey and TRT.TMS_RouteKey is null 

	update TRT set TMS_RouteKey = RD.RouteKey, TMS_LegKey = RD.TMS_LegKey, StopType = RD.LocationType
	from TKT_RouteDataNew RD
	inner join TMS_Integration_Header TH on RD.OrderKey = TH.TMS_OrderKey 
	inner join TMS_Integration_Container TC on TH.DataKey = TC.DataKey and TH.SiteID = TC.SiteID
	inner join Integration_JCB.dbo.Robinson_StopList SL on TC.ContainerKey = SL.ContainerKey and RD.LocationType = SL.facilityCode
	inner join TMS_Integration_Routes TRT on Tc.DataKey = TRT.DataKey and TC.ContainerKey = TRT.ContainerKey 
		and TC.SiteID = TRT.SiteID and SL.StopKey = TRT.StopKey
	where TH.DataKey = @DataKey and TRT.StopKey = SL.StopKey

	print '7'
	update H set TMS_OrderKey = A.TMS_OrderKey, TMS_CSRKey = OH.CsrKey, TMS_CarrierKey = OH.CarrierKey,
		TMS_DestinationAddrKey = OH.DestinationAddrKey, TMS_OrderDate = OH.OrderDate, 
		TMS_OrderNo = OH.OrderNo, TMS_OrderTypeKey = OH.OrderTypeKey, TMS_SourceAddrKey  = OH.SourceAddrKey
	--select *
	from Integration_JCB.dbo.Robinson_Header H 
	inner join TKT_SyncData A  WITH (NOLOCK) on A.TKT_DataKey = H.DataKey
	inner join Orderheader OH  WITH (NOLOCK) on A.TMS_OrderKey = OH.OrderKey 
	where OH.custkey IN (SELECT CustKey FROm #RobinsonCustKeys) and isnull(H.TMS_OrderKey ,0) = 0 and isnull(ProcessStatus ,'') = ''
		and A.SiteID = @SiteId and H.DataKey = @DataKey

	print '8'
	update H set TMS_OrderKey = A.TMS_OrderKey, TMS_CSRKey = OH.CsrKey, TMS_CarrierKey = OH.CarrierKey,
		TMS_DestinationAddrKey = OH.DestinationAddrKey, TMS_OrderDate = OH.OrderDate, 
		TMS_OrderNo = OH.OrderNo, TMS_OrderTypeKey = OH.OrderTypeKey, TMS_SourceAddrKey  = OH.SourceAddrKey
	--select *
	from Integration_JCB.dbo.Robinson_Header H
	inner join TKT_SyncData A  WITH (NOLOCK) on A.TKT_DataKey = H.DataKey
	inner join Orderheader OH  WITH (NOLOCK) on A.TMS_OrderKey = OH.OrderKey
	where OH.custkey IN (SELECT CustKey FROm #RobinsonCustKeys) and isnull(H.TMS_OrderKey ,0) <> 0 and isnull(ProcessStatus ,'') = '' 
		and H.TMS_OrderKey <> A.TMS_OrderKey and A.SiteID = @SiteId and H.DataKey = @DataKey

	print '9'
	update C set TMS_ContainerSizeKey = OD.ContainerSizeKey, TMSOrderDetailKey = OD.OrderDetailKey
	--select *
	from Integration_JCB.dbo.Robinson_ContainerList C
	inner join TKT_SyncData A  WITH (NOLOCK) on TKT_DataKey = C.DataKey and TKT_ContainerKey = C.ContainerKey and A.siteid = @SiteId
	inner join OrderDetail OD  WITH (NOLOCK) on A.TMS_OrderDetailKey = OD.OrderDetailKey
	inner join Integration_JCB.dbo.Robinson_Header H  WITH (NOLOCK) on C.DataKey  = H.DataKey
	where isnull(H.TMS_OrderKey ,0) > 0-- and isnull(H.ProcessStatus ,'') = '' 
		and C.TMSOrderDetailKey <> OD.OrderDetailKey and A.SiteID = @SiteId and A.TKT_DataKey = @DataKey

	print '10'
	-- To handle the Leg Changes
	UPDATE			SL 
	SET				TMS_RouteKey = null, TMS_LegKey = null, IsScheduleSent = 0, ScheduledDateTime = null,
					IsActualSent = 0, ActualDateTime = null, ScheduleSentDate = null, ActualSentDate = null 
	FROM			Integration_JCB.dbo.Robinson_StopList SL
	INNER JOIN		Integration_JCB.dbo.Robinson_ContainerList FC  WITH (NOLOCK) on SL.ContainerKey = FC.ContainerKey
	LEFT JOIN		TKT_RouteDatanew RT  WITH (NOLOCK) on SL.TMS_RouteKey = RT.Routekey and SL.TMS_LegKey = Rt.TMS_LegKey 
					and RT.LocationType = SL.facilityCode 
	WHERE			FC.DataKey = @DataKey and  RT.RouteKey is null

	print '11'
	update  SL set TMS_LegKey = RD.TMS_legKey, TMS_RouteKey = RD.RouteKey, TMS_SourceAddrKey = RT.SourceAddrKey,
		TMS_DestinationAddrKey = RT.DestinationAddrKey
	--select *
	from Integration_JCB.dbo.Robinson_StopList SL
	inner join Integration_JCB.dbo.Robinson_ContainerList FC  WITH (NOLOCK) on SL.ContainerKey = FC.ContainerKey
	inner join TKT_SyncData A  WITH (NOLOCK) on FC.DataKey = TKT_DataKey and FC.ContainerKey = TKT_ContainerKey and A.SiteID = @SiteId
	inner join TKT_RouteDatanew RD  WITH (NOLOCK) on  A.TMS_OrderDetailKey = RD.orderDetailKey and RD.LocationType = SL.facilityCode
	inner join Routes RT  WITH (NOLOCK) on RD.RouteKey = RT.Routekey and isnull(RT.IsDryRun,0) = 0
	where isnull(SL.TMS_RouteKey,0) <> RD.RouteKey OR isnull(SL.TMS_LegKey,0) <> RD.TMS_legKey  and A.SiteID = @SiteId
		and A.TKT_DataKey = @DataKey and RD.LocationType = SL.facilityCode

	
	

	select 'TKT_SyncData', * from TKT_SyncData where tkt_datakey = @DataKey AND SiteID = 'Robinson'
	select 'TMS_Integration_Header', * from TMS_Integration_Header where datakey = @DataKey AND SiteID = 'Robinson'
	select 'TMS_Integration_Container', * from TMS_Integration_Container where datakey = @DataKey AND SiteID = 'Robinson'
	select 'TMS_Integration_Routes', * from TMS_Integration_Routes where datakey = @DataKey AND SiteID = 'Robinson'

	select 'Robinson_Header', * from Integration_JCB.dbo.Robinson_Header where DataKey = @DataKey
	select 'Robinson_ContainerList',* from Integration_JCB.dbo.Robinson_ContainerList where datakey = @DataKey

	select 'Robinson_StopList', b.* from Integration_JCB.dbo.Robinson_ContainerList A
	inner join Integration_JCB.dbo.Robinson_StopList B on A.ContainerKey = B.ContainerKey
	where A.DataKey = @DataKey

	drop table #Temp_Robinson

END
