CREATE PROCEDURE [dbo].[Get_OrderStatus]
/*
dbo.fn_get_orderstatus
*/
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT st.[Status], st.Description
	FROM dbo.OrderStatus st 
	WHERE st.isactive = 1 
	ORDER BY [Status] asc;
END
