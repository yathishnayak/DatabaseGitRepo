
CREATE PROCEDURE MelroseIntegrate_GetOrderDetails -- MelroseIntegrate_GetOrderDetails '{"OrderKey":158335,"DataKey":62558,"SiteID":"flexport","TMS_OrderKey":158335,"WorkOrdernumber":"002397176","WorKOrderDate":"2025-02-03T20:33:00","status":6,"ContainerData":[{"OrderDetailKey":194087,"ContainerKey":62558,"ContainerNo":"GAOU7676739","status":10,"Orderkey":158335,"STOPDATA":[{"RouteKey":632017,"LegKey":37,"StopKey":155154,"TMS_LegKey":37,"TMS_RouteKey":632017,"LocationType":"ST","OrderDetailKey":194087,"SchedDelivery":"2025-02-12T17:00:00","ActualDelivery":"2025-02-12T10:30:18.343","StopNum":2},{"RouteKey":646650,"LegKey":19,"StopKey":162448,"TMS_LegKey":19,"TMS_RouteKey":646650,"LocationType":"EP","OrderDetailKey":194087,"SchedPickup":"2025-02-21T15:29:00","ActualPickup":"2025-02-21T15:29:27.443","StopNum":4},{"RouteKey":646650,"LegKey":19,"StopKey":162453,"TMS_LegKey":19,"TMS_RouteKey":646650,"LocationType":"RT","OrderDetailKey":194087,"SchedDelivery":"2025-02-21T15:29:00","ActualDelivery":"2025-02-21T15:29:27.823","StopNum":5}]}]}'
(
  @json NVARCHAR(MAX) = ''
  )

  AS

-- Temp table for Order level
CREATE TABLE #Orders (
    OrderKey INT,
    DataKey INT,
    SiteID NVARCHAR(100),
    TMS_OrderKey INT,
    WorkOrdernumber NVARCHAR(50),
    WorKOrderDate DATETIME,
    Status INT
);

INSERT INTO #Orders
SELECT OrderKey, DataKey, SiteID, TMS_OrderKey, WorkOrdernumber, WorKOrderDate, Status
FROM OPENJSON(@json)
WITH (
    OrderKey INT,
    DataKey INT,
    SiteID NVARCHAR(100),
    TMS_OrderKey INT,
    WorkOrdernumber NVARCHAR(50),
    WorKOrderDate DATETIME,
    Status INT
);

-- Temp table for Container level
CREATE TABLE #Containers (
    OrderKey INT,
    OrderDetailKey INT,
    ContainerKey INT,
    ContainerNo NVARCHAR(50),
    Status INT
);

INSERT INTO #Containers
SELECT o.OrderKey, c.OrderDetailKey, c.ContainerKey, c.ContainerNo, c.Status
FROM #Orders o
CROSS APPLY OPENJSON(@json, '$.ContainerData')
WITH (
    OrderDetailKey INT,
    ContainerKey INT,
    ContainerNo NVARCHAR(50),
    Status INT,
    OrderKey INT
) c;

-- Temp table for Stop level
CREATE TABLE #Stops (
    OrderKey INT,
    ContainerKey INT,
    RouteKey INT,
    LegKey INT,
    StopKey INT,
    TMS_LegKey INT,
    TMS_RouteKey INT,
    LocationType NVARCHAR(10),
    OrderDetailKey INT,
    SchedDelivery DATETIME,
    ActualDelivery DATETIME,
    SchedPickup DATETIME,
    ActualPickup DATETIME,
    StopNum INT
);

INSERT INTO #Stops
SELECT c.OrderKey, c.ContainerKey, s.RouteKey, s.LegKey, s.StopKey, s.TMS_LegKey,
       s.TMS_RouteKey, s.LocationType, s.OrderDetailKey, s.SchedDelivery, s.ActualDelivery,
       s.SchedPickup, s.ActualPickup, s.StopNum
FROM #Containers c
CROSS APPLY OPENJSON(@json, '$.ContainerData[0].STOPDATA')
WITH (
    RouteKey INT,
    LegKey INT,
    StopKey INT,
    TMS_LegKey INT,
    TMS_RouteKey INT,
    LocationType NVARCHAR(10),
    OrderDetailKey INT,
    SchedDelivery DATETIME,
    ActualDelivery DATETIME,
    SchedPickup DATETIME,
    ActualPickup DATETIME,
    StopNum INT
) s;

--SELECT * FROM #Orders;
--SELECT * FROM #Containers;
SELECT * FROM #Stops;
