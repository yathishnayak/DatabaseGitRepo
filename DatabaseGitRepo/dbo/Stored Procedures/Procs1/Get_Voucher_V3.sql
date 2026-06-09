/**

DECLARE 
	@UserKey		INT				= 512,
	@JSONString		NVARCHAR(MAX)	= '{"VoucherKey":299443}',
	@Status			BIT				= 0,
	@Reason			VARCHAR(100)	= ''
EXEC [Get_Voucher_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT
Select @Status AS Status, @Reason AS Reason

**/
CREATE PROCEDURE [dbo].[Get_Voucher_V3]
(
    @UserKey    INT,
    @JSONString NVARCHAR(MAX),
    @Status     BIT = 0 OUTPUT,
    @Reason     VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF;

    -- Initialize output parameters
    SET @Status = 0;
    SET @Reason = 'Failure';

    -- Validate JSON input
    IF (ISNULL(LTRIM(RTRIM(@JSONString)), '') = '')
    BEGIN
        SET @Reason = 'Parameters not found';
        RETURN;
    END

    -- Parse JSON input
    DECLARE @VoucherKey INT = 0;
    
    SELECT @VoucherKey = VoucherKey
    FROM OPENJSON(@JSONString, '$')
    WITH (
        VoucherKey INT '$.VoucherKey'
    );

    -- Validate VoucherKey
    IF (@VoucherKey = 0)
    BEGIN
        SET @Reason = 'Invalid VoucherKey';
        RETURN;
    END

    -- Declare variables
    DECLARE 
        @ContainerNo   VARCHAR(5000),
        @OrderNo       VARCHAR(5000),
        @DriverKey     INT = 0,
        @DriverOrgName VARCHAR(500) = '',
        @DriverName    VARCHAR(200) = '',
        @DriverID      VARCHAR(100) = '';

    -- Get container and order data
    SELECT DISTINCT OD.ContainerNo, OH.OrderNo
    INTO #TempVoucherdata
    FROM dbo.VoucherDetail VD 
        INNER JOIN dbo.[Routes] R  WITH(NOLOCK) ON VD.RouteKey = R.RouteKey
        INNER JOIN dbo.OrderDetail OD WITH(NOLOCK) ON OD.OrderDetailKey = R.OrderDetailKey
        INNER JOIN dbo.OrderHeader OH WITH(NOLOCK) ON OD.OrderKey = OH.OrderKey
    WHERE VD.VoucherKey = @VoucherKey;

    -- Get driver key
    SELECT TOP 1 @DriverKey = RT.DriverKey 
    FROM dbo.VoucherDetail VD WITH(NOLOCK)
        INNER JOIN dbo.Routes RT WITH(NOLOCK) ON VD.RouteKey = RT.RouteKey
    WHERE VD.VoucherKey = @VoucherKey 
        AND RT.DriverKey IS NOT NULL;

    -- Concatenate container and order numbers
    SELECT 
        @ContainerNo = COALESCE(@ContainerNo + ', ', '') + CAST(ContainerNo AS VARCHAR(15)),
        @OrderNo = COALESCE(@OrderNo + ', ', '') + CAST(OrderNo AS VARCHAR(15))
    FROM #TempVoucherdata;

    -- Get driver information in single query (performance improvement)
    SELECT 
        @DriverOrgName = CASE 
            WHEN ISNULL(OrgName, '') = '' THEN '' 
            ELSE ISNULL(OrgName, '') + ' ' + ISNULL(OrgCity, '') + ' ' + 
                 ISNULL(OrgZipCode, '') + ' ' + ISNULL(OrgState, '') + ' ' + 
                 ISNULL(OrgCountry, '') 
        END,
        @DriverName = ISNULL(FirstName, '') + ' ' + ISNULL(LastName, ''),
        @DriverID = ISNULL(DriverID, '')
    FROM dbo.Driver WITH(NOLOCK) 
    WHERE DriverKey = @DriverKey;

    -- Get voucher items with proper Pascal casing
    SELECT 
        VH.VoucherNo,
        VH.VoucherKey,
        VD.VoucherLineKey,
        I.ItemID,
        VD.[Description], 
        VD.ItemKey,
        VD.Qty,
        VD.UnitCost,
        VD.ExtCost, 
        ISNULL(L.LegID, '') AS LegID, 
        ISNULL(L.Description, '') AS LegDescription, 
        ISNULL(R.RouteKey, 0) AS RouteKey,
        ISNULL(R.FromLocation, '') AS FromLocation, 
        ISNULL(R.ToLocation, '') AS ToLocation,
        ISNULL(R.DriverKey, 0) AS DriverKey, 
        ISNULL(D.DriverID, '') AS DriverID, 
        ISNULL(D.FirstName, '') AS FirstName,
        ISNULL(D.LastName, '') AS LastName, 
        ISNULL(D.DrivingLicenseNo, '') AS DrivingLicenseNo,
        CASE 
            WHEN ISNULL(R.RouteKey, 0) = 0 THEN 'Deductions & Refunds' 
            ELSE ISNULL(OD.ContainerNo, '') 
        END AS ContainerNo,
        OD.OrderDetailKey, 
        VD.Remarks,
        R.ActualArrival AS ActualDelivery,
        R.ActualDeparture AS ActualPickup,
        OE.CreateUserKey, 
        OE.UpdateUserKey,
        U1.UserName AS CreatedUserName, 
        U2.UserName AS UpdatedUserName, 
        VD.DriverPay AS DriverPay
    INTO #VoucherItems
    FROM dbo.VoucherHeader VH  WITH(NOLOCK)
        INNER JOIN dbo.VoucherDetail VD WITH(NOLOCK) ON VD.VoucherKey = VH.VoucherKey
        INNER JOIN dbo.Item I WITH(NOLOCK) ON I.ItemKey = VD.ItemKey
        LEFT JOIN dbo.OrderExpense OE WITH(NOLOCK) ON OE.RouteKey = VD.RouteKey AND OE.ItemKey = VD.ItemKey
        LEFT JOIN dbo.[Routes] R WITH(NOLOCK) ON VD.RouteKey = R.RouteKey
        LEFT JOIN dbo.Leg L WITH(NOLOCK) ON R.LegKey = L.LegKey
        LEFT JOIN dbo.Driver D WITH(NOLOCK) ON R.DriverKey = D.DriverKey
        LEFT JOIN dbo.OrderDetail OD WITH(NOLOCK) ON OD.OrderDetailKey = R.OrderDetailKey
        LEFT JOIN dbo.[User] U1 WITH(NOLOCK) ON OE.CreateUserKey = U1.UserKey
        LEFT JOIN dbo.[User] U2 WITH(NOLOCK) ON OE.UpdateUserKey = U2.UserKey
    WHERE VH.VoucherKey = @VoucherKey
    
    UNION ALL
    
    SELECT '', 0, 0, '', '', 0, 0, 0, 0, 'Deductions & Refunds', 'Deductions & Refunds', 
           0, '', '', 0, '', '', '', '', 'Deductions & Refunds', 0, '', 
           NULL, NULL, 0, 0, '', '', ''
    ORDER BY VoucherKey, VoucherLineKey, ContainerNo, RouteKey, ItemKey;

    -- Get voucher header
    SELECT 
        VH.VoucherNo, 
        A.VoucherAmt AS VoucherAmount,
        VH.DueDate, 
        VH.VoucherDate, 
        VH.IsPaymentApproved, 
        VH.IsPaid, 
        0 AS RouteKey,
        BT.AddrName,
        BT.Address1,
        BT.City,
        BT.[State],
        BT.ZipCode,
        BT.Country,
        @ContainerNo AS ContainerNo,
        @OrderNo AS OrderNo,
        VH.DriverNote, 
        VH.InternalNote,
        VH.PaidDate,
        @DriverOrgName AS DriverOrgName,
        VH.StatusKey,
        @DriverID AS DriverID,
        @DriverName AS DriverName
    INTO #VoucherHeader
    FROM dbo.VoucherHeader VH  WITH(NOLOCK)
        LEFT JOIN dbo.[Address] BT WITH(NOLOCK) ON BT.AddrKey = VH.BillToAddrKey
        LEFT JOIN dbo.vVoucherAmt A WITH(NOLOCK) ON VH.VoucherKey = A.VoucherKey
    WHERE VH.VoucherKey = @VoucherKey;

    -- Final output with proper Pascal casing
    SELECT 
        DueDate,
        IsPaymentApproved,
        RouteKey,
        VoucherAmount,
        VoucherDate,
        Address1,
        AddrName,
        City,
        Country,
        [State],
        @VoucherKey AS VoucherKey,
        VoucherNo,
        ZipCode,
        ContainerNo,
        OrderNo,
        DriverNote,
        InternalNote,
        IsPaid, 
        PaidDate, 
        DriverOrgName, 
        StatusKey, 
        DriverID,
        DriverName,
        VoucherDetails = 
            (SELECT  
                [Description],
                FirstName AS DriverFirstName,
                DriverID,
                DriverKey,
                LastName AS DriverLastName,
                DrivingLicenseNo,
                ExtCost,
                FromLocation,
                ItemID,
                ItemKey,
                LegDescription,
                LegID,
                Qty, 
                ToLocation, 
                UnitCost, 
                VoucherKey, 
                VoucherLineKey, 
                VoucherNo, 
                RouteKey, 
                ContainerNo, 
                OrderDetailKey, 
                Remarks, 
                0 AS IsNewItem,
                DriverPay,
                ActualPickup,
                ActualDelivery,
                CreateUserKey AS CreatedUserKey,
                UpdateUserKey AS UpdatedUserKey,
                CreatedUserName,
                UpdatedUserName
            FROM #VoucherItems
            FOR JSON PATH
        )
    FROM #VoucherHeader
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

    -- Success
    SET @Status = 1;
    SET @Reason = 'SUCCESS';
    
    -- Git Test
    -- Cleanup
    DROP TABLE #TempVoucherdata;
    DROP TABLE #VoucherHeader;
    DROP TABLE #VoucherItems;
END