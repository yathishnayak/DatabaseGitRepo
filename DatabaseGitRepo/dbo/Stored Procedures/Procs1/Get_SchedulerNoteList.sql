CREATE PROCEDURE [dbo].[Get_SchedulerNoteList]
@RouteKey INT=0,
@OrderKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT SC.RouteKey,C.Commentkey, C.[Description] AS HeaderComment, C.CreateDate, C.CreateUserkey 
	FROM dbo.Comment C
		INNER JOIN dbo.SchedulerComment SC ON SC.Commentkey = C.commentkey 
		INNER JOIN dbo.Orderdetail OD ON OD.OrderDetailKey=SC.OrderDetailKey
	WHERE   (@RouteKey=0 OR @RouteKey IS NULL OR SC.RouteKey = @RouteKey)
		AND (@OrderKey=0 OR @OrderKey IS NULL OR OD.OrderKey=@OrderKey)
END
