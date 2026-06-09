CREATE TABLE [dbo].[SafeGateIntegration_ActualDepartureDateUpdate] (
    [ActivityId]         INT           NULL,
    [RouteKey]           INT           NULL,
    [ContainerNo]        VARCHAR (50)  NULL,
    [createdDate]        DATETIME      NULL,
    [SafeGateChassisNo]  VARCHAR (50)  NULL,
    [SafegareDriverID]   VARCHAR (20)  NULL,
    [SafegateYardName]   VARCHAR (100) NULL,
    [DestinationYard]    VARCHAR (20)  NULL,
    [SourceYard]         VARCHAR (20)  NULL,
    [ChassisKey]         INT           NULL,
    [DriverKey]          INT           NULL,
    [ChassisNo]          VARCHAR (50)  NULL,
    [Carrier]            VARCHAR (20)  NULL,
    [RouteStatusID]      SMALLINT      NULL,
    [RouteStatus]        VARCHAR (200) NOT NULL,
    [LegID]              VARCHAR (50)  NULL,
    [TMSActualArrival]   DATETIME      NULL,
    [TMSActualDeparture] DATETIME      NULL,
    [YardCheckIn]        DATETIME      NULL,
    [YardCheckOut]       DATETIME      NULL,
    [ActualArrival]      DATETIME      NULL,
    [ActualDeparture]    DATETIME      NULL,
    [ContainerDesc]      VARCHAR (20)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_SafeGateIntegration_ActualDepartureDateUpdate_RouteKey_RouteStatusID]
    ON [dbo].[SafeGateIntegration_ActualDepartureDateUpdate]([RouteKey] ASC, [RouteStatusID] ASC)
    INCLUDE([ActualDeparture]);


GO
CREATE NONCLUSTERED INDEX [IX_SafeGateIntegration_ActualDepartureDateUpdate_RouteStatusID]
    ON [dbo].[SafeGateIntegration_ActualDepartureDateUpdate]([RouteStatusID] ASC)
    INCLUDE([RouteKey], [ActualDeparture]) WITH (FILLFACTOR = 90);

