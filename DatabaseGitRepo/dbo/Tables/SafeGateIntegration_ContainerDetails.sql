CREATE TABLE [dbo].[SafeGateIntegration_ContainerDetails] (
    [ActivityId]        INT           NULL,
    [YardName]          VARCHAR (100) NULL,
    [ContainerNo]       VARCHAR (50)  NULL,
    [ContainerDesc]     VARCHAR (20)  NULL,
    [Effect]            SMALLINT      NULL,
    [CreatedDate]       DATETIME      NULL,
    [ChassisKey]        INT           NULL,
    [ChassisNo]         VARCHAR (50)  NULL,
    [ChassisType]       VARCHAR (100) NULL,
    [IsProcessed]       BIT           NULL,
    [DriverKey]         INT           NULL,
    [DriverId]          VARCHAR (20)  NULL,
    [FirstName]         VARCHAR (100) NULL,
    [LastName]          VARCHAR (100) NULL,
    [CDLNo]             VARCHAR (100) NULL,
    [RouteKey]          INT           NULL,
    [DriverTag]         VARCHAR (50)  NULL,
    [IsUpdated]         BIT           NULL,
    [TMSYardName]       VARCHAR (100) NULL,
    [Remarks]           VARCHAR (500) NULL,
    [TMSYardID]         VARCHAR (20)  NULL,
    [DestinationYardID] VARCHAR (20)  NULL,
    [SourceYardID]      VARCHAR (20)  NULL,
    [DataPulledDate]    DATETIME      NULL,
    [ContainerType]     VARCHAR (20)  NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_SafeGateIntegration_ContainerDetails_ActivityId]
    ON [dbo].[SafeGateIntegration_ContainerDetails]([ActivityId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_11268_11267_SafeGateIntegration_ContainerDet]
    ON [dbo].[SafeGateIntegration_ContainerDetails]([ContainerNo] ASC)
    INCLUDE([ActivityId], [YardName], [ContainerDesc], [Effect], [CreatedDate], [ChassisNo], [DriverId]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_SafeGateIntegration_ContainerDetails_CreatedDate]
    ON [dbo].[SafeGateIntegration_ContainerDetails]([CreatedDate] ASC)
    INCLUDE([ContainerNo]);

