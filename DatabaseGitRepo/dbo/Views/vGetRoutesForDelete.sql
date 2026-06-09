CREATE VIEW [dbo].[vGetRoutesForDelete]
AS
	SELECT od.containerno,od.OrderDetailKey,rt.RouteKey,L.LegID 
	FROM Routes RT WITH (NOLOCK)
	LEFT JOIN OrderDetailStops ODSA WITH (NOLOCK) ON RT.FromODStopKey=ODSA.OrderDetailStopKey
	LEFT JOIN OrderDetailStops ODSB WITH (NOLOCK) ON RT.ToODStopKey=ODSB.OrderDetailStopKey
	INNER JOIN OrderDetail OD WITH (NOLOCK) on od.OrderDetailKey=rt.OrderDetailKey
	INNER JOIN LEG L WITH (NOLOCK) ON L.LegKey=RT.LegKey
	WHERE (ODSA.StopTypeKey IS NULL OR ODSB.StopTypeKey IS NULL)
	AND RT.CreateDate>CONVERT(DATE,'2025-06-17' )
	AND ISNULL(IsManual,0)=0 AND ISNULL(RT.IsDryRun,0)=0

