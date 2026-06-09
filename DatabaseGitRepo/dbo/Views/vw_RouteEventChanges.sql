
CREATE  VIEW [dbo].[vw_RouteEventChanges] -- SELECT * FROM vw_RouteEventChanges
AS
WITH TMPData AS (
    SELECT	DISTINCT  RouteKey,'Actual Departure' AS EventType,ActualDeparture AS EventDate,
			LastUpdateDate
    FROM	Routes_Log WITH (NOLOCK)
    WHERE	ActualDeparture IS NOT NULL
    UNION ALL
    SELECT	DISTINCT  RouteKey,'Actual Arrival' AS EventType,ActualArrival AS EventDate,
			LastUpdateDate
    FROM	Routes_Log WITH (NOLOCK)
    WHERE	ActualArrival IS NOT NULL
)

SELECT		RouteKey,EventType,EventDate,LastUpdateDate
FROM		(SELECT		RouteKey,EventType,EventDate,LastUpdateDate,
						LAG(EventDate) OVER (PARTITION BY RouteKey, EventType ORDER BY LastUpdateDate,EventDate) AS PrevEventDate
			FROM		TMPData) A
WHERE		EventDate <> ISNULL(PrevEventDate, '1900-01-01');
