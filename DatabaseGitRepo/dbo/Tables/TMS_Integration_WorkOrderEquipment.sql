CREATE TABLE [dbo].[TMS_Integration_WorkOrderEquipment] (
    [EquipmentKey]       INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WorkOrderKey]       INT            NOT NULL,
    [EquipmentNumber]    NVARCHAR (100) NULL,
    [EquipmentTypeCode]  NVARCHAR (100) NULL,
    [PieceCount]         NVARCHAR (100) NULL,
    [GrossWeight]        NVARCHAR (100) NULL,
    [WeightUOM]          NVARCHAR (50)  NULL,
    [Volume]             NVARCHAR (100) NULL,
    [VolumeUOM]          NVARCHAR (50)  NULL,
    [FreightDescription] NVARCHAR (300) NULL,
    [IsHazmat]           NVARCHAR (50)  NULL,
    [SealNumber]         NVARCHAR (100) NULL,
    CONSTRAINT [PK_TMS_Integration_WorkOrderEquipment] PRIMARY KEY CLUSTERED ([EquipmentKey] ASC),
    CONSTRAINT [FK_TMS_Integration_WorkOrderEquipment_TMS_Integration_WorkOrderEquipment] FOREIGN KEY ([WorkOrderKey]) REFERENCES [dbo].[TMS_Integration_WorkOrder] ([WorkOrderKey])
);

