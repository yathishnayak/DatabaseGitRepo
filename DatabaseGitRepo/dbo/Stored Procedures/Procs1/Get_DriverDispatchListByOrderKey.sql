

CREATE PROCEDURE [dbo].[Get_DriverDispatchListByOrderKey] 
@OrderKey		 INT= 0
AS
BEGIN
	---**** NOTE: STATUS KEY 0= ALL, 1 = PENDING TO APPROVE, 2 = COMPLETED, 9 = PENDING TO CREATE VOUCHER
	SET NOCOUNT ON
	SET FMTONLY OFF

	SELECT OH.OrderKey,od.OrderDetailKey,oh.OrderNo,od.ContainerNo,RT.ActualArrival AS ActualDeparture,d.DriverID,d.FirstName,d.LastName,
					ISNULL(VH.IsPaymentApproved,0)AS IsPaymentApproved, 
					CASE WHEN ISNULL(VH.IsPaymentApproved,0)=1 THEN CAST(2 AS SMALLINT)  ELSE ISNULL(VH.[Statuskey],9) END AS StatusKey
							,VH.VoucherAmount,RT.RouteKey,RT.DestinationAddrKey,VH.VoucherKey,VH.VoucherNo,VH.VoucherDate
							,L.Instruction AS WorkFlow, LG.LegID as LegTypeID,DST.City,isnull(CDC.DocumentCount,0) as DocumentCount
	FROM dbo.[routes] RT 
		INNER JOIN dbo.OrderDetail od	ON RT.OrderDetailKey = od.OrderDetailkey
		INNER JOIN dbo.OrderHeader oh	ON oh.OrderKey = od.OrderKey
		INNER JOIN dbo.Leg LG			ON LG.LegKey = RT.LegKey
		INNER JOIN dbo.LegType L		ON L.LegtypeKey = LG.LegTypeKey
		INNER JOIN dbo.Driver d			ON d.DriverKey = RT.DriverKey
		INNER JOIN dbo.RouteStatus RTS	ON RTS.[Status]=RT.[Status]
		LEFT JOIN RouteVouchers RV		ON RV.RouteKey=RT.RouteKey
		LEFT JOIN VoucherHeader VH		ON VH.VoucherKey=RV.VoucherKey
		LEFT JOIN dbo.VoucherStatus VS	ON VS.[StatusKey]=VH.[StatusKey]
		LEFT JOIN dbo.[Address] DST ON DST.AddrKey=RT.DestinationAddrKey
		LEFT JOIN ContainerDocumentCount CDC ON OD.OrderDetailKey = CDC.OrderDetailKey
		where OH.OrderKey=@OrderKey 

END
