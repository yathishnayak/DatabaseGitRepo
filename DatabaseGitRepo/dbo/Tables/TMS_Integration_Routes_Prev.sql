CREATE TABLE [dbo].[TMS_Integration_Routes_Prev] (
    [SiteID]       VARCHAR (50) NOT NULL,
    [DataKey]      INT          NOT NULL,
    [ContainerKey] INT          NOT NULL,
    [StopKey]      INT          NOT NULL,
    [TMS_RouteKey] INT          NULL,
    [TMS_LegKey]   INT          NULL
);

