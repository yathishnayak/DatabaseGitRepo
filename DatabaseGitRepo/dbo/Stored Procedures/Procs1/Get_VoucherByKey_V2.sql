--select top 10 * from voucherheader order by voucherkey desc
--select * from voucherdetail where voucherkey = 211775

/*
	Declare @UserKey int=29,@JSONString nvarchar(max),@Status 	bit	= 0,@Reason	varchar(1000) = '' 
	set @JsonString = '{"VoucherKey":211775}'
	exec Get_VoucherByKey_V2 @UserKey, @JSONString, @Status output, @Reason output
	select @Status, @Reason
*/
CREATE PROCEDURE [dbo].[Get_VoucherByKey_V2] -- Get_VoucherByKey_V2 211775
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output
)

AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	declare @VoucherKey  INT=0

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Select @VoucherKey = VoucherKey
	from OpenJSON(@JsonString, '$')
	WITH (
		VoucherKey			int			'$.VoucherKey'
	)
	if(isnull(ltrim(rtrim(@VoucherKey)) ,0) = 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'Voucher No not found'
		return
	End

	DECLARE @ContainerNo VARCHAR(5000)
	DECLARE @OrderNo VARCHAR(5000)
	Declare @DriverKey int = 0
	Declare @DriverOrgName varchar(500) = ''
	Declare @DriverName varchar(200) = ''
	Declare @DriverID varchar(100) = ''
	
	--**// HEADER PART

	SELECT DISTINCT OD.ContainerNo,OrderNo  INTO #TempVoucherdata	
	FROM  dbo.VoucherDetail VD 
		INNER JOIN DBO.[Routes] R ON VD.RouteKey = R.RouteKey
		INNER JOIN dbo.orderdetail OD ON OD.OrderDetailKey=R.OrderDetailKey
		INNER JOIN dbo.OrderHeader OH ON OD.OrderKey=OH.OrderKey
	WHERE VD.Voucherkey=@VoucherKey

	select Top 1 @DriverKey = RT.DriverKey 
	from VoucherDetail VD
	inner join Routes RT on VD.RouteKey = RT.RouteKey
	where VoucherKey = @VoucherKey and DriverKey is not null


	SELECT @ContainerNo = COALESCE(@ContainerNo + ', ', '') + CAST(ContainerNo AS VARCHAR(15)),
		   @OrderNo = COALESCE(@OrderNo + ', ', '') + CAST(OrderNo AS VARCHAR(15))
	FROM #TempVoucherdata
	 
	select @DriverOrgName = case when isnull(d.OrgName,'') = '' then '' 
				else  isnull(d.OrgName,'') + ' ' + isnull(d.OrgCity,'') + ' ' + isnull(d.OrgZipCode,'') + ' ' 
					+ isnull(d.OrgState,'') + ' ' + isnull(d.OrgCountry,'') end 
	from Driver d
	where Driverkey = @DriverKey

	SET @DriverName =(SELECT isnull(d.FirstName,'') + ' ' + isnull(d.LastName,'')  
	from Driver d
	where Driverkey = @DriverKey)

	select @DriverID = DriverID 
	from Driver d
	where Driverkey = @DriverKey

	

	--**// DETAIL PART

SELECT  VH.VoucherNo
		, VH.VoucherKey as voucherkey
		, VD.VoucherLineKey as voucherlinekey
		, ItemID
		, VD.[Description] 
		, VD.ItemKey as itemkey
		, VD.Qty as qty
		, VD.UnitCost as unitcost
		, VD.ExtCost as extcost 
		, ISNULL(L.LegID,'') AS LegID 
		, ISNULL(L.Description,'') AS LegDescription
		, ISNULL(R.RouteKey,0) AS RouteKey
		, ISNULL(R.FromLocation,'') AS FromLocation 
		, ISNULL(R.ToLocation,'') AS ToLocation
		, ISNULL(R.DriverKey,0) AS DriverKey
		, ISNULL(D.DriverID,'') as DriverID 
		, isnull(D.FirstName,'') as DriverFirstName
		, ISNULL(D.LastName,'') AS DriverLastName
		, ISNULL(D.DrivingLicenseNo,'') AS DrivingLicenseNo
		, CASE WHEN ISNULL(R.RouteKey,0)=0 THEN 'Deductions & Refunds' ELSE ISNULL(OD.ContainerNo,'') END AS ContainerNo  
		, isnull(OD.OrderDetailKey,0) as OrderDetailKey
		, VD.Remarks
		, R.ActualArrival as ActualDelivery
		, R.ActualDeparture as ActualPickup
		, isnull(OE.CreateUserKey,0) as CreateUserKey
		, Isnull(OE.UpdateUserKey,0) as UpdateUserKey
		, U1.UserName AS CreatedUserName
		, u2.UserName as UpdatedUserName
		, convert(bit, 0) as isNewItem
	INTO #Temp
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
	SELECT '',0,0,'','',0,0,0,0,'Deductions & Refunds','Deductions & Refunds',0,'','',0,'','','','','Deductions & Refunds',0,'',null,null, 0, 0, '', '',0
	ORDER BY VH.Voucherkey, VD.VoucherLineKey,Routekey, ItemKey

	SELECT	  VH.VoucherNo
			, VH.VoucherKey
			, A.VoucherAmt as VoucherAmount
			, Vh.DueDate
			, VH.VoucherDate
			, VH.IsPaymentApproved
			, VH.IsPaid
			, 0 AS RouteKey 
			, BT.AddrName 
			, BT.Address1 
			, BT.City
			, BT.[State] 
			, BT.ZipCode 
			, BT.Country
			, @ContainerNo AS ContainerNo
			, @OrderNo AS OrderNo
			, VH.DriverNote
			, VH.InternalNote 
			, VH.PaidDate
			, @DriverOrgName as DriverOrgName
			, VH.StatusKey 
			, @DriverID AS DriverID
			, @DriverName AS DriverName
			, VoucherDetail = (
				Select * from #Temp
				FOR JSON PATH
			)
	FROM dbo.VoucherHeader VH 
		LEFT JOIN dbo.[Address] BT		ON BT.AddrKey=VH.BillToAddrKey	
		Left join dbo.vVoucherAmt A on VH.VoucherKey = A.voucherKey
	WHERE VH.VoucherKey= @VoucherKey
	FOR JSON PATH

	SEt @Status = 1
	Set @Reason = 'SUCCESS'
END;
