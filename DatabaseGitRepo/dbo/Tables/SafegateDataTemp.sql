CREATE TABLE [dbo].[SafegateDataTemp] (
    [ActivityId]  INT           NOT NULL,
    [YardName]    VARCHAR (20)  NOT NULL,
    [ContainerNo] NVARCHAR (50) NULL,
    [Description] VARCHAR (50)  NULL,
    [Effect]      SMALLINT      NULL,
    [CreateDate]  DATETIME      NULL,
    [ChassisKey]  INT           NULL,
    [ChassisNo]   VARCHAR (50)  NULL,
    [ChassisType] VARCHAR (100) NULL,
    [DriverKey]   INT           NULL,
    [DriverId]    VARCHAR (20)  NULL,
    [FirstName]   VARCHAR (100) NULL,
    [LastName]    VARCHAR (100) NULL,
    [CDLNo]       VARCHAR (100) NULL,
    [DriverTag]   VARCHAR (50)  NULL
);

