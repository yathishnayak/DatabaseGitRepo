CREATE PROCEDURE [dbo].[Update_ReleaseContainersToDispatch]
@RouteKey				INT,
@OutPut					BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON
	SET FMTONLY OFF
	declare @OrderDetailKey int = 0
	select @OrderDetailKey = OrderDetailKey from Routes where RouteKey = @RouteKey

	UPDATE dbo.[Routes] 
	SET [Status] = ( SELECT [Status] FROM RouteStatus WHERE [Description]= 'Delivery Pending' )
	WHERE RouteKey= @RouteKey ;

	exec UpdateContainerStatus @OrderDetailKey

	SET @OutPut=1
END
