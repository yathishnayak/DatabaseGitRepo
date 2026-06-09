

CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_Robinson_Prev_16Jul2024] -- TMS_Integration_GetScheduleAndActuals_Robinson 72606, 8
(
	@TMS_OrderKey	int,
	@DataKey		int
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	declare @OrderType varchar(20) = '',
			@SiteID	varchar(10) = 'Robinson',
			@Custkey int = 0

	select @OrderType = OT.OrderType, @Custkey = CustKey
	from OrderHeader OH
	inner join OrderType OT on OH.OrderTypeKey = OT.OrderTypeKey
	where OrderKey = @TMS_OrderKey

	select * into #TempData from TempPickupDelivery where 1=0
	
	if(@OrderType = 'Import')
	Begin
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) as StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey,  DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID, 'FROM' as StopType,
			isnull(isnull(RT.PickupDateTo, RT.PickupDateFrom),RT.ActualDeparture) as SchedPickup, 
			RT.ActualDeparture as ActualPickup,
			null as SchedDelivery, null as ActualDelivery
			from Routes_DateTracker DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID =@SiteID
				AND TR.TMS_RouteKey = RT.RouteKey 
			inner join Integration_JCB.dbo.Robinson_StopList SL on TR.StopKey = SL.StopKey AND TR.Stoptype = SL.FacilityCode
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0 AND TR.STopType IN ('SF','RD')
			and (L.FromLocation = 'PORT' )
			and SD.SiteID = @SiteID --and SL.stopNumber = 1
			and OD.Orderkey = @TMS_OrderKey and TR.DataKey = @DataKey -- AND SL.StopReferenceNumber = 1
		) A
		
		-- SELECT * FROM #TempData

		declare @CntImp int = 0
		select @CntImp = count(1) from #TempData

		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, @CntImp + ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) AS StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID,
			'TO' as StopType, null as SchedPickup, null as ActualPickup,
			isnull(isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom),  RT.ActualArrival) as SchedDelivery, 
			RT.ActualArrival as ActualDelivery
			from Routes_DateTracker DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID
				AND TR.TMS_RouteKey = RT.RouteKey 
			inner join Integration_JCB.dbo.Robinson_StopList SL on TR.StopKey = SL.StopKey AND TR.Stoptype = SL.FacilityCode
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0 AND TR.STopType IN ('ST','RT','RD')
			and ( L.ToLocation = 'Consignee' OR  L.ToLocation = 'Customer' 
				OR L.ToLocation = 'PORT')
			and SD.SiteID = @SiteID --and SL.stopNumber in (2,3)
			and OD.OrderKey = @TMS_OrderKey and TR.DataKey = @DataKey--  AND SL.StopReferenceNumber = 1
		) A
	END

	if(@OrderType = 'Export')
	Begin
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) as StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID, 'FROM' as StopType,
			isnull(isnull(RT.PickupDateTo,RT.PickupDateFrom),RT.ActualDeparture) as SchedPickup, 
			RT.ActualDeparture as ActualPickup,
			null as SchedDelivery, null as ActualDelivery
			from Routes_DateTracker DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID 
				AND TR.TMS_RouteKey = RT.RouteKey
			inner join Integration_JCB.dbo.Robinson_StopList SL on TR.StopKey = SL.StopKey AND TR.Stoptype = SL.FacilityCode
			where OT.OrderType = 'EXPORT' and isnull(RT.IsDryRun ,0) = 0  AND TR.STopType IN ('SF')
			and (L.FromLocation in ('Shipper','Consignee','Customer') )
			and SD.SiteID = @SiteID --and sl.stopNumber = 1
			and OD.Orderkey = @TMS_OrderKey  and TR.DataKey = @DataKey
		) A
	
	

		declare @CntExp int = 0
		select @cntExp = count(1) from #TempData

		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery, StopNum)
		select *, @CntExp + ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) AS StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID,
			'TO' as StopType,  null as SchedPickup, null as ActualPickup,
			isnull(isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom),RT.ActualArrival) as SchedDelivery, 
			RT.ActualArrival as ActualDelivery
			from Routes_DateTracker DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID
				AND TR.TMS_RouteKey = RT.RouteKey
			inner join Integration_JCB.dbo.Robinson_StopList SL on TR.StopKey = SL.StopKey AND TR.Stoptype = SL.FacilityCode
			where OT.OrderType = 'Export' and isnull(RT.IsDryRun ,0) = 0   AND TR.STopType IN ('ST','RT')
			and (  L.ToLocation = 'PORT')
			and SD.SiteID = @SiteID --and SL.stopNumber =2
			and OD.OrderKey = @TMS_OrderKey  and TR.DataKey = @DataKey
		) A
	End
	
	-- select * from #TempData
	
	SELECT top 1 OrderKey, DataKey, SiteID, TMS_OrderKey, WorkOrdernumber, WorKOrderDate, status,
			ContainerData = ( select OD.OrderDetailKey, TC.ContainerKey, OD.ContainerNo, OD.status,
			STOPDATA = (
				SELECT  RouteKey, LegKey, StopKey, TMS_LegKey, TMS_RouteKey,
					SchedPickup, SchedDelivery, ActualPickup, ActualDelivery, StopNum
				FROM #TempData A
				FOR JSON PATH
				)
				from TMS_integration_Container TC
				inner join OrderDetail OD on TC.TMS_OrderDetailKey = OD.orderDetailKey 
				where TC.DataKey = TH.DataKey and TC.SiteID = TH.SiteID
				FOR JSON PATH
			)
	FROM OrderHeader OH
	inner join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey
	WHERE OH.OrderKey = @TMS_OrderKey and TH.SiteID = @SiteID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END

