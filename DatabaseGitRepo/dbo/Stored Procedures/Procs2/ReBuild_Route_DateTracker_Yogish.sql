CREATE PROC [dbo].[ReBuild_Route_DateTracker_Yogish]
AS
BEGIN
    SET NOCOUNT ON;

    -- Prepare temp table with the same structure
    SELECT TOP 0 * INTO #Temp FROM Routes_DateTracker;

    -- Insert missing route dates into temp table
    INSERT INTO #Temp
    SELECT 
        RT.RouteKey,
        DT.DateType,
        DT.DateValue,
        RT.CreateDate,
        ISNULL(RT.UpdateUserKey, RT.CreateUserKey) AS CreateUser
    FROM Routes RT
    CROSS APPLY (
        SELECT 'SP' AS DateType, ISNULL(RT.PickupDateTo, RT.PickupDateFrom) AS DateValue WHERE RT.PickupDateFrom IS NOT NULL
        UNION ALL
        SELECT 'SD', ISNULL(RT.DeliveryDateTo, RT.DeliveryDateFrom) WHERE RT.DeliveryDateFrom IS NOT NULL
        UNION ALL
        SELECT 'AP', RT.ActualDeparture WHERE RT.ActualDeparture IS NOT NULL
        UNION ALL
        SELECT 'AD', RT.ActualArrival WHERE RT.ActualArrival IS NOT NULL
    ) DT
    LEFT JOIN Routes_DateTracker RTD ON RT.RouteKey = RTD.RouteKey AND RTD.DateType = DT.DateType
    WHERE RTD.RouteKey IS NULL;

    -- Bulk insert from temp into main table
    INSERT INTO Routes_DateTracker (RouteKey, DateType, DateTime, CreateDate, CreateUser)
    SELECT RouteKey, DateType, DateTime, CreateDate, CreateUser FROM #Temp;

    DROP TABLE #Temp;

    -- Update existing Route_DateTracker entries if dates have changed
    UPDATE RTD SET DateTime = ISNULL(RT.PickupDateTo, RT.PickupDateFrom)
    FROM Routes_DateTracker RTD
    JOIN Routes RT ON RT.RouteKey = RTD.RouteKey
    WHERE RTD.DateType = 'SP' AND ISNULL(RT.PickupDateTo, RT.PickupDateFrom) <> RTD.DateTime;

    UPDATE RTD SET DateTime = ISNULL(RT.DeliveryDateTo, RT.DeliveryDateFrom)
    FROM Routes_DateTracker RTD
    JOIN Routes RT ON RT.RouteKey = RTD.RouteKey
    WHERE RTD.DateType = 'SD' AND ISNULL(RT.DeliveryDateTo, RT.DeliveryDateFrom) <> RTD.DateTime;

    UPDATE RTD SET DateTime = RT.ActualDeparture
    FROM Routes_DateTracker RTD
    JOIN Routes RT ON RT.RouteKey = RTD.RouteKey
    WHERE RTD.DateType = 'AP' AND RT.ActualDeparture <> RTD.DateTime;

    UPDATE RTD SET DateTime = RT.ActualArrival
    FROM Routes_DateTracker RTD
    JOIN Routes RT ON RT.RouteKey = RTD.RouteKey
    WHERE RTD.DateType = 'AD' AND RT.ActualArrival <> RTD.DateTime;

    -- Final sync
    EXEC [TMS_INTEGRATION_UPDATE_TKT_ROUTESDATANEW];
END
