CREATE TABLE [dbo].[TempPickupDelivery] (
    [OrderKey]       INT           NOT NULL,
    [StopKey]        INT           NOT NULL,
    [OrderDetailKey] INT           NOT NULL,
    [TMS_RouteKey]   INT           NULL,
    [OrderTypeKey]   SMALLINT      NOT NULL,
    [OrderType]      VARCHAR (100) NOT NULL,
    [FromLocation]   VARCHAR (50)  NULL,
    [TMS_LegKey]     SMALLINT      NOT NULL,
    [RouteKey]       INT           NULL,
    [ToLocation]     VARCHAR (50)  NULL,
    [LegNo]          SMALLINT      NULL,
    [IsEmpty]        BIT           NULL,
    [LegKey]         SMALLINT      NOT NULL,
    [SiteID]         VARCHAR (20)  NOT NULL,
    [StopType]       VARCHAR (10)  NOT NULL,
    [SchedPickup]    DATETIME      NULL,
    [ActualPickup]   DATETIME      NULL,
    [SchedDelivery]  DATETIME      NULL,
    [ActualDelivery] DATETIME      NULL,
    [StopNum]        INT           NULL
);

