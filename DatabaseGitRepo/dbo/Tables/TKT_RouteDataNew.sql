CREATE TABLE [dbo].[TKT_RouteDataNew] (
    [OrderDetailKey]        INT          NOT NULL,
    [RouteKey]              INT          NOT NULL,
    [LocationType]          VARCHAR (5)  NOT NULL,
    [OrderKey]              INT          NOT NULL,
    [OrderTypeKey]          INT          NULL,
    [Location]              VARCHAR (20) NULL,
    [TMS_Legno]             INT          NULL,
    [IsEmpty]               BIT          NULL,
    [IsDryRun]              BIT          NULL,
    [TMS_LegKey]            INT          NULL,
    [TKT_StopType]          INT          NULL,
    [TKT_FacilityCode]      VARCHAR (5)  NULL,
    [SiteID]                VARCHAR (20) NULL,
    [AppliedOrderDetailKey] INT          CONSTRAINT [DF_TKT_RouteDataNew_AppliedOrderDetailKey] DEFAULT ((0)) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_RouteDataNew_RouteKey_LocationType]
    ON [dbo].[TKT_RouteDataNew]([RouteKey] ASC, [LocationType] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_RouteDataNew_OrderKey]
    ON [dbo].[TKT_RouteDataNew]([OrderKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_RouteDataNew_LocationType]
    ON [dbo].[TKT_RouteDataNew]([LocationType] ASC)
    INCLUDE([RouteKey], [OrderKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex_RouteKey]
    ON [dbo].[TKT_RouteDataNew]([RouteKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_RouteDataNew_OrderDetailKey_LocationType]
    ON [dbo].[TKT_RouteDataNew]([OrderDetailKey] ASC, [LocationType] ASC)
    INCLUDE([RouteKey], [TMS_LegKey]);

