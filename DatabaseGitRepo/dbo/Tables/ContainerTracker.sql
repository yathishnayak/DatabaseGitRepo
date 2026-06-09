CREATE TABLE [dbo].[ContainerTracker] (
    [OrderKey]                    INT           NOT NULL,
    [OrderDetailKey]              INT           NOT NULL,
    [UUID]                        VARCHAR (50)  NULL,
    [Container_journey_start_key] VARCHAR (100) NULL,
    [ContainerNo]                 VARCHAR (50)  NULL,
    [MBLNo]                       VARCHAR (50)  NULL,
    [OrderTypeKey]                INT           NULL,
    [OrderCreateDate]             DATETIME      NULL,
    [ContainerCreateDate]         DATETIME      NULL,
    [IsGnosisTracking]            BIT           CONSTRAINT [DF_Gnosis_ContainerTracker_IsTracking] DEFAULT ((0)) NOT NULL,
    [IsEDI]                       BIT           CONSTRAINT [DF_Gnosis_ContainerTracker_IsEDI] DEFAULT ((0)) NOT NULL,
    [EDI_SiteID]                  VARCHAR (50)  NULL,
    [EDI_DataKey]                 INT           NULL,
    [Port_RouteKey]               INT           NULL,
    [Customer_RouteKey]           INT           NULL,
    [PortReturn_RouteKey]         INT           NULL,
    CONSTRAINT [PK_Gnosis_ContainerTracker_1] PRIMARY KEY CLUSTERED ([OrderKey] ASC, [OrderDetailKey] ASC)
);

