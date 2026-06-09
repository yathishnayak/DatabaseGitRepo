CREATE PROCEDURE [dbo].[Insert_OrderHeaderComment]
/*
dbo.fn_insert_order_header_comment
*/
@OrderKey INT,
@CommentKey INT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	INSERT INTO dbo.OrderHeaderComments(Orderkey,Commentkey)
	VALUES (@OrderKey, @CommentKey);	
END
