CREATE TABLE [dbo].[TempAll_WRK] (
    [RowID]                   INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderKey]                INT             NOT NULL,
    [OrderDate]               DATE            NOT NULL,
    [OrderDetailkey]          INT             NOT NULL,
    [OrderTypeKey]            SMALLINT        NOT NULL,
    [OrderNo]                 VARCHAR (20)    NOT NULL,
    [ContainerNo]             VARCHAR (20)    NOT NULL,
    [ContainerID]             VARCHAR (50)    NOT NULL,
    [ContainerSizeKey]        SMALLINT        NOT NULL,
    [LastFreeDay]             DATETIME        NULL,
    [PickupDate]              SMALLDATETIME   NULL,
    [PickupTime]              VARCHAR (10)    NULL,
    [DropOffDate]             SMALLDATETIME   NULL,
    [DropOffTime]             VARCHAR (10)    NULL,
    [Status]                  VARCHAR (100)   NOT NULL,
    [StatusKey]               INT             NULL,
    [OrderType]               VARCHAR (100)   NOT NULL,
    [BillOfLading]            VARCHAR (50)    NOT NULL,
    [BookingNo]               VARCHAR (50)    NOT NULL,
    [BrokerRefNo]             VARCHAR (50)    NOT NULL,
    [ContainerSize]           VARCHAR (200)   NOT NULL,
    [Priority]                VARCHAR (100)   NOT NULL,
    [S_AddrName]              VARCHAR (255)   NULL,
    [S_Address1]              VARCHAR (255)   NULL,
    [S_City]                  VARCHAR (255)   NULL,
    [S_State]                 VARCHAR (255)   NULL,
    [S_ZipCode]               VARCHAR (50)    NULL,
    [S_Country]               CHAR (3)        NULL,
    [D_AddrName]              VARCHAR (255)   NULL,
    [D_Address1]              VARCHAR (255)   NULL,
    [D_City]                  VARCHAR (255)   NULL,
    [D_State]                 VARCHAR (255)   NULL,
    [D_ZipCode]               VARCHAR (50)    NULL,
    [D_Country]               CHAR (3)        NULL,
    [Source_AddrName]         VARCHAR (255)   NULL,
    [Source_Address1]         VARCHAR (255)   NULL,
    [Source_City]             VARCHAR (255)   NULL,
    [Source_State]            VARCHAR (255)   NULL,
    [Source_ZipCode]          VARCHAR (50)    NULL,
    [Source_Country]          CHAR (3)        NULL,
    [Destination_AddrName]    VARCHAR (255)   NULL,
    [Destination_Address1]    VARCHAR (255)   NULL,
    [Destination_City]        VARCHAR (255)   NULL,
    [Destination_State]       VARCHAR (255)   NULL,
    [Destination_ZipCode]     VARCHAR (50)    NULL,
    [Destination_Country]     CHAR (3)        NULL,
    [B_AddrName]              VARCHAR (255)   NOT NULL,
    [B_Address1]              VARCHAR (255)   NOT NULL,
    [B_City]                  VARCHAR (255)   NOT NULL,
    [B_State]                 VARCHAR (255)   NOT NULL,
    [B_ZipCode]               VARCHAR (50)    NOT NULL,
    [B_Country]               CHAR (3)        NOT NULL,
    [R_AddrName]              VARCHAR (255)   NOT NULL,
    [R_Address1]              VARCHAR (255)   NOT NULL,
    [R_City]                  VARCHAR (255)   NOT NULL,
    [R_State]                 VARCHAR (255)   NOT NULL,
    [R_ZipCode]               VARCHAR (50)    NOT NULL,
    [R_Country]               CHAR (3)        NOT NULL,
    [VesselETA]               DATETIME        NULL,
    [IsLinked]                BIT             NOT NULL,
    [LinkedContainerNo]       VARCHAR (20)    NOT NULL,
    [NextAction]              VARCHAR (30)    NULL,
    [custKey]                 INT             NOT NULL,
    [BrokerName]              VARCHAR (255)   NULL,
    [Weight]                  DECIMAL (18, 2) NULL,
    [VesselName]              VARCHAR (50)    NULL,
    [SealNo]                  VARCHAR (20)    NOT NULL,
    [CutOffDate]              DATETIME        NULL,
    [IsEmpty]                 BIT             NOT NULL,
    [DriverNotes]             VARCHAR (1000)  NULL,
    [SchedulerNotes]          VARCHAR (1000)  NULL,
    [IsTMF]                   BIT             NOT NULL,
    [isTransLoad]             INT             NOT NULL,
    [CustName]                VARCHAR (100)   NOT NULL,
    [CustID]                  VARCHAR (100)   NOT NULL,
    [CreatedUser]             VARCHAR (50)    NOT NULL,
    [CurLeg]                  VARCHAR (39)    NULL,
    [LocationType]            VARCHAR (50)    NULL,
    [CurLocation]             VARCHAR (255)   NULL,
    [RouteKey]                INT             NULL,
    [AddrName]                VARCHAR (255)   NULL,
    [IsHazardous]             INT             NOT NULL,
    [DocumentCount]           INT             NOT NULL,
    [Int_LFD]                 DATETIME        NULL,
    [IntDataExists]           BIT             NULL,
    [TerminationDate]         DATETIME        NULL,
    [isStreetTurn]            BIT             NULL,
    [StreetTurnSetUser]       VARCHAR (50)    NOT NULL,
    [StreetTurnSetDate]       DATETIME        NULL,
    [CsrKey]                  INT             NULL,
    [CSManagerKey]            INT             NULL,
    [SalePersonKey]           INT             NULL,
    [CsrName]                 VARCHAR (100)   NOT NULL,
    [CSManagerName]           VARCHAR (100)   NOT NULL,
    [CSRManagerKey]           INT             NULL,
    [SalesPersonName]         VARCHAR (100)   NOT NULL,
    [CSRUser]                 INT             NULL,
    [CMUser]                  INT             NULL,
    [SPUser]                  INT             NULL,
    [MarketLocationKey]       INT             NOT NULL,
    [MarketLocation]          VARCHAR (100)   NOT NULL,
    [Consignee]               VARCHAR (100)   NULL,
    [SteamShipLine]           VARCHAR (100)   NULL,
    [SenderInfo]              VARCHAR (100)   NULL,
    [SCAC]                    VARCHAR (50)    NULL,
    [Dischargedate]           VARCHAR (50)    NULL,
    [HoldStatus]              VARCHAR (20)    NULL,
    [LiveDrop]                VARCHAR (1)     NOT NULL,
    [DelayReasonCode]         NVARCHAR (MAX)  NULL,
    [PUDelayedCodeKey]        INT             NULL,
    [AvailableforPickup]      VARCHAR (50)    NULL,
    [AvailableforPickupDate]  VARCHAR (50)    NULL,
    [IsEditDelayReasonCode]   BIT             NULL,
    [PrepullDelayedCodeKEy]   INT             NULL,
    [PrepullDelayedCode]      NVARCHAR (MAX)  NULL,
    [IsEditPrepullReasonCode] BIT             NULL,
    [Location_at_terminal]    VARCHAR (50)    NULL,
    [Tracking]                BIT             NULL,
    [Pod_terminal_name]       VARCHAR (50)    NULL,
    [CTF]                     VARCHAR (50)    NULL,
    [Customs]                 VARCHAR (50)    NULL,
    [Line]                    VARCHAR (50)    NULL,
    [Other]                   VARCHAR (50)    NULL,
    [TMF]                     VARCHAR (50)    NULL,
    [HoldType]                VARCHAR (27)    NOT NULL,
    [Customer]                VARCHAR (100)   NULL,
    [OrderCSR]                VARCHAR (100)   NULL,
    [SalesPersonKey]          INT             NULL,
    [Pickup_appointment_dt]   VARCHAR (50)    NULL,
    [LinkedUserKey]           INT             NULL,
    [DeliveryLocationKey]     INT             NULL,
    [NoTrackingRemarks]       VARCHAR (20)    NOT NULL,
    [PrepullRCKeys]           NVARCHAR (MAX)  NULL,
    [PUDealyedRCKeys]         NVARCHAR (MAX)  NULL,
    [IsDataSelected]          BIT             NULL,
    [IsSelectedStatusKey]     BIT             NULL,
    [ID]                      BIGINT          NULL,
    CONSTRAINT [PK_TempAll_WRK] PRIMARY KEY CLUSTERED ([RowID] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK]
    ON [dbo].[TempAll_WRK]([IsDataSelected] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_1]
    ON [dbo].[TempAll_WRK]([ContainerNo] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_2]
    ON [dbo].[TempAll_WRK]([AvailableforPickup] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_3]
    ON [dbo].[TempAll_WRK]([Pod_terminal_name] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_4]
    ON [dbo].[TempAll_WRK]([CTF] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_5]
    ON [dbo].[TempAll_WRK]([TMF] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_6]
    ON [dbo].[TempAll_WRK]([Line] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_7]
    ON [dbo].[TempAll_WRK]([Other] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_8]
    ON [dbo].[TempAll_WRK]([Customs] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_9]
    ON [dbo].[TempAll_WRK]([Customer] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_10]
    ON [dbo].[TempAll_WRK]([OrderCSR] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_11]
    ON [dbo].[TempAll_WRK]([CSManagerKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_12]
    ON [dbo].[TempAll_WRK]([MarketLocationKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_13]
    ON [dbo].[TempAll_WRK]([SalePersonKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_14]
    ON [dbo].[TempAll_WRK]([Pickup_appointment_dt] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_15]
    ON [dbo].[TempAll_WRK]([LinkedUserKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_16]
    ON [dbo].[TempAll_WRK]([Tracking] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_17]
    ON [dbo].[TempAll_WRK]([DeliveryLocationKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TempAll_WRK_18]
    ON [dbo].[TempAll_WRK]([OrderTypeKey] ASC) WITH (FILLFACTOR = 90);

