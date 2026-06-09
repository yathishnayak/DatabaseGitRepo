CREATE PROCEDURE [dbo].[Update_DispatchActionData_Chassis_Yogish]
    @RouteKey           INT,
    @ChassisNo          VARCHAR(30),
    @ChassisType        VARCHAR(30),
    @ChassisKey         INT,
    @CategoryKey        INT,
    @UserKey            INT,
    @OutPut             BIT OUTPUT,
    @IsReadyToComplete  BIT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET FMTONLY OFF; 

        DECLARE 
            @OrderDetailKey         INT,
            @DriverAsgStatusKey     SMALLINT,
            @Status_LegCompleted    SMALLINT,
            @Status_DeliveryPending SMALLINT,
            @Status_DispatchInProgress SMALLINT,
            @JasonString            NVARCHAR(MAX),
            @LegFromLocation        VARCHAR(100),
            @LegToLocation          VARCHAR(100),
            @CustKey                INT,
            @LegKey                 INT,
            @OrderKey               INT;

        -- Preload commonly used status values
        SELECT 
            @DriverAsgStatusKey = (SELECT [Status] FROM dbo.RouteStatus WHERE [Description] = 'DriverAssigned'),
            @Status_LegCompleted = (SELECT [Status] FROM dbo.RouteStatus WHERE [Description] = 'Leg Completed'),
            @Status_DeliveryPending = (SELECT [Status] FROM dbo.RouteStatus WHERE [Description] = 'Delivery Pending'),
            @Status_DispatchInProgress = (SELECT [Status] FROM dbo.OrderDetailStatus WHERE [Description] = 'Dispatch InProgress' AND IsActive = 1);

        -- Fetch primary Route data
        ;WITH RouteInfo AS (
            SELECT 
                R.RouteKey,
                R.LegKey,
                R.OrderKey,
                R.OrderDetailKey,
                R.ChassisCategoryKey,
                L.FromLocation,
                L.ToLocation,
                OH.CustKey
            FROM dbo.Routes R
            LEFT JOIN dbo.Leg L ON R.LegKey = L.LegKey
            LEFT JOIN dbo.OrderHeader OH ON R.OrderKey = OH.OrderKey
            WHERE R.RouteKey = @RouteKey
        )
        SELECT 
            @OrderDetailKey = RI.OrderDetailKey,
            @LegKey = RI.LegKey,
            @OrderKey = RI.OrderKey,
            @LegFromLocation = RI.FromLocation,
            @LegToLocation = RI.ToLocation,
            @CustKey = RI.CustKey
        FROM RouteInfo RI;

        -- Update chassis data for primary RouteKey
        UPDATE dbo.Routes
        SET 
            ChassisNo           = @ChassisNo,
            ChassisType         = @ChassisType,
            ChassisKey          = @ChassisKey,
            ChassisCategoryKey  = @CategoryKey,
            UpdateUserKey       = @UserKey,
            LastUpdateDate      = GETDATE()
        WHERE RouteKey = @RouteKey;

        -- Chassis split for Century - current leg
        IF ((@LegFromLocation = 'Port' OR @LegToLocation = 'Port') AND @CustKey = 3402 AND @CategoryKey IN (2, 3))
        BEGIN
            SET @JasonString = '{"RouteKey":'+CAST(@RouteKey AS VARCHAR)+',"IsChassisSplit":1,"OrderDetailKey":'+CAST(@OrderDetailKey AS VARCHAR)+'}';
            EXEC Container_IsChassisSplit @UserKey, @JasonString, '', 0, '';
            UPDATE dbo.Routes
            SET IsChassisSplit = 1, ChassisSplitBy = @UserKey, ChassisSplitDate = GETDATE()
            WHERE RouteKey = @RouteKey;
        END

        -- Update chassis data on other legs
        UPDATE R
        SET 
            ChassisNo =           CASE WHEN ISNULL(R.ChassisNo, '') <> '' THEN R.ChassisNo ELSE @ChassisNo END,
            ChassisType =         CASE WHEN ISNULL(R.ChassisType, '') <> '' THEN R.ChassisType ELSE @ChassisType END,
            ChassisKey =          CASE WHEN ISNULL(R.ChassisKey, 0) <> 0 THEN R.ChassisKey ELSE @ChassisKey END,
            ChassisCategoryKey =  CASE WHEN ISNULL(R.ChassisCategoryKey, 0) <> 0 THEN R.ChassisCategoryKey ELSE @CategoryKey END
        FROM dbo.Routes R
        WHERE 
            R.OrderDetailKey = @OrderDetailKey
            AND R.RouteKey <> @RouteKey
            AND R.[Status] <> @Status_LegCompleted;

        -- Multi-leg Chassis Split using WHILE loop
        DECLARE @SplitRoutes TABLE (
            RowNum INT IDENTITY(1,1) PRIMARY KEY,
            RouteKey INT,
            JasonString NVARCHAR(MAX)
        );

        INSERT INTO @SplitRoutes (RouteKey, JasonString)
        SELECT 
            R.RouteKey,
            '{"RouteKey":'+CAST(R.RouteKey AS VARCHAR)+',"IsChassisSplit":1,"OrderDetailKey":'+CAST(@OrderDetailKey AS VARCHAR)+'}'
        FROM dbo.Routes R
        JOIN dbo.Leg L ON R.LegKey = L.LegKey
        JOIN dbo.OrderHeader OH ON R.OrderKey = OH.OrderKey
        WHERE 
            R.OrderDetailKey = @OrderDetailKey
            AND R.RouteKey <> @RouteKey
            AND R.[Status] <> @Status_LegCompleted
            AND (L.FromLocation = 'Port' OR L.ToLocation = 'Port')
            AND OH.CustKey = 3402
            AND R.ChassisCategoryKey IN (2, 3);

        DECLARE @TotalRows INT = (SELECT COUNT(*) FROM @SplitRoutes);
        DECLARE @CurrentRow INT = 1;
        DECLARE @SplitRouteKey INT;
        DECLARE @SplitJasonString NVARCHAR(MAX);

        WHILE @CurrentRow <= @TotalRows
        BEGIN
            SELECT 
                @SplitRouteKey = RouteKey,
                @SplitJasonString = JasonString
            FROM @SplitRoutes
            WHERE RowNum = @CurrentRow;

            EXEC Container_IsChassisSplit @UserKey, @SplitJasonString, '', 0, '';

            UPDATE dbo.Routes
            SET 
                IsChassisSplit = 1,
                ChassisSplitBy = @UserKey,
                ChassisSplitDate = GETDATE()
            WHERE RouteKey = @SplitRouteKey;

            SET @CurrentRow += 1;
        END

        -- Container Status Update
        IF EXISTS (
            SELECT 1
            FROM dbo.Routes RT
            JOIN dbo.RouteStatus RTS ON RTS.[Status] = RT.[Status]
            WHERE RT.OrderDetailKey = @OrderDetailKey
                AND RTS.[Description] <> 'Leg Completed'
                AND (
                    ISNULL(RT.DriverKey, 0) > 0 OR 
                    ISNULL(RT.ChassisNo, '') <> '' OR 
                    ISNULL(RT.ActualDeparture, '1970-01-01') <> '1970-01-01' OR 
                    ISNULL(RT.ActualArrival, '1970-01-01') <> '1970-01-01'
                )
        )
        BEGIN
            UPDATE dbo.OrderDetail
            SET [Status] = @Status_DispatchInProgress,
                StatusDate = GETDATE()
            WHERE OrderDetailKey = @OrderDetailKey;
        END

        -- Leg Status Update
        IF EXISTS (
            SELECT 1 
            FROM dbo.Routes RT
            JOIN dbo.RouteStatus RTS ON RTS.[Status] = RT.[Status]
            WHERE RT.RouteKey = @RouteKey AND RTS.[Description] <> 'Leg Completed'
        )
        BEGIN
            UPDATE dbo.Routes
            SET [Status] = @Status_DeliveryPending
            WHERE RouteKey = @RouteKey AND [Status] <> @DriverAsgStatusKey;
        END

        -- Final route completion check
        SELECT @IsReadyToComplete = dbo.FN_IsRouteComplete(@RouteKey);
        SET @OutPut = 1;
END