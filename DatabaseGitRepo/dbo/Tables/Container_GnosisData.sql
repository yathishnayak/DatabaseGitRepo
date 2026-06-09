CREATE TABLE [dbo].[Container_GnosisData] (
    [PKey]                         INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderDetailKey]               INT            NOT NULL,
    [MBL]                          NVARCHAR (100) NULL,
    [SSLKey]                       INT            NULL,
    [Vessel]                       NVARCHAR (100) NULL,
    [ETA_ATA]                      NVARCHAR (100) NULL,
    [LFD]                          NVARCHAR (100) NULL,
    [Size_Type]                    INT            NULL,
    [ContainerStatus]              INT            NULL,
    [Available]                    BIT            NULL,
    [Hold]                         INT            NULL,
    [HoldType]                     INT            NULL,
    [HoldNote]                     NVARCHAR (500) NULL,
    [AvailableDate]                DATETIME       NULL,
    [MBLChangedByUser]             BIT            NULL,
    [SSLChangedByUser]             BIT            NULL,
    [VesselChangedByUser]          BIT            NULL,
    [ETA_ATAChangedByUser]         BIT            NULL,
    [LFDChangedByUser]             BIT            NULL,
    [Size_TypeChangedByUser]       BIT            NULL,
    [ContainerStatusChangedByUser] BIT            NULL,
    [AvailableChangedByUser]       BIT            NULL,
    [HoldChangedByUser]            BIT            NULL,
    [HoldTypeChangedByUser]        BIT            NULL,
    [AvailableDateChangedByUser]   BIT            NULL,
    CONSTRAINT [PK_Container_GnosisData] PRIMARY KEY CLUSTERED ([PKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Container_GnosisData_OrderDetailKey]
    ON [dbo].[Container_GnosisData]([OrderDetailKey] ASC)
    INCLUDE([Vessel], [AvailableDate], [MBL], [SSLKey], [ETA_ATA], [LFD], [Size_Type], [ContainerStatus], [Available], [Hold], [HoldType], [HoldNote]);

