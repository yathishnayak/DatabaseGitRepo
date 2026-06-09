CREATE TABLE [dbo].[TMS_Integration_WorkOrder] (
    [WorkOrderKey]            INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OriginatorCode]          NVARCHAR (100) NULL,
    [ReceiverCode]            NVARCHAR (100) NULL,
    [WorkOrderNumber]         NVARCHAR (200) NULL,
    [Category]                NVARCHAR (50)  NULL,
    [CreatedBy]               NVARCHAR (50)  NULL,
    [WorkOrderDate]           NVARCHAR (100) NULL,
    [HouseAirWayBillNumber]   NVARCHAR (100) NULL,
    [ShipmentReferenceNumber] NVARCHAR (100) NULL,
    [BillOfLadingNumber]      NVARCHAR (100) NULL,
    [Vessel]                  NVARCHAR (100) NULL,
    [Voyage]                  NVARCHAR (50)  NULL,
    [PortOfLoading]           NVARCHAR (100) NULL,
    [PortOfDischarge]         NVARCHAR (100) NULL,
    [Eta]                     NVARCHAR (100) NULL,
    [Shipper]                 NVARCHAR (100) NULL,
    [Broker]                  NVARCHAR (100) NULL,
    [CarrierCode]             NVARCHAR (100) NULL,
    [CreateDate]              DATETIME       NULL,
    CONSTRAINT [PK_TMS_Integration_WorkOrder] PRIMARY KEY CLUSTERED ([WorkOrderKey] ASC)
);

