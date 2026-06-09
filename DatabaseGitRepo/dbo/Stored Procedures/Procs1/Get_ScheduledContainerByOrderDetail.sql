CREATE PROCEDURE [dbo].[Get_ScheduledContainerByOrderDetail]
/*
dbo.fn_get_scheduledcontainer
*/
@OrderDetailKey INT
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 
		od.OrderDetailkey, 
		od.RouteKey,od.ApptDateFrom, od.ApptDateTo, 
	    CMS.[Description] AS SchedulerNotes,
		od.LastFreeDay,
		LT.LegTypeID AS LegType,
		RT.DeliveryDateFrom AS ScheduledArrival, 
		RT.PickupDateFrom AS ScheduledDeparture,
		CM.[Description] AS DriverNotes
	FROM dbo.OrderDetail od 	
		LEFT JOIN dbo.routes RT ON RT.RouteKey = od.RouteKey
		LEFT JOIN Leg L ON L.LegKey=RT.LegKey
		LEFT JOIN LegType LT ON LT.LegtypeKey=L.LegTypeKey
		LEFT JOIN SchedulerDriverComment SD ON SD.RouteKey=RT.RouteKey
		LEFT JOIN Comment CM ON CM.CommentKey=SD.Commentkey
		LEFT JOIN SchedulerComment SC ON SC.RouteKey=RT.RouteKey
		LEFT JOIN Comment CMS ON CMS.CommentKey=SC.Commentkey
	WHERE  od.OrderDetailkey = @OrderDetailKey	
END
