CREATE PROCEDURE [dbo].[Delete_OrderContainer] 
@OrderDetailKey INT,
@UserKey		INT,
@OutPut			VARCHAR(200) OUTPUT
AS
BEGIN
		SET NOCOUNT ON;
		SET FMTONLY OFF;

		SET @OutPut=0;

		DECLARE @OrderKey INT;
	
	
		SET @OrderKey= (SELECT DISTINCT OrderKey FROM dbo.OrderDetail WHERE OrderDetailKey=@OrderDetailKey );

		IF  (	SELECT COUNT(1) 
				FROM dbo.[Routes] RT
					INNER JOIN dbo.RouteStatus RTS ON RTS.[Status]=RT.[Status]
				WHERE OrderDetailKey = @OrderDetailKey AND 
					( RTS.[Description] IN ('Leg Completed','DriverAssigned','InProgress') OR RT.ActualArrival IS NOT NULL OR ActualDeparture IS NOT NULL)
			)>0 
		BEGIN
			SET @OutPut='Dispatch InProgress for this Container'
			SELECT @OutPut
			RETURN
		END
		ELSE
		BEGIN
			SELECT CommentKey INTO  #TempCommt 
			FROM OrderDetailComments 
			WHERE OrderDetailKey=@OrderDetailKey

			DELETE FROM OrderExpense WHERE RouteKey IN ( SELECT RouteKey FROM dbo.Routes WHERE OrderDetailKey=@OrderDetailKey )
			DELETE FROM OrderDetailComments WHERE OrderDetailKey=@OrderDetailKey
			DELETE FROM dbo.Comment WHERE CommentKey IN ( SELECT CommentKey FROM #TempCommt )			
			DELETE FROM OrderDetailDocuments WHERE OrderDetailKey=@OrderDetailKey
			DELETE FROM dbo.Routes WHERE OrderDetailKey=@OrderDetailKey
			DELETE FROM dbo.OrderDetail WHERE OrderDetailKey=@OrderDetailKey

			SET @OutPut='Container Deleted'

			SELECT @OutPut
		END		
END
