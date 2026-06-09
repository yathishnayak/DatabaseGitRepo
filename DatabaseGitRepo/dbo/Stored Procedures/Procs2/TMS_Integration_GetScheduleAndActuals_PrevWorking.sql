


CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_PrevWorking] -- [TMS_Integration_GetScheduleAndActuals] 60753
(
	@TMS_OrderKey	int
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT top 1 oh.OrderKey, TH.DataKey, TH.SiteID, TH.TMS_OrderKey, TH.WorkOrdernumber, TH.WorKOrderDate, OH.status,
			ContainerData = ( select OD.OrderDetailKey, TC.ContainerKey, OD.ContainerNo, OD.status,
			STOPDATA = (
				SELECT RT.RouteKey, RT.LegKey, TR.StopKey, TR.TMS_LegKey, TR.TMS_RouteKey,
					RT.PickupDateFrom AS SchedPickup,
					RT.ScheduledArrival as SchedDelivery,
					RT.ActualDeparture as ActualPickup,
					RT.ActualArrival as ActualDelivery
				FROM Routes RT 
				inner join TMS_Integration_Routes TR on RT.RouteKey = TR.TMS_RouteKey
				inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
				WHERE RT.OrderDetailKey = OD.OrderDetailKey and TR.SiteID = TC.SiteID and TR.DataKey = TC.DataKey
				and  OD.status not in (1, 3, 4, 11) and isnull(RT.IsDryRun ,'0') ='0'
				FOR JSON PATH
			)
			from TMS_integration_Container TC
			inner join OrderDetail OD on TC.TMS_OrderDetailKey = OD.orderDetailKey 
			where TC.DataKey = TH.DataKey and TC.SiteID = TH.SiteID
			FOR JSON PATH
		)
	FROM OrderHeader OH
	inner join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey
	WHERE OH.OrderKey = @TMS_OrderKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
