

CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_ACER] -- [TMS_Integration_GetScheduleAndActuals_ACER] 92977,270
(
	@TMS_OrderKey	int,
	@DataKey		int = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	Declare @SiteID varchar(10) = 'ACER'

	SELECT top 1 oh.OrderKey, TH.DataKey, TH.SiteID, TH.TMS_OrderKey, TH.WorkOrdernumber, TH.WorKOrderDate, OH.status,
			ContainerData = ( select OD1.OrderDetailKey, TC.ContainerKey, OD1.ContainerNo, OD1.status,
			STOPDATA = (
				SELECT RT.RouteKey, RT.LegKey, TR.StopKey, TR.TMS_LegKey, TR.TMS_RouteKey,
					isnull(Isnull(RT.PickupDateTo,RT.PickupDateFrom), RT.ActualDeparture) AS SchedPickup,
					isnull(isnull(RT.DeliveryDateTo, Rt.DeliveryDateFrom),RT.ActualArrival) as SchedDelivery,
					RT.ActualDeparture as ActualPickup,
					RT.ActualArrival as ActualDelivery
				FROM Routes RT 
				inner join TMS_Integration_Routes TR on RT.RouteKey = TR.TMS_RouteKey
				inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
				WHERE RT.OrderDetailKey = OD1.OrderDetailKey and TR.SiteID = TC.SiteID and TR.DataKey = TC.DataKey
				and  OD.status not in (1, 3, 4, 11) and isnull(RT.IsDryRun ,'0') ='0'
				FOR JSON PATH
			)
			from TMS_integration_Container TC
			inner join OrderDetail OD1 on TC.TMS_OrderDetailKey = OD1.orderDetailKey 
			where TC.DataKey = TH.DataKey and TC.SiteID = TH.SiteID
			FOR JSON PATH
		)
	FROM OrderHeader OH
	inner join TMS_Integration_Header TH on OH.OrderKey = TH.TMS_OrderKey
	WHERE OH.OrderKey = @TMS_OrderKey and TH.SiteID = @SiteID AND TH.DataKey = @DataKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END
