/**
DECLARE 
	@UserKey INT=512,
	@JSONString NVARCHAR(MAX)='[{"voucherlinekey":214183,"voucherkey":208502,"itemkey":32,"description":"DRIVER PAY","unitcost":325,"qty":1,"extcost":325,"VoucherNo":"83794","ItemID":"DRIVER PAY","LegID":"Shipper to Yard (Stop-Off)","LegDescription":"Shipper to Yard (Stop-Off)","FromLocation":"Carl Zeiss Vision-SD","ToLocation":"Reyes","DriverKey":1160,"DriverID":"E & D TRANSPORT INC.","DriverFirstName":"EMERSSON ","DriverLastName":"BERMUDEZ","DrivingLicenseNo":"","ContainerNo":"HLBU1047711","UserKey":0,"RouteKey":424229,"OrderDetailKey":124954,"Remarks":null,"isNewItem":false,"ActualPickup":"2024-06-12T09:55:32.773","ActualDelivery":"2024-06-12T11:55:00","CreatedUserKey":291,"UpdatedUserKey":291,"CreatedUserName":"Kathy  Castillo","UpdatedUserName":"Kathy  Castillo","DriverPay":"P"},{"voucherlinekey":222207,"voucherkey":208502,"itemkey":252,"description":"CARRIER RATE","unitcost":25,"qty":1,"extcost":25,"VoucherNo":"83794","ItemID":"CARRIER RATE","LegID":"Yard To Shipper","LegDescription":"Yard To Shipper","FromLocation":"Reyes","ToLocation":"Carl Zeiss Vision-SD","DriverKey":1160,"DriverID":"E & D TRANSPORT INC.","DriverFirstName":"EMERSSON ","DriverLastName":"BERMUDEZ","DrivingLicenseNo":"","ContainerNo":"HLBU1047711","UserKey":0,"RouteKey":422110,"OrderDetailKey":124954,"Remarks":null,"isNewItem":false,"ActualPickup":"2024-06-12T09:31:27.323","ActualDelivery":"2024-06-12T09:31:28.597","CreatedUserKey":0,"UpdatedUserKey":0,"CreatedUserName":null,"UpdatedUserName":null,"DriverPay":"NP"}]',
	@Status BIT=0,
	@Reason VARCHAR(100)=''
EXec InsertUpdate_Voucher_V2 @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[InsertUpdate_Voucher_V2]
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

	Create Table #Items (
		VoucherKey			INT,
		ItemKey				INT,
		RouteKey			INT,
		Qty					DECIMAL(18,4),
		UnitCost			DECIMAL(18,4),
		DriverPay			varchar(2),
		IsNew				bit default 1,
		VoucherLineKey		int,
		Remarks				VARCHAR(100)
	)
	if(isnull(ltrim(rtrim(@JSONString)) ,'') = '')
	Begin
		SEt @Status = 0
		Set @Reason = 'Parameters not found'
		return
	End

	insert into #Items (VoucherKey	,ItemKey	,RouteKey	,Qty	,UnitCost , DriverPay, IsNew, VoucherLineKey,Remarks)
	select VoucherKey	,ItemKey	,RouteKey	,Qty	,UnitCost , DriverPay, IsNew, VoucherLineKey,Remarks
	from OpenJSON(@JsonString, '$')
	WITH (
		VoucherKey				INT				'$.voucherkey',
		ItemKey					INT				'$.itemkey',
		RouteKey				INT				'$.RouteKey',
		Qty						DECIMAL(18,4)	'$.qty',
		UnitCost				DECIMAL(18,4)	'$.unitcost',
		DriverPay				varchar(2)		'$.DriverPay',
		VoucherLineKey			int				'$.voucherlinekey',
		IsNew					bit				'$.isNewItem',
		Remarks					VARCHAR(1000)	'$.Remarks'	
	)
	if((Select count(1) from #Items) = 0)
	Begin
		SEt @Status = 0
		Set @Reason = 'Items Not found'
		return
	End

	select * from #Items

	update T Set UnitCost = I.UnitCost
	from #Items T
	inner join Item I WITH (READPAST) on T.ItemKey = I.ItemKey
	where IsNull(T.UnitCost,0) = 0
	
	insert into VoucherDetail 
		(Voucherkey, ItemKey, Description, UnitCost, Qty, ExtCost, RouteKey,  CreateUserKey, CreateDate, DriverPay)
	select T.VoucherKey, T.ItemKey, I.Description, T.UnitCost, T.Qty, isnull(T.UnitCost,0) * isnull(T.qty,0), 
		T.RouteKey, @UserKey, GetDate(), T.DriverPay
	from #Items T
	Left Join Item I WITH (READPAST) on T.ItemKey = I.ItemKey
	where T.IsNew = 1

	update VD Set 
		ItemKey		= T.ItemKey, 
		UnitCost	= T.UnitCost,
		Qty			= T.Qty,
		ExtCost		= isnull(T.UnitCost,0) * isnull(T.qty,0), 
		DriverPay	= T.DriverPay,
		RouteKey	= T.routekey,
		UpdateUserKey = @UserKey,
		Remarks=T.Remarks,
		UpdateDate = GetDate()
	from VoucherDetail VD 
	inner join #Items T on Vd.VoucherLineKey = T.VoucherLineKey

	Declare @voucherKey int
	select top 1 @voucherKey = VoucherKey from #Items

	UPDATE dbo.VoucherHeader
	SET VoucherAmount=(  SELECT SUM(ISNULL(ExtCost,0)) FROM dbo.VoucherDetail WHERE VoucherKey=@VoucherKey ),
	UpdateuserKey=@UserKey
	WHERE VoucherKey= @VoucherKey

	UPDATE VoucherHeader 
	SET NPAmount=(SELECT SUM(VD.ExtCost) FROM VoucherDetail VD
					WHERE ISNULL(DriverPay,'P')='NP' AND VoucherKey=@VoucherKey)

	
	SET @Status =1;
	set @Reason = 'Success'
END;
