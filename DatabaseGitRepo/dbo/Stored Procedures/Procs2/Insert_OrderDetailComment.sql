CREATE PROCEDURE [dbo].[Insert_OrderDetailComment]

@OrderdetailKey INT,
@CommentKey INT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO dbo.OrderDetailComments(OrderDetailKey,Commentkey)
	VALUES (@OrderdetailKey, @CommentKey);	

	--exec [Container_TypeInsert] @OrderdetailKey, @CommentKey
END
