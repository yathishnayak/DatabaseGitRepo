CREATE TABLE [dbo].[TMS_Integration_Routes] (
    [SiteID]       VARCHAR (50) NOT NULL,
    [DataKey]      INT          NOT NULL,
    [ContainerKey] INT          NOT NULL,
    [StopKey]      INT          NOT NULL,
    [TMS_RouteKey] INT          NULL,
    [TMS_LegKey]   INT          NULL,
    [StopType]     VARCHAR (20) NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Routes_TMS_RouteKey]
    ON [dbo].[TMS_Integration_Routes]([TMS_RouteKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Routes_DataKey]
    ON [dbo].[TMS_Integration_Routes]([DataKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Routes_SiteID]
    ON [dbo].[TMS_Integration_Routes]([SiteID] ASC)
    INCLUDE([DataKey], [ContainerKey], [StopKey], [TMS_RouteKey], [TMS_LegKey], [StopType]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Routes_SiteID_StopKey]
    ON [dbo].[TMS_Integration_Routes]([SiteID] ASC, [StopKey] ASC)
    INCLUDE([TMS_RouteKey]);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Routes_SiteID_DataKey]
    ON [dbo].[TMS_Integration_Routes]([SiteID] ASC, [DataKey] ASC);

