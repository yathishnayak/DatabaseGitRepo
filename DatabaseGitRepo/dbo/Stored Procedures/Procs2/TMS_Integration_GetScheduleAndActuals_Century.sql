
CREATE proc [dbo].[TMS_Integration_GetScheduleAndActuals_Century] -- [TMS_Integration_GetScheduleAndActuals_Century] 232711, 7862
(
	@TMS_OrderKey	int,
	@DataKey		int = 0
)
as
BEGIN

	--INSERT INTO TempDataDelete_20250318 (DataKey,JsonText,CreatedDate)
	--SELECT @DataKey, CAST(@TMS_OrderKey AS VARCHAR), GETDATE()

	SET NOCOUNT ON
	SET FMTONLY OFF
	Declare @SiteID varchar(10) = 'Century'

	SELECT top 1 oh.OrderKey, TH.DataKey, TH.SiteID, TH.TMS_OrderKey, TH.WorkOrdernumber, TH.WorKOrderDate, OH.status,
			ContainerData = ( select OD.OrderDetailKey, TC.ContainerKey, OD.ContainerNo, OD.status,
			STOPDATA = (
				SELECT RT.RouteKey, RT.LegKey, TR.StopKey, TR.TMS_LegKey, TR.TMS_RouteKey,TR.StopType,
					isnull(Isnull(RT.PickupDateTo,RT.PickupDateFrom), RT.ActualDeparture) AS SchedPickup,
					isnull(isnull(RT.DeliveryDateTo, Rt.DeliveryDateFrom),RT.ActualArrival) as SchedDelivery,
					RT.ActualDeparture as ActualPickup,
					RT.ActualArrival as ActualDelivery,
					A.CreateDate
				FROM Routes RT 
				inner join TMS_Integration_Routes TR on RT.RouteKey = TR.TMS_RouteKey
				inner join OrderDetail OD on RT.OrderDetailKey = OD.OrderDetailKey
				LEFT JOIN	(SELECT		DISTINCT RouteKey , D.CreateDate
							FROM		ContainerLegDocuments LD
							INNER JOIN	Document D ON  LD.DocumentKey = D.DocumentKey
							WHERE		D.DocumentType IN (20,21)) A ON RT.RouteKey = A.RouteKey
				WHERE RT.OrderDetailKey = OD.OrderDetailKey and TR.SiteID = TC.SiteID and TR.DataKey = TC.DataKey
				and  OD.status not in (1, 3, 4, 11) 
				and CASE WHEN TR.StopType = 'CE' THEN 0 ELSE isnull(RT.IsDryRun ,0) END = 0
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
