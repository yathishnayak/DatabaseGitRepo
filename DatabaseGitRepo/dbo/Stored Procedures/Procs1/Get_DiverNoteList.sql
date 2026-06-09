CREATE PROCEDURE [dbo].[Get_DiverNoteList]
@RouteKey	INT=0,
@DriverKey	INT=0,
@OrderKey	INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT OD.OrderKey,OD.orderDetailKey,SC.RouteKey,C.Commentkey, C.[Description] AS HeaderComment, C.CreateDate, C.CreateUserkey 
	FROM dbo.Comment C
		INNER JOIN dbo.SchedulerDriverComment SC ON SC.Commentkey = C.commentkey 
		INNER JOIN dbo.Orderdetail OD ON OD.OrderDetailKey=SC.OrderDetailKey
		LEFT JOIN dbo.[Routes] RT ON RT.RouteKey = SC.RouteKey		
	WHERE ( @RouteKey=0 OR @RouteKey IS NULL OR SC.RouteKey = @RouteKey )
	  AND ( @DriverKey =0 OR @DriverKey IS NULL OR RT.DriverKey IS NULL)
	  AND ( @OrderKey=0 OR @OrderKey IS NULL OR OD.OrderKey= @OrderKey)
END
