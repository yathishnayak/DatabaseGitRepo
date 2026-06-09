CREATE TABLE [dbo].[SafeGateIntegration_ContainerDetails_WRK] (
    [ActivityId]    INT           NULL,
    [YardName]      VARCHAR (100) NULL,
    [ContainerNo]   VARCHAR (50)  NULL,
    [ContainerDesc] VARCHAR (20)  NULL,
    [Effect]        SMALLINT      NULL,
    [CreatedDate]   DATETIME      NULL,
    [ChassisKey]    INT           NULL,
    [ChassisNo]     VARCHAR (50)  NULL,
    [ChassisType]   VARCHAR (100) NULL,
    [IsProcessed]   BIT           NULL,
    [DriverKey]     INT           NULL,
    [DriverId]      VARCHAR (20)  NULL,
    [FirstName]     VARCHAR (100) NULL,
    [LastName]      VARCHAR (100) NULL,
    [CDLNo]         VARCHAR (100) NULL,
    [RouteKey]      INT           NULL,
    [DriverTag]     VARCHAR (50)  NULL,
    [IsUpdated]     BIT           NULL,
    [TMSYardName]   VARCHAR (100) NULL,
    [Remarks]       VARCHAR (500) NULL,
    [ContainerType] VARCHAR (20)  NULL
);

