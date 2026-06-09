
CREATE PROCEDURE [dbo].[GET_ContainerDriverPay]
(
	@OrderDetailKey INT = 0
)
AS
	SELECT A.OrderDetailKey,SUM(ISNULL(A.VoucherAmount,0)) DriverPay from
	(
		SELECT DISTINCT OD.OrderDetailKey,VH.VoucherKey,VoucherAmount
		FROM OrderDetail OD
		INNER JOIN Routes R WITH(NOLOCK) ON R.OrderDetailKey = OD.OrderDetailKey
		INNER JOIN VoucherDetail VD WITH(NOLOCK) ON  VD.RouteKey = R.RouteKey
		INNER JOIN VoucherHeader VH WITH(NOLOCK) ON VH.VoucherKey = VD.Voucherkey
		WHERE OD.OrderDetailKey = @OrderDetailKey
	) A
	GROUP BY A.OrderDetailKey

	--select *from OrderDetail
