
CREATE PROCEDURE [dbo].[Get_VoucherDetail] -- [Get_VoucherDetail] 159
@VoucherKey  INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	 SELECT VH.VoucherNo,VH.VoucherKey,VD.VoucherLineKey,ItemID,VD.[Description] , VD.ItemKey,
			VD.Qty,VD.UnitCost,VD.ExtCost, ISNULL(L.LegID,'') AS LegID, ISNULL(L.Description,'') AS LegDescription, 
			ISNULL(R.RouteKey,0) AS RouteKey,
			ISNULL(R.FromLocation,'') AS FromLocation , ISNULL(R.ToLocation,'') AS ToLocation
			,ISNULL(R.DriverKey,0) AS DriverKey, ISNULL(D.DriverID,'') as DriverID, isnull(D.FirstName,'') as FirstName,
			ISNULL(D.LastName,'') AS LastName, ISNULL(D.DrivingLicenseNo,'') AS DrivingLicenseNo,
			CASE WHEN ISNULL(R.RouteKey,0)=0 THEN 'Deductions & Refunds' ELSE ISNULL(OD.ContainerNo,'') END AS ContainerNo , 
			OD.OrderDetailKey, VD.Remarks
			, R.ActualArrival as ActualDelivery
			, R.ActualDeparture as ActualPickup
			, OE.CreateUserKey, OE.UpdateUserKey
			, U1.UserName AS CreatedUserName, u2.UserName as UpdatedUserName
	 FROM  dbo.VoucherHeader VH 
		INNER JOIN dbo.VoucherDetail VD ON VD.Voucherkey=VH.VoucherKey
		LEFT JOIN DBO.OrderExpense OE ON OE.RouteKey = VD.RouteKey AND OE.Itemkey = VD.ItemKey
		INNER JOIN dbo.Item I ON I.ItemKey=VD.ItemKey
		LEFT JOIN DBO.[Routes] R ON VD.RouteKey = R.RouteKey
		LEFT JOIN DBO.Leg L ON R.LegKey = L.LegKey
		LEFT JOIN dbo.Driver D on R.DriverKey = D.DriverKey
		LEFT JOIN dbo.orderdetail OD ON OD.OrderDetailKey=R.OrderDetailKey
		LEFT JOIN DBO.[User] U1 ON OE.CreateUserKey = U1.UserKey
		LEFT JOIN DBO.[User] U2 ON OE.UpdateUserKey = U2.UserKey
	 WHERE VH.VoucherKey=@VoucherKey	
	 UNION ALL
	 SELECT '',0,0,'','',0,0,0,0,'Deductions & Refunds','Deductions & Refunds',0,'','',0,'','','','','Deductions & Refunds',0,'',null,null, 0, 0, '', ''
	 ORDER BY Voucherkey, VoucherLineKey,ContainerNo,Routekey, ItemKey
END;
