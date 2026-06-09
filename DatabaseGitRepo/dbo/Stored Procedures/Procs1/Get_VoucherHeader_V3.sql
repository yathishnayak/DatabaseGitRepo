/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"VoucherKey" : 410279}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Get_VoucherHeader_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[Get_VoucherHeader_V3] -- [Get_VoucherHeader] 124256
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END

	DECLARE
		@VoucherKey  INT=0
	SELECT
		@VoucherKey		=		VoucherKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		VoucherKey		INT		'$.VoucherKey'
	)

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
			VH.StatusKey ,@DriverID AS DriverID,@DriverName AS DriverName,
			VoucherDetails=(
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
							  For JSON PATH
				)
	FROM dbo.VoucherHeader VH WITH(NOLOCK) 
		LEFT JOIN dbo.[Address] BT WITH(NOLOCK)		ON BT.AddrKey=VH.BillToAddrKey	
		Left join dbo.vVoucherAmt A WITH(NOLOCK) on VH.VoucherKey = A.voucherKey
	WHERE VH.VoucherKey= @VoucherKey
	FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status = 1
	SET @Reason = 'Success'
END