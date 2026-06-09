
CREATE PROCEDURE	[dbo].[CDS_GetCustomerNameNOrders] -- CDS_GetCustomerNameNOrders '2020-08-08 09:42:13.583'
(
	@FromDate		DATETIME = ''
)

AS
BEGIN
	IF(@FromDate = '')
		BEGIN
			SET @FromDate = '2010-01-01'
		END

	SELECT		*
	FROM		(SELECT		ROW_NUMBER() OVER (PARTITION BY ContainerNo  ORDER BY  ISNULL(R.chassisNo,CH.chassisNo) ) SL,  B.OrderDetailKey,A.OrderKey,ContainerNo,A.CustKey,C.CustName, CS.Description AS ContainerSize
							, ISNULL(R.chassisNo,CH.chassisNo)chassisNo, A.CreateDate				
				FROM		OrderHeader A
				INNER JOIN	OrderDetail B ON A.OrderKey = B.OrderKey
				LEFT JOIN	Routes R ON B.OrderDetailKey = R.OrderDetailKey
				LEFT JOIN	Chassis CH ON R.ChassisKey = CH.chassisKey
				INNER JOIN	Customer C ON A.CustKey = C.CustKey 
				LEFT JOIN	ContainerSize CS ON B.ContainerSizeKey = CS.ContainerSizeKey
				WHERE		A.CreateDate >= @FromDate OR A.LastUpdateDate > @FromDate) A
	WHERE		SL = 1
	ORDER BY	A.CreateDate DESC
	FOR JSON PATH
END


