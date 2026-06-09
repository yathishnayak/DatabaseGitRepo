CREATE TABLE [dbo].[TMS_Integration_WorkOrderStopList] (
    [StopKey]           INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WorkOrderKey]      INT            NOT NULL,
    [StopType]          NVARCHAR (100) NULL,
    [StopName]          NVARCHAR (300) NULL,
    [StopNumber]        NVARCHAR (50)  NULL,
    [EquipmentNumber]   NVARCHAR (100) NULL,
    [EquipmentTypeCode] NVARCHAR (50)  NULL,
    CONSTRAINT [PK_TMS_Integration_WorkOrderShopList] PRIMARY KEY CLUSTERED ([StopKey] ASC),
    CONSTRAINT [FK_TMS_Integration_WorkOrderShopList_TMS_Integration_WorkOrder] FOREIGN KEY ([WorkOrderKey]) REFERENCES [dbo].[TMS_Integration_WorkOrder] ([WorkOrderKey])
);

