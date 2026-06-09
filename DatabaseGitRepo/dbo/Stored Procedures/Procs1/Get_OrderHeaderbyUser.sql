CREATE PROCEDURE [dbo].[Get_OrderHeaderbyUser]
/*
dbo.fn_get_orders_by_user
*/
@UserKey INT=0
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT 
		o.OrderKey, o.OrderNo, o.OrderDate 
	FROM dbo.OrderHeader o
	WHERE o.CreateUserKey = @UserKey or o.LastUpdateUserKey = @UserKey
	ORDER BY o.OrderDate DESC;
END
