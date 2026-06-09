
CREATE Proc [dbo].[Update_RouteLegNoOrder] -- Update_RouteLegNoOrder 15747
(
	@OrderDetailKey		int = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @TODATE DATETIME = CONVERT(DATE,'2050-12-31')

	UPDATE RTN SET LEGNO = B.ROWNUM
	FROM ROUTES RTN
	INNER JOIN (SELECT TOP 1000 RT.RouteKey, RT.ActualArrival, ROW_NUMBER() OVER(ORDER BY ISNULL(RT.ActualDeparture,@TODATE)) AS ROWNUM
	FROM ROUTES RT WITH (NOLOCK)
	WHERE OrderDetailKey = @OrderDetailKey
	ORDER BY ISNULL(RT.ActualDeparture,@TODATE), RT.LegNo, RT.RouteKey) B ON RTN.RouteKey = B.RouteKey
	WHERE RTN.OrderDetailKey = @OrderDetailKey
END
