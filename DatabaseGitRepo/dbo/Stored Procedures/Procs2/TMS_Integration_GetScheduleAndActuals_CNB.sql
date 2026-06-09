

CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_CNB] -- TMS_Integration_GetScheduleAndActuals_CNB 193718, 3761
(
	@TMS_OrderKey	int,
	@DataKey		int
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	
	declare @OrderType varchar(20) = '',
			@SiteID	varchar(10) = 'CNB',
			@Custkey int = 0

	select @OrderType = OT.OrderType, @Custkey = CustKey
	from OrderHeader OH
	inner join OrderType OT on OH.OrderTypeKey = OT.OrderTypeKey
	where OrderKey = @TMS_OrderKey

	DECLARE @JsonResult NVARCHAR(MAX) = ''

	SELECT		*
	INTO		#OrderDetail
	FROM		OrderDetail 
	WHERE		Orderkey = @TMS_OrderKey AND LEFT(LTRIM(RTRIM(ContainerNo)),4) NOT IN ('UUUU','JFLT')

	IF((SELECT COUNT(*) FROM #OrderDetail) = 0)
		BEGIN
			SELECT NULL AS JsonResult
			RETURN
		END

	select * into #TempData from TempPickupDelivery where 1=0

	ALTER TABLE #TempData
	ADD LocationType VARCHAR(20)
	
	if(@OrderType = 'Import')
	Begin
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery,LocationType, StopNum)
		select *, ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) as StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey,  DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID, 'FROM' as StopType,
			isnull(isnull(RT.PickupDateTo, RT.PickupDateFrom),RT.ActualDeparture) as SchedPickup, 
			RT.ActualDeparture as ActualPickup,
			null as SchedDelivery, null as ActualDelivery, DT.LocationType
			from TKT_RouteDataNew DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join #OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID =@SiteID
				AND TR.TMS_RouteKey = RT.RouteKey 
			inner join Integration_JCB.dbo.CNB_StopList SL on TR.StopKey = SL.StopKey and Dt.LocationType = SL.facilityCode
			where  OT.OrderType = 'IMPORT' and isnull(RT.IsDryRun ,0) = 0 and DT.LocationType IN ('SF','RP')
			and SD.SiteID = @SiteID --and SL.stopNumber = 1
			and OD.Orderkey = @TMS_OrderKey and TR.DataKey = @DataKey
		) A

		declare @CntImp int = 0
		select @CntImp = count(1) from #TempData
	
		insert into #TempData (OrderKey, StopKey, OrderDetailKey, TMS_RouteKey, OrderTypeKey, OrderType, 
			FromLocation, TMS_LegKey, RouteKey, ToLocation, LegNo, IsEmpty, LegKey, SiteID, StopType, 
			SchedPickup, ActualPickup, SchedDelivery, ActualDelivery,LocationType, StopNum)
		select *, @CntImp + ROW_NUMBER() over (partition by OrderDetailKey Order by OrderDetailKey, legNo  ) AS StopNum
		from (
			select distinct OD.OrderKey, TR.StopKey, RT.OrderDetailKey, DT.RouteKey as TMS_RouteKey, OH.OrderTypeKey, 
			OT.OrderType, L.FromLocation, RT.LegKey as TMS_LegKey, DT.RouteKey ,
			L.ToLocation, RT.LegNo, RT.IsEmpty , RT.LegKey, SD.SiteID,
			'TO' as StopType, null as SchedPickup, null as ActualPickup,
			isnull(isnull(RT.DeliveryDateTo,RT.DeliveryDateFrom),  RT.ActualArrival) as SchedDelivery, 
			RT.ActualArrival as ActualDelivery, DT.LocationType
			from TKT_RouteDataNew DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join #OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID
				AND TR.TMS_RouteKey = RT.RouteKey 
			inner join Integration_JCB.dbo.CNB_StopList SL on TR.StopKey = SL.StopKey and Dt.LocationType = SL.facilityCode
			where OT.OrderType = 'Import' and isnull(RT.IsDryRun ,0) = 0
				and DT.LocationType in ('ST','RT','AF','AT')
			and SD.SiteID = @SiteID --and SL.stopNumber in (2,3)
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
			from TKT_RouteDataNew DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join #OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID 
				AND TR.TMS_RouteKey = RT.RouteKey
			inner join Integration_JCB.dbo.CNB_StopList SL on TR.StopKey = SL.StopKey and DT.LocationType = SL.facilityCode
			where OT.OrderType = 'EXPORT' and isnull(RT.IsDryRun ,0) = 0
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
			from TKT_RouteDataNew DT
			inner join Routes RT on DT.RouteKey = RT.RouteKey
			inner join #OrderDetail OD on Rt.OrderDetailKey = OD.OrderDetailKey
			inner join TKT_SyncData SD on OD.OrderDetailKey = SD.TMS_OrderDetailKey
			inner join OrderHeader OH on SD.TMS_OrderKey = OH.OrderKey
			inner join OrderType OT  on OH.OrderTypeKey = OT.OrderTypeKey
			inner join Leg L on RT.LegKey = L.LegKey
			INNER JOIN TMS_Integration_Routes TR ON SD.TKT_DataKey = TR.DataKey AND TR.SiteID = @SiteID
				AND TR.TMS_RouteKey = RT.RouteKey
			inner join Integration_JCB.dbo.CNB_StopList SL on TR.StopKey = SL.StopKey and Dt.LocationType = SL.facilityCode
			where OT.OrderType = 'Export' and isnull(RT.IsDryRun ,0) = 0
				and DT.LocationType in ('ST','RT')
			and SD.SiteID = @SiteID --and SL.stopNumber =2
			and OD.OrderKey = @TMS_OrderKey  and TR.DataKey = @DataKey
		) A

	End
	
	--select * from #TempData
	SET @JsonResult = (
	SELECT top 1 OrderKey, DataKey, SiteID, TMS_OrderKey, WorkOrdernumber, WorKOrderDate, status,
			ContainerData = ( select OD.OrderDetailKey, TC.ContainerKey, OD.ContainerNo, OD.status,
			STOPDATA = (
				SELECT  RouteKey, LegKey, StopKey, TMS_LegKey, TMS_RouteKey,
					SchedPickup, SchedDelivery, ActualPickup, ActualDelivery, StopNum, LocationType
				FROM #TempData A
				FOR JSON PATH
				)
				from TMS_integration_Container TC
				inner join #OrderDetail OD on TC.TMS_OrderDetailKey = OD.orderDetailKey 
				where TC.DataKey = TH.DataKey and TC.SiteID = TH.SiteID
				FOR JSON PATH
			)
	FROM OrderHeader OH
	inner join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey
	WHERE OH.OrderKey = @TMS_OrderKey and TH.SiteID = @SiteID
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

	SELECT @JsonResult AS JsonResult

END

