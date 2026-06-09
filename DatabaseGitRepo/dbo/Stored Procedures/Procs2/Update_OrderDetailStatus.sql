CREATE PROCEDURE [dbo].[Update_OrderDetailStatus]
/*
Order/Container Screen
*/
@Orderkey		INT,
@Orderdetailkey INT,
@StatusKey		SMALLINT,
@UpdateUserKey	INT,
@OutPut			BIT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	SET @OutPut=0;

	UPDATE dbo.OrderDetail 
	SET [Status]=@StatusKey , StatusDate = GETDATE(),UpdateUserKey=@UpdateUserKey 
	WHERE OrderDetailkey= @Orderdetailkey and OrderKey= @Orderkey;

	exec UpdateContainerStatus @OrderDetailKey

	SET @OutPut=1;
END
