CREATE TABLE [dbo].[TKT_RouteData] (
    [OrderDetailKey] INT           NOT NULL,
    [RouteKey]       INT           NULL,
    [OrderTypeKey]   SMALLINT      NOT NULL,
    [OrderType]      VARCHAR (100) NOT NULL,
    [FromLocation]   VARCHAR (50)  NULL,
    [ToLocation]     VARCHAR (50)  NULL,
    [LegNo]          SMALLINT      NULL,
    [IsEmpty]        BIT           NULL,
    [LegKey]         SMALLINT      NOT NULL,
    [StopType]       BIGINT        NULL,
    [FacilityCode]   VARCHAR (2)   NOT NULL,
    [SiteID]         VARCHAR (20)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_RouteData_OrderDetailKey_RouteKey]
    ON [dbo].[TKT_RouteData]([OrderDetailKey] ASC, [RouteKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_RouteData_RouteKey]
    ON [dbo].[TKT_RouteData]([RouteKey] ASC) WITH (FILLFACTOR = 90);

