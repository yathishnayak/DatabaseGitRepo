




CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_KHNN_PRev_20240501] -- TMS_Integration_GetScheduleAndActuals_KHNN 65672,12
(
	@TMS_OrderKey	INT,
	@DataKey		INT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	declare @OrderType varchar(20) = '',
			@SiteID	varchar(10) = 'KHNN'

	select SiteId, CustKey into #CustKeys from Integration_JCB.dbo.TMS_Integration_CustomerMapping where SiteID =@SiteID
	
	--select * from #CustKeys

	select @OrderType = OT.OrderType
	from OrderHeader OH
	inner join OrderType OT on OH.OrderTypeKey = OT.OrderTypeKey
	inner join #CustKeys C on OH.CustKey = C.custkey
	where OrderKey = @TMS_OrderKey
	print @OrderType

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
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0
			and (L.FromLocation = 'PORT' )
			and SD.SiteID = @SiteID
			and OD.Orderkey = @TMS_OrderKey and TR.DataKey = @DataKey
		) A
	
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
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0
			and ( L.ToLocation = 'Consignee' OR  L.ToLocation = 'Customer' 
				OR L.ToLocation = 'PORT')
			and SD.SiteID = @SiteID
			and OD.OrderKey = @TMS_OrderKey and TR.DataKey = @DataKey
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
			where OT.OrderType = 'EXPORT' and isnull(RT.IsDryRun ,0) = 0
			and (L.FromLocation in ('Shipper','Consignee','Customer') )
			and SD.SiteID = @SiteID
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
			where OT.OrderType = 'Export' and isnull(RT.IsDryRun ,0) = 0
			and (  L.ToLocation = 'PORT')
			and SD.SiteID = @SiteID
			and OD.OrderKey = @TMS_OrderKey  and TR.DataKey = @DataKey
		) A
	End
	
	--select * from #TempData
	
	SELECT top 1 OrderKey, DataKey, TH.SiteID, TMS_OrderKey, WorkOrdernumber, WorKOrderDate, status,
			ContainerData = ( select OD.OrderDetailKey, TC.ContainerKey, OD.ContainerNo, OD.status,
			STOPDATA = (
				SELECT RouteKey, LegKey, StopKey, TMS_LegKey, TMS_RouteKey,
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
	inner join #CustKeys C on OH.CustKey = C.CustKey
	WHERE OH.OrderKey = @TMS_OrderKey and TH.SiteID = @SiteID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
