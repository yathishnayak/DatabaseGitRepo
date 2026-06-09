CREATE PROCEDURE [dbo].[Get_OrderRoutesByOrderKey]
/*
fn_get_all_route_fordo
*/
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT
		  OrderDetailKey  ,
		  RT.LegNo ,
		  LT.LegTypeID AS LegType ,
		  SourceAddrKey  ,
		  DestinationAddrKey ,
		  EstimatedDistanceinMiles ,
		  EstimatedTravelTime ,
		  [Status] ,
		  Driverkey ,
		  RT.DeliveryDateFrom ScheduledArrival ,
		  RT.PickupDateFrom AS ScheduledDeparture,
		  OdometerAtSource,
		  ActualArrival,
		  ActualDeparture,
		  OdometerAtDestination
	  FROM dbo.Routes RT 
		LEFT JOIN  Leg LG ON LG.LegKey=RT.LegKey
		LEFT JOIN LegType LT ON LT.LegtypeKey=LG.LegTypeKey
	  WHERE OrderKey = @OrderKey
END
