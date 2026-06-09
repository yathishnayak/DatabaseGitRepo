CREATE PROCEDURE [dbo].[MelroseIntegrate_GetRouteDateUpdates]

AS

BEGIN
	SELECT		MAX(Datakey)Datakey,RouteKey,IsRouteRecordUpdate,ScheduleActual,IsArrival 
	FROM		(SELECT Datakey,RouteKey,ISNULL(IsRouteRecordUpdate,0)IsRouteRecordUpdate
				, CASE WHEN UpdateColumnName LIKE '%Schedule%' THEN 'S' ELSE 'A' END ScheduleActual
				, CAST(CASE WHEN UpdateColumnName LIKE '%Arrival%' THEN 1 ELSE 0 END AS BIT) IsArrival
				FROM MelroseIntegrate_RouteDateUpdates 
				WHERE ISNULL(IsDataSenttoMelrose,0) = 0 ) A
	GROUP BY	RouteKey,IsRouteRecordUpdate,ScheduleActual,IsArrival 
	ORDER BY	Datakey
END