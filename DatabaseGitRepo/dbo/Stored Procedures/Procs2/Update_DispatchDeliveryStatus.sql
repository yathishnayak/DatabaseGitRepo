CREATE PROCEDURE [dbo].[Update_DispatchDeliveryStatus]
/*
 dbo.fn_update_status_dispatch_delivery
*/
@Orderdetailkey			INT,
@StatusKey				SMALLINT,
@OutPut					BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	UPDATE dbo.OrderDetail 
	SET  Status = @StatusKey,  StatusDate = GETDATE()
	WHERE OrderDetailkey= @Orderdetailkey ;

	exec UpdateContainerStatus @OrderDetailKey

	SET @OutPut=1
END
