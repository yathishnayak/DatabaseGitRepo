CREATE PROCEDURE [dbo].[Get_CSRInfoForMail] -- Get_CSRInfoForMail 316839
(
	@Orderdetailkey int,
	@RouteKey		INT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @BillToName VARCHAR(100)=''
	SELECT @BillToName =C.CustName FROM OrderDetail OD
	INNER JOIN OrderHeader OH ON (Oh.OrderKey=OD.OrderKey)
	INNER JOIN Customer C ON OH.CustKey=C.CustKey
	WHERE OD.OrderDetailKey=@Orderdetailkey

	SELECT DISTINCT CS.CsrName,c.CustName,c.CustID, OrderNo,ContainerNo,oh.BrokerRefNo,LT.LegTypeID,U.UserName,a.Email,@BillToName As BillToName,
	C.CSRManagerKey, CM.CsrName AS ManagerName, AM.Email as CSRManagerEmail
	FROM OrderDetail od
	LEFT JOIN OrderHeader oh WITH (NOLOCK) ON od.OrderKey= oh.OrderKey
	LEFT JOIN csr cs WITH (NOLOCK) ON cs.csrkey= oh.CsrKey
	LEFT JOIN address a WITH (NOLOCK) ON a.AddrKey =cs.AddrKey
	LEFT JOIN customer c WITH (NOLOCK) ON c.CustKey= oh.CustKey
	LEFT JOIN CSR CM WITH (NOLOCK) ON CS.CSRManagerKey = CM.CsrKey
	LEFT JOIN address AM WITH (NOLOCK) ON AM.AddrKey =CM.AddrKey
	--LEFT JOIN LegType L WITH(NOLOCK) ON L.LegtypeKey = OD.LegTypeKey
	INNER JOIN [Routes] R WITH (NOLOCK) ON R.OrderDetailKey=OD.OrderDetailKey
	INNER JOIN Leg L WITH (NOLOCK) ON L.LegKey=R.LegKey
	LEFT JOIN LegType LT WITH(NOLOCK) ON LT.LegtypeKey = L.LegTypeKey
	INNER JOIN OrderExpense E WITH(NOLOCK) ON E.RouteKey = R.RouteKey
	INNER JOIN [user] U WITH(NOLOCK) ON U.UserKey = E.CreateUserKey

	WHERE od.OrderDetailKey= @Orderdetailkey AND R.RouteKey=@RouteKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
END