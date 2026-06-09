CREATE PROCEDURE [dbo].[Get_BulkVoucherHeader] -- [Get_BulkVoucherHeader] '127:128'
@VoucherKey  varchar(500) -- colon seperated
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	create table #VoucherKey
	(
		VoucherKey int
	)
	insert into #VoucherKey 
	select value from dbo.Fn_SplitParamCol(@VoucherKey)

	DECLARE @ContainerNo VARCHAR(5000)
	DECLARE @OrderNo VARCHAR(5000)

	/*
	SELECT DISTINCT  OD.ContainerNo,OrderNo  
	INTO #TempVoucherdata	
	FROM  dbo.VoucherDetail VD 
		INNER JOIN DBO.[Routes] R ON VD.RouteKey = R.RouteKey
		INNER JOIN dbo.orderdetail OD ON OD.OrderDetailKey=R.OrderDetailKey
		INNER JOIN dbo.OrderHeader OH ON OD.OrderKey=OH.OrderKey
		INNER JOIN #VoucherKey V ON VD.Voucherkey = V.VoucherKey

	SELECT @ContainerNo = COALESCE(@ContainerNo + ', ', '') + CAST(ContainerNo AS VARCHAR(15)),
		   @OrderNo = COALESCE(@OrderNo + ', ', '') + CAST(OrderNo AS VARCHAR(15))
	FROM #TempVoucherdata
	*/

	SELECT VH.VoucherKey,	VH.VoucherNo,VH.VoucherAmount,Vh.DueDate, VH.VoucherDate, 
		VH.IsPaymentApproved, VH.IsPaid, 0 AS RouteKey, --RV.RouteKey,
			BT.AddrName ,BT.Address1 ,BT.City,
			BT.[State] ,BT.ZipCode ,BT.Country,
			@ContainerNo AS ContainerNo,@OrderNo AS OrderNo,
			VH.DriverNote, VH.InternalNote
	FROM dbo.VoucherHeader VH 
		LEFT JOIN dbo.[Address] BT		ON BT.AddrKey=VH.BillToAddrKey		
	INNER JOIN #VoucherKey V ON VH.Voucherkey = V.VoucherKey
END
