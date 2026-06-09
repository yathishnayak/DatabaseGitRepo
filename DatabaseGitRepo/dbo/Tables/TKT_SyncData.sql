CREATE TABLE [dbo].[TKT_SyncData] (
    [TKT_DataKey]                 INT           NOT NULL,
    [TKT_WorkOrderNumber]         VARCHAR (100) NULL,
    [TKT_ShipmentReferenceNumber] VARCHAR (100) NULL,
    [TKT_IsAccepted]              BIT           NULL,
    [TKT_ContainerKey]            INT           NOT NULL,
    [TKT_EquipmentNumber]         VARCHAR (50)  NULL,
    [TMS_OrderKey]                INT           NULL,
    [TMS_BrokerRefNo]             VARCHAR (50)  NULL,
    [TMS_OrderDetailKey]          INT           NULL,
    [TMS_ContainerNo]             VARCHAR (20)  NULL,
    [SiteID]                      VARCHAR (8)   NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_SyncData_TKT_DataKey_SiteID]
    ON [dbo].[TKT_SyncData]([TKT_DataKey] ASC, [SiteID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_SyncData_SiteID]
    ON [dbo].[TKT_SyncData]([SiteID] ASC)
    INCLUDE([TKT_DataKey], [TMS_OrderKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TKT_SyncData_SiteID_SiteID]
    ON [dbo].[TKT_SyncData]([SiteID] ASC)
    INCLUDE([TKT_DataKey], [TKT_ContainerKey], [TMS_OrderDetailKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-SiteID]
    ON [dbo].[TKT_SyncData]([SiteID] ASC);

