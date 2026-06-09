CREATE PROCEDURE [dbo].[Update_DispatchStatus]
@Orderdetailkey			INT,
@StatusKey				SMALLINT,
@OutPut					BIT OUTPUT
AS
BEGIN	
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	UPDATE dbo.OrderDetail 
	SET  [Status] = @StatusKey,  StatusDate = GETDATE()
	WHERE OrderDetailkey= @Orderdetailkey ;

	exec UpdateContainerStatus @OrderDetailKey

	SET @OutPut=1;
END
