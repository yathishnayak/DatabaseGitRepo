CREATE PROCEDURE [dbo].[Get_OrdersToGenerateInvoice]
/*
dbo.fn_get_orderstogenerateinvoice
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @OrderHeaderStatus SMALLINT
	DECLARE @OrderDetailStatus SMALLINT

	SET @OrderHeaderStatus= ( SELECT [Status] FROM orderstatus WHERE Description='In Progress' )
	SET @OrderDetailStatus= ( SELECT [Status] FROM orderstatus WHERE Description='Completed' )

	SELECT
		oh.OrderKey,oh.OrderNo,oh.OrderDate
	FROM
		dbo.OrderHeader oh
		LEFT JOIN dbo.OrderDetail od  ON oh.orderkey = od.orderkey
		--LEFT JOIN dbo.orderdetailcomments oc ON oc.orderdetailkey = od.orderdetailkey
		--LEFT JOIN dbo.comment c					 ON c.commentkey = oc.commentkey
		LEFT JOIN dbo.OrderStatus osh		 ON osh.[Status]= oh.[Status]
		LEFT JOIN dbo.OrderStatus osd		 ON osd.[Status]= od.[Status]
		--LEFT JOIN dbo.containersize cs		 ON cs.containersize = od.containersize
	WHERE osh.[Status] = @OrderHeaderStatus AND osd.[Status] = @OrderDetailStatus
	ORDER BY oh.OrderKey	
END
