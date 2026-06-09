
create PROCEDURE [dbo].[Get_CustomerInfoForMail]
(
	@OrderDetailKey  INT
)
AS
BEGIN
	SELECT C.CustName, C.CustID, A.Email, OH.OrderNo,OD.ContainerNo FROM OrderDetail OD
	LEFT JOIN OrderHeader OH WITH (NOLOCK) ON OD.OrderKey=OH.OrderKey
	LEFT JOIN Customer C WITH (NOLOCK) ON C.CustKey=OH.CustKey
	LEFT JOIN Address A WITH (NOLOCK) ON A.AddrKey=C.AddrKey
	WHERE OrderDetailKey=@OrderDetailKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END
