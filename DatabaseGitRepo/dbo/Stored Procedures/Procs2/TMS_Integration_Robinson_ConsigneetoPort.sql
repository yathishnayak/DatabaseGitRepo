CREATE proc [dbo].[TMS_Integration_Robinson_ConsigneetoPort] -- TMS_Integration_Robinson_ConsigneetoPort 3
(
	 @DataKey	int = 16084
)
as
BEGIN
	select distinct RT.Routekey, Th.DataKey, OT.OrderType, RT.LegKey, L.FromLocation, L.ToLocation, RT.SourceAddrKey, RT.DestinationAddrKey, OH.orderkey, OH.OrderNo
	into #TempPortToConsignee
	from Routes RT
	inner join OrderHeader OH on rt.OrderKey = OH.OrderKey
	inner join OrderType OT on OH.OrderTypeKey = OT.OrderTypeKey
	inner join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey
	inner join Leg L on RT.LegKey = L.LegKey and L.FromLocation in ('Consignee','Customer','Shipper')and L.ToLocation   = 'Port' 
	where SiteID = 'Robinson' and TH.DataKey =  @DataKey

	select * from #TempPortToConsignee

	if((select count(1) from #TempPortToConsignee) > 0)
	Begin
		delete from TMS_Integration_Routes where DataKey = @DataKey
	End

	-- From Location update
	insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey, StopType)
	select distinct TRC.SiteID, A.DataKey, TRC.ContainerKey, SL.StopKey, A.RouteKey, A.LegKey, SL.facilityCode
	from #TempPortToConsignee A
	inner join TMS_Integration_Container TRC on A.DataKey = TRC.DataKey
	inner join Integration_JCB.dbo.Robinson_StopList SL on TRC.ContainerKey = SL.ContainerKey -- and TRT.StopKey = SL.StopKey
	where A.FromLocation  in ('Consignee','Customer','Shipper')  and SL.facilityCode = 'SF' --and (a.LegKey <> TRT.TMS_LegKey OR a.RouteKey <> TRT.TMS_RouteKey)
		and A.DataKey =  @DataKey AND SiteID = 'Robinson'

	Update SL set TMS_LegKey = A.LegKey, 
					TMS_RouteKey = A.RouteKey,
					TMS_SourceAddrKey = A.SourceAddrKey,
					TMS_DestinationAddrKey = A.DestinationAddrKey
	--select distinct A.LegKey, SL.TMS_LegKey, A.RouteKey, SL.TMS_RouteKey , SL.ContainerKey, A.Orderkey, A.OrderNo, A.DataKey
	from #TempPortToConsignee A
	inner join TMS_Integration_Routes TRT on A.DataKey = TRT.DataKey 
	inner join Integration_JCB.dbo.Robinson_StopList SL on TRT.ContainerKey = SL.ContainerKey  and TRT.StopKey = SL.StopKey
	where A.FromLocation in ('Consignee','Customer','Shipper') and SL.facilityCode = 'SF' and (a.LegKey <> SL.TMS_LegKey OR a.RouteKey <> SL.TMS_RouteKey)
	and A.DataKey = @DataKey AND  SiteID = 'Robinson'

	-- To Location update

	insert into TMS_Integration_Routes (SiteID, DataKey, ContainerKey, StopKey, TMS_RouteKey, TMS_LegKey, StopType)
	select distinct TRC.SiteID, A.DataKey, TRC.ContainerKey, SL.StopKey, A.RouteKey, A.LegKey, SL.facilityCode
	from #TempPortToConsignee A
	inner join TMS_Integration_Container TRC on A.DataKey = TRC.DataKey
	inner join Integration_JCB.dbo.Robinson_StopList SL on TRC.ContainerKey = SL.ContainerKey -- and TRT.StopKey = SL.StopKey
	where A.ToLocation  = 'PORT'  and SL.facilityCode IN  ('ST','RD') --and (a.LegKey <> TRT.TMS_LegKey OR a.RouteKey <> TRT.TMS_RouteKey)
		and A.DataKey =  @DataKey AND SiteID = 'Robinson'

	Update SL set TMS_LegKey = A.LegKey, 
					TMS_RouteKey = A.RouteKey,
					TMS_DestinationAddrKey = A.DestinationAddrKey,
					TMS_SourceAddrKey = A.SourceAddrKey
	--select distinct A.LegKey, SL.TMS_LegKey, A.RouteKey, SL.TMS_RouteKey , SL.ContainerKey, A.Orderkey, A.OrderNo, A.DataKey
	from #TempPortToConsignee A
	inner join TMS_Integration_Routes TRT on A.DataKey = TRT.DataKey 
	inner join Integration_JCB.dbo.Robinson_StopList SL on TRT.ContainerKey = SL.ContainerKey  and TRT.StopKey = SL.StopKey
	where A.ToLocation  = 'PORT'  and SL.facilityCode IN  ('ST','RD') --and (a.LegKey <> SL.TMS_LegKey OR a.RouteKey <> SL.TMS_RouteKey)
	and A.DataKey = @DataKey AND SiteID = 'Robinson'

	
end
