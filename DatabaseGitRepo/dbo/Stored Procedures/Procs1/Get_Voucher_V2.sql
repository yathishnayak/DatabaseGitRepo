/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='{"voucherkey":208502}',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec Get_Voucher_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[Get_Voucher_V2]
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

	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	Declare @VoucherKey  INT=0

	select @VoucherKey = VoucherKey
	from OpenJSON(@JsonString, '$')
	WITH (
		VoucherKey				INT				'$.voucherkey'
	)

	DECLARE @ContainerNo VARCHAR(5000)
	DECLARE @OrderNo VARCHAR(5000)
	Declare @DriverKey int = 0
	Declare @DriverOrgName varchar(500) = ''
	Declare @DriverName varchar(200) = ''
	Declare @DriverID varchar(100) = ''


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
			, U1.UserName AS CreatedUserName, u2.UserName as UpdatedUserName, VD.DriverPay
	 into #VoucherItems
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
	 SELECT '',0,0,'','',0,0,0,0,'Deductions & Refunds','Deductions & Refunds',0,'','',0,'','','','','Deductions & Refunds',0,'',null,null, 0, 0, '', '',''
	 ORDER BY Voucherkey, VoucherLineKey,ContainerNo,Routekey, ItemKey

	SELECT	VH.VoucherNo, A.VoucherAmt as VoucherAmount,Vh.DueDate, VH.VoucherDate, VH.IsPaymentApproved, VH.IsPaid, 0 AS RouteKey, 
			--RV.RouteKey,
			BT.AddrName ,BT.Address1 ,BT.City,
			BT.[State] ,BT.ZipCode ,BT.Country,@ContainerNo AS ContainerNo,@OrderNo AS OrderNo,
			VH.DriverNote, VH.InternalNote ,  VH.PaidDate,
			@DriverOrgName as DriverOrgName,
			VH.StatusKey ,@DriverID AS DriverID,@DriverName AS DriverName
	Into #VoucherHeader
	FROM dbo.VoucherHeader VH 
		LEFT JOIN dbo.[Address] BT		ON BT.AddrKey=VH.BillToAddrKey	
		Left join dbo.vVoucherAmt A on VH.VoucherKey = A.voucherKey
	WHERE VH.VoucherKey= @VoucherKey

	Select duedate,
		ispaymentapproved,
		routekey,
		voucheramount,
		voucherdate,
		Address1,
		AddrName,
		City,
		Country,
		State,
        @VoucherKey as voucherkey ,
        voucherno ,
        ZipCode ,
        ContainerNo ,
        OrderNo ,
        DriverNote,
        InternalNote,
        IsPaid, 
        PaidDate, 
        DriverOrgName, 
        StatusKey, 
        DriverID,
        DriverName,
		VoucherDetails = 
			(select  
					description,
                    Firstname as  DriverFirstName,
                    DriverID,
                    DriverKey,
                    LastName as DriverLastName,
                    DrivingLicenseNo,
                    extcost,
                    FromLocation,
                    ItemID,
                    itemkey,
                    LegDescription,
                    LegID,
                    qty, 
                    ToLocation, 
                    unitcost, 
                    voucherkey, 
                    voucherlinekey, 
                    VoucherNo, 
                    RouteKey, 
                    ContainerNo, 
                    OrderDetailKey, 
                    Remarks, 
                    0 as isNewItem,
					DriverPay,
                    ActualPickup,
                    ActualDelivery,
                    CreateUserKey as CreatedUserKey,
                    UpdateUserKey as UpdatedUserKey,
                    CreatedUserName,
                    UpdatedUserName
			from #VoucherItems
			for JSON PATH
		)
	from #VoucherHeader
	For JSON PATH

	set @Status = 1
	set @Reason = 'SUCCESS'
	drop table #TempVoucherdata
	drop table #VoucherHeader
	drop table #VoucherItems
END
