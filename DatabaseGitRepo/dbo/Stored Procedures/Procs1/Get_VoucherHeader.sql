CREATE PROCEDURE [dbo].[Get_VoucherHeader] -- [Get_VoucherHeader] 260
@VoucherKey  INT=0
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	DECLARE @ContainerNo VARCHAR(5000)
	DECLARE @OrderNo VARCHAR(5000)
	Declare @DriverKey int = 0
	Declare @DriverOrgName varchar(500) = ''
	Declare @DriverName varchar(200) = ''
	Declare @DriverID varchar(100) = ''
	

	SELECT DISTINCT OD.ContainerNo,OrderNo  INTO #TempVoucherdata	
	FROM  dbo.VoucherDetail VD WITH(NOLOCK) 
		INNER JOIN DBO.[Routes] R WITH(NOLOCK) ON VD.RouteKey = R.RouteKey
		INNER JOIN dbo.orderdetail OD WITH(NOLOCK) ON OD.OrderDetailKey=R.OrderDetailKey
		INNER JOIN dbo.OrderHeader OH WITH(NOLOCK) ON OD.OrderKey=OH.OrderKey
	WHERE VD.Voucherkey=@VoucherKey

	select Top 1 @DriverKey = RT.DriverKey 
	from VoucherDetail VD WITH(NOLOCK)
	inner join Routes RT WITH(NOLOCK) on VD.RouteKey = RT.RouteKey
	where VoucherKey = @VoucherKey and DriverKey is not null


	SELECT @ContainerNo = COALESCE(@ContainerNo + ', ', '') + CAST(ContainerNo AS VARCHAR(15)),
		   @OrderNo = COALESCE(@OrderNo + ', ', '') + CAST(OrderNo AS VARCHAR(15))
	FROM #TempVoucherdata
	 
	select @DriverOrgName = case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end 
	from Driver d WITH(NOLOCK)
	where Driverkey = @DriverKey

	SET @DriverName =(SELECT isnull(d.FirstName,'') + ' ' + isnull(d.LastName,'')  
	from Driver d WITH(NOLOCK)
	where Driverkey = @DriverKey)

	select @DriverID = DriverID 
	from Driver d WITH(NOLOCK)
	where Driverkey = @DriverKey

	SELECT	VH.VoucherNo, A.VoucherAmt as VoucherAmount,Vh.DueDate, VH.VoucherDate, VH.IsPaymentApproved, VH.IsPaid, 0 AS RouteKey, 
			--RV.RouteKey,
			BT.AddrName ,BT.Address1 ,BT.City,
			BT.[State] ,BT.ZipCode ,BT.Country,@ContainerNo AS ContainerNo,@OrderNo AS OrderNo,
			VH.DriverNote, VH.InternalNote ,  VH.PaidDate,
			@DriverOrgName as DriverOrgName,
			VH.StatusKey ,@DriverID AS DriverID,@DriverName AS DriverName
	FROM dbo.VoucherHeader VH WITH(NOLOCK) 
		LEFT JOIN dbo.[Address] BT WITH(NOLOCK)		ON BT.AddrKey=VH.BillToAddrKey	
		Left join dbo.vVoucherAmt A WITH(NOLOCK) on VH.VoucherKey = A.voucherKey
	WHERE VH.VoucherKey= @VoucherKey
END