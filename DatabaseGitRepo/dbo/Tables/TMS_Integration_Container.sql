CREATE TABLE [dbo].[TMS_Integration_Container] (
    [SiteID]             VARCHAR (50) NOT NULL,
    [DataKey]            INT          NOT NULL,
    [ContainerKey]       INT          NOT NULL,
    [ContainerNo]        VARCHAR (50) NOT NULL,
    [TMS_OrderDetailKey] INT          NULL,
    CONSTRAINT [PK_TMS_Integration_Container] PRIMARY KEY CLUSTERED ([SiteID] ASC, [DataKey] ASC, [ContainerKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Container_SiteID_ContainerKey]
    ON [dbo].[TMS_Integration_Container]([SiteID] ASC, [ContainerKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Container_TMS_OrderDetailKey]
    ON [dbo].[TMS_Integration_Container]([TMS_OrderDetailKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Container_DataKey]
    ON [dbo].[TMS_Integration_Container]([DataKey] ASC) WITH (FILLFACTOR = 90);

