/**

DECLARE 
    @UserKey    INT = 512,
    @JSONString NVARCHAR(MAX) = '{"VoucherKey": 299376}',
    @Status     BIT = 0,
    @Reason     VARCHAR(1000) = '';

EXEC [dbo].[InsertUpdate_Voucher_V3] 
    @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT;

SELECT @Status AS Status, @Reason AS Reason;

**/

/**

DECLARE 
    @UserKey    INT = 512,
    @JSONString NVARCHAR(MAX) = '[
	{
		"Description": "",
		"DriverFirstName": "",
		"DriverID": "",
		"DriverKey": 0,
		"DriverLastName": "",
		"DrivingLicenseNo": "",
		"ExtCost": 0,
		"FromLocation": "",
		"ItemID": "",
		"ItemKey": 0,
		"LegDescription": "Deductions & Refunds",
		"LegID": "Deductions & Refunds",
		"Qty": 0,
		"ToLocation": "",
		"UnitCost": 0,
		"VoucherKey": 0,
		"VoucherLineKey": 0,
		"VoucherNo": "",
		"RouteKey": 0,
		"ContainerNo": "Deductions & Refunds",
		"OrderDetailKey": 0,
		"Remarks": "",
		"IsNewItem": 0,
		"DriverPay": "NP",
		"CreatedUserKey": 0,
		"UpdatedUserKey": 0,
		"CreatedUserName": "",
		"UpdatedUserName": "",
		"IsDriverPay": false
	},
	{
		"Description": "CARRIER RATE",
		"DriverFirstName": "Rene ",
		"DriverID": "105-RENE & REFUGIO T",
		"DriverKey": 1861,
		"DriverLastName": "Hernandez",
		"DrivingLicenseNo": "",
		"ExtCost": 162.25,
		"FromLocation": "Port",
		"ItemID": "CARRIER RATE",
		"ItemKey": 252,
		"LegDescription": "Port To Yard (Pre-Pull)",
		"LegID": "Port To Yard (Pre-Pull)",
		"Qty": 1,
		"ToLocation": "Yard",
		"UnitCost": 162.25,
		"VoucherKey": 349766,
		"VoucherLineKey": 554249,
		"VoucherNo": "223222",
		"RouteKey": 886855,
		"ContainerNo": "BMOU5428056",
		"OrderDetailKey": 281591,
		"IsNewItem": 0,
		"DriverPay": "NP",
		"ActualPickup": "2025-12-15T15:27:00",
		"ActualDelivery": "2025-12-15T15:36:23",
		"CreatedUserKey": 943,
		"UpdatedUserKey": 943,
		"CreatedUserName": "Roger  Granja",
		"UpdatedUserName": "Roger  Granja",
		"IsDriverPay": true
	},
	{
		"Description": "FUEL SURCHARGE (FSC)",
		"DriverFirstName": "Rene ",
		"DriverID": "105-RENE & REFUGIO T",
		"DriverKey": 1861,
		"DriverLastName": "Hernandez",
		"DrivingLicenseNo": "",
		"ExtCost": 40.5625,
		"FromLocation": "Port",
		"ItemID": "FUEL SURCHARGE (FSC)",
		"ItemKey": 17,
		"LegDescription": "Port To Yard (Pre-Pull)",
		"LegID": "Port To Yard (Pre-Pull)",
		"Qty": 162.25,
		"ToLocation": "Yard",
		"UnitCost": 0.25,
		"VoucherKey": 349766,
		"VoucherLineKey": 554250,
		"VoucherNo": "223222",
		"RouteKey": 886855,
		"ContainerNo": "BMOU5428056",
		"OrderDetailKey": 281591,
		"IsNewItem": 0,
		"DriverPay": "NP",
		"ActualPickup": "2025-12-15T15:27:00",
		"ActualDelivery": "2025-12-15T15:36:23",
		"CreatedUserKey": 943,
		"UpdatedUserKey": 943,
		"CreatedUserName": "Roger  Granja",
		"UpdatedUserName": "Roger  Granja",
		"IsDriverPay": false
	},
	{
		"Description": "DED Fuel",
		"DriverFirstName": "Rene ",
		"DriverID": "105-RENE & REFUGIO T",
		"DriverKey": 1861,
		"DriverLastName": "Hernandez",
		"DrivingLicenseNo": "",
		"ExtCost": 10,
		"FromLocation": "Port",
		"ItemID": "DED Fuel",
		"ItemKey": 370,
		"LegDescription": "Port To Yard (Pre-Pull)",
		"LegID": "Port To Yard (Pre-Pull)",
		"Qty": 1,
		"ToLocation": "Yard",
		"UnitCost": 10,
		"VoucherKey": 349766,
		"VoucherLineKey": 653019,
		"VoucherNo": "223222",
		"RouteKey": 886855,
		"ContainerNo": "BMOU5428056",
		"OrderDetailKey": 281591,
		"IsNewItem": 0,
		"DriverPay": "P",
		"ActualPickup": "2025-12-15T15:27:00",
		"ActualDelivery": "2025-12-15T15:36:23",
		"CreatedUserKey": 886,
		"UpdatedUserKey": 886,
		"CreatedUserName": "Ramya G",
		"UpdatedUserName": "Ramya G",
		"IsDriverPay": true
	}
]',
    @Status     BIT = 0,
    @Reason     VARCHAR(1000) = '';

EXEC [dbo].[InsertUpdate_Voucher_V3] 
    @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT;

SELECT @Status AS Status, @Reason AS Reason;

**/
CREATE PROCEDURE [dbo].[InsertUpdate_Voucher_V3]
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

    -- Validate UserKey exists
    IF NOT EXISTS (SELECT 1 FROM dbo.[User] WHERE UserKey = @UserKey)
    BEGIN
        SET @Reason = 'Invalid UserKey';
        RETURN;
    END

    -- Create temp table for items with proper data types
    CREATE TABLE #Items (
        VoucherKey     INT,
        ItemKey        INT,
        RouteKey       INT,
        Qty            DECIMAL(18,4),
        UnitCost       DECIMAL(18,4),
        DriverPay      VARCHAR(2),
        IsNew          BIT DEFAULT 1,
        VoucherLineKey INT,
        Remarks        VARCHAR(1000)
    );

    -- Parse JSON with Pascal case properties
    INSERT INTO #Items (VoucherKey, ItemKey, RouteKey, Qty, UnitCost, DriverPay, IsNew, VoucherLineKey, Remarks)
    SELECT VoucherKey, ItemKey, RouteKey, Qty, UnitCost, DriverPay, IsNew, VoucherLineKey, Remarks
    FROM OPENJSON(@JSONString, '$')
    WITH (
        VoucherKey     INT           '$.VoucherKey',
        ItemKey        INT           '$.ItemKey',
        RouteKey       INT           '$.RouteKey',
        Qty            DECIMAL(18,4) '$.Qty',
        UnitCost       DECIMAL(18,4) '$.UnitCost',
        DriverPay      VARCHAR(2)    '$.DriverPay',
        VoucherLineKey INT           '$.VoucherLineKey',
        IsNew          BIT           '$.IsNew',
        Remarks        VARCHAR(1000) '$.Remarks'
    );

    -- Validate items were parsed
    IF NOT EXISTS (SELECT 1 FROM #Items)
    BEGIN
        SET @Reason = 'Items not found or invalid JSON format';
        RETURN;
    END

    -- Reset VoucherLineKey for new items to prevent audit log issues
    UPDATE #Items
    SET VoucherLineKey = 0
    WHERE IsNew = 1 OR VoucherLineKey IS NULL;

    -- Update unit costs from Item master for items with zero cost
    UPDATE T 
    SET UnitCost = I.UnitCost
    FROM #Items T
        INNER JOIN dbo.Item I ON T.ItemKey = I.ItemKey
    WHERE ISNULL(T.UnitCost, 0) = 0;

    -- Insert new voucher detail records
    INSERT INTO dbo.VoucherDetail (
        VoucherKey, ItemKey, Description, UnitCost, Qty, ExtCost, 
        RouteKey, CreateUserKey, CreateDate, DriverPay
    )
    SELECT 
        T.VoucherKey, 
        T.ItemKey, 
        I.[Description], 
        T.UnitCost, 
        T.Qty, 
        ISNULL(T.UnitCost, 0) * ISNULL(T.Qty, 0), 
        T.RouteKey, 
        @UserKey, 
        GETDATE(), 
        T.DriverPay
    FROM #Items T
        LEFT JOIN dbo.Item I ON T.ItemKey = I.ItemKey
    WHERE T.IsNew = 1;

    -- Create audit log for new items
    INSERT INTO dbo.AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, CommentType, Comments)
    SELECT  
        GETDATE(),
        U.UserName,
        'Container',
        OD.ContainerNo,
        OD.OrderDetailKey,  
        'Text',
        'Item ' + I.Description + ' added in Voucher ' + VH.VoucherNo + ' by ' + U.UserName
    FROM #Items T
        INNER JOIN dbo.Item I ON I.ItemKey = T.ItemKey
        INNER JOIN dbo.VoucherHeader VH ON VH.VoucherKey = T.VoucherKey
        INNER JOIN dbo.[User] U ON U.UserKey = @UserKey
        LEFT JOIN dbo.Routes R ON R.RouteKey = T.RouteKey
        LEFT JOIN dbo.OrderDetail OD ON OD.OrderDetailKey = R.OrderDetailKey
    WHERE T.IsNew = 1;

    -- Create audit log for updated items (only if values actually changed)
    INSERT INTO dbo.AuditLogDetail (DateCreated, CreateUser, RefType, RefId, RefKey, CommentType, Comments)
    SELECT  
        GETDATE(),
        U.UserName,
        'Container',
        OD.ContainerNo,
        OD.OrderDetailKey,
        'Text',
        'Item ' + I.[Description] + ' updated in Voucher ' + VH.VoucherNo + ' by ' + U.UserName
    FROM #Items T
        INNER JOIN dbo.Item I ON I.ItemKey = T.ItemKey
        INNER JOIN dbo.VoucherDetail VD ON VD.VoucherLineKey = T.VoucherLineKey
        INNER JOIN dbo.VoucherHeader VH ON VH.VoucherKey = T.VoucherKey
        INNER JOIN dbo.[User] U ON U.UserKey = @UserKey
        LEFT JOIN dbo.Routes R ON R.RouteKey = VD.RouteKey
        LEFT JOIN dbo.OrderDetail OD ON OD.OrderDetailKey = R.OrderDetailKey
    WHERE T.IsNew = 0
        AND T.VoucherLineKey > 0
        AND (
            ISNULL(VD.UnitCost, 0) <> ISNULL(T.UnitCost, 0)
            OR ISNULL(VD.Qty, 0) <> ISNULL(T.Qty, 0)
            OR ISNULL(VD.DriverPay, '') <> ISNULL(T.DriverPay, '')
            OR ISNULL(VD.RouteKey, 0) <> ISNULL(T.RouteKey, 0)
            OR ISNULL(VD.Remarks, '') <> ISNULL(T.Remarks, '')
        );

    -- Update existing voucher detail records
    UPDATE VD 
    SET 
        ItemKey = T.ItemKey, 
        UnitCost = T.UnitCost,
        Qty = T.Qty,
        ExtCost = ISNULL(T.UnitCost, 0) * ISNULL(T.Qty, 0), 
        DriverPay = T.DriverPay,
        RouteKey = T.RouteKey,
        UpdateUserKey = @UserKey,
        Remarks = T.Remarks,
        UpdateDate = GETDATE()
    FROM dbo.VoucherDetail VD 
        INNER JOIN #Items T ON VD.VoucherLineKey = T.VoucherLineKey
    WHERE T.IsNew = 0 AND T.VoucherLineKey > 0;

    -- Get voucher key for header updates
    DECLARE @VoucherKey INT;
    SELECT TOP 1 @VoucherKey = VoucherKey 
    FROM #Items 
    WHERE VoucherKey > 0;

    -- Update voucher header amounts in single operation
    UPDATE dbo.VoucherHeader
    SET 
        VoucherAmount = (
            SELECT SUM(ISNULL(ExtCost, 0)) 
            FROM dbo.VoucherDetail 
            WHERE VoucherKey = @VoucherKey
        ),
        NPAmount = (
            SELECT SUM(ISNULL(ExtCost, 0)) 
            FROM dbo.VoucherDetail 
            WHERE VoucherKey = @VoucherKey 
                AND ISNULL(DriverPay, 'P') = 'NP'
        ),
        UpdateUserKey = @UserKey,
        UpdateDate = GETDATE()
    WHERE VoucherKey = @VoucherKey;

    -- Clean up route vouchers for routes no longer in use
    DELETE FROM dbo.RouteVouchers
    WHERE VoucherKey = @VoucherKey 
        AND RouteKey NOT IN (
            SELECT DISTINCT RouteKey 
            FROM dbo.VoucherDetail 
            WHERE VoucherKey = @VoucherKey 
                AND RouteKey IS NOT NULL
        );

    -- Success
    SET @Status = 1;
    SET @Reason = 'Success';

    -- Cleanup temp table
    DROP TABLE #Items;
END;