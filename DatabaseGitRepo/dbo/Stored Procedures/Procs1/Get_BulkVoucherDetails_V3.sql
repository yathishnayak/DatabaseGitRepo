/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"VoucherKeys" : "353238,354321"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXec [Get_BulkVoucherDetails_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	Select @Status AS Status, @Reason AS Reason

	SELECT TOP 100 * FROM VoucherHeader
*/
CREATE PROCEDURE [dbo].[Get_BulkVoucherDetails_V3] 
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
		@VoucherKey  varchar(500) -- Comma seperated

	SELECT
		@VoucherKey		=    VoucherKey
	FROM OPENJSON(@JSONString)
	WITH
	(
		VoucherKey			VARCHAR(500)		'$.VoucherKeys'
	)


	create table #VoucherKey
	(
		VoucherKey int
	)
	insert into #VoucherKey 
	select value from dbo.Fn_SplitParam(@VoucherKey)

	DECLARE @ContainerNo VARCHAR(5000)
	DECLARE @OrderNo VARCHAR(5000)

	SELECT 
		OuterVH.VoucherKey,	
		OuterVH.VoucherNo,
		OuterVH.VoucherAmount,
		OuterVH.DueDate, 
		OuterVH.VoucherDate, 
		OuterVH.IsPaymentApproved, 
		OuterVH.IsPaid, 0 AS RouteKey, --RV.RouteKey,
		BT.AddrName ,
		BT.Address1 ,
		BT.City,
		BT.[State] ,
		BT.ZipCode ,
		BT.Country,
		@ContainerNo AS ContainerNo,
		@OrderNo AS OrderNo,
		OuterVH.DriverNote, 
		OuterVH.InternalNote,
		( 
    SELECT *
    FROM (
        SELECT 
            VH.VoucherNo,
            VH.VoucherKey,
            VD.VoucherLineKey,
            ItemID,
            VD.[Description], 
            VD.ItemKey,
            VD.Qty,
            VD.UnitCost,
            VD.ExtCost, 
            ISNULL(L.LegID,'') AS LegID, 
            ISNULL(L.Description,'') AS LegDescription, 
            ISNULL(R.RouteKey,0) AS RouteKey,
            ISNULL(R.FromLocation,'') AS FromLocation, 
            ISNULL(R.ToLocation,'') AS ToLocation,
            ISNULL(R.DriverKey,0) AS DriverKey, 
            ISNULL(D.DriverID,'') AS DriverID, 
            ISNULL(D.FirstName,'') AS FirstName,
            ISNULL(D.LastName,'') AS LastName, 
            ISNULL(D.DrivingLicenseNo,'') AS DrivingLicenseNo,
            CASE WHEN ISNULL(R.RouteKey,0)=0 THEN 'Deductions & Refunds' ELSE ISNULL(OD.ContainerNo,'') END AS ContainerNo, 
            OD.OrderDetailKey, 
            VD.Remarks, 
            R.ActualArrival AS ActualDelivery, 
            R.ActualDeparture AS ActualPickup, 
            OE.CreateUserKey, OE.UpdateUserKey, 
            U1.UserName AS CreatedUserName, 
            U2.UserName AS UpdatedUserName,
			VD.DriverPay as DriverPay
        FROM dbo.VoucherHeader VH 
            INNER JOIN dbo.VoucherDetail VD ON VD.Voucherkey = VH.VoucherKey
            LEFT JOIN DBO.OrderExpense OE ON OE.RouteKey = VD.RouteKey AND OE.Itemkey = VD.ItemKey
            INNER JOIN dbo.Item I ON I.ItemKey = VD.ItemKey
            LEFT JOIN DBO.[Routes] R ON VD.RouteKey = R.RouteKey
            LEFT JOIN DBO.Leg L ON R.LegKey = L.LegKey
            LEFT JOIN dbo.Driver D ON R.DriverKey = D.DriverKey
            LEFT JOIN dbo.orderdetail OD ON OD.OrderDetailKey = R.OrderDetailKey
            LEFT JOIN DBO.[User] U1 ON OE.CreateUserKey = U1.UserKey
            LEFT JOIN DBO.[User] U2 ON OE.UpdateUserKey = U2.UserKey
        WHERE VH.VoucherKey = OuterVH.VoucherKey
		--WHERE VH.VoucherKey IN (SELECT VoucherKey FROM #VoucherKey)

        UNION ALL

        SELECT '', 0, 0, '', '', 0, 0, 0, 0,
               'Deductions & Refunds', 'Deductions & Refunds',
               0, '', '', 0, '', '', '', '',
               'Deductions & Refunds', 0, '', NULL, NULL, 0, 0, '', '', ''
    ) AS CombinedData
    ORDER BY VoucherKey, VoucherLineKey, ContainerNo, RouteKey, ItemKey
    FOR JSON PATH
	) AS VoucherDetails
	FROM dbo.VoucherHeader OuterVH 
	LEFT JOIN dbo.[Address] BT		ON BT.AddrKey=OuterVH.BillToAddrKey		
	INNER JOIN #VoucherKey V ON OuterVH.VoucherKey = V.VoucherKey
	FOR JSON PATH


	SET @Status = 1
	SET @Reason = 'Success'
END
