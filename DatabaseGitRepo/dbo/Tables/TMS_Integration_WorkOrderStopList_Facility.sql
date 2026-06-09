CREATE TABLE [dbo].[TMS_Integration_WorkOrderStopList_Facility] (
    [FacilityKey]         INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [StopKey]             INT            NULL,
    [FacilityCode]        NVARCHAR (50)  NULL,
    [StopReferenceNumber] NVARCHAR (50)  NULL,
    [Address1]            NVARCHAR (300) NULL,
    [City]                NVARCHAR (100) NULL,
    [State]               NVARCHAR (50)  NULL,
    [Country]             NVARCHAR (50)  NULL,
    [PostalCode]          NVARCHAR (50)  NULL,
    CONSTRAINT [PK_TMS_Integration_WorkOrderShopList_Facility] PRIMARY KEY CLUSTERED ([FacilityKey] ASC),
    CONSTRAINT [FK_TMS_Integration_WorkOrderShopList_Facility_TMS_Integration_WorkOrderShopList_Facility] FOREIGN KEY ([StopKey]) REFERENCES [dbo].[TMS_Integration_WorkOrderStopList] ([StopKey])
);

