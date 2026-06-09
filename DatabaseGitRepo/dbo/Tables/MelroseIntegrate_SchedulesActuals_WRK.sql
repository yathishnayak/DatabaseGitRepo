CREATE TABLE [dbo].[MelroseIntegrate_SchedulesActuals_WRK] (
    [ID]             VARCHAR (50) NULL,
    [OrderDetailKey] INT          NOT NULL,
    [RouteKey]       INT          NULL,
    [Locationtype]   VARCHAR (10) NULL,
    [OrderKey]       INT          NOT NULL,
    [OrderTypeKey]   SMALLINT     NOT NULL,
    [Loco]           VARCHAR (1)  NOT NULL,
    [LegNo]          SMALLINT     NULL,
    [IsEmpty]        BIT          NULL,
    [IsDryRun]       INT          NULL,
    [LegKey]         SMALLINT     NOT NULL,
    [EventDate]      DATETIME     NULL,
    [ScheduleActual] VARCHAR (1)  NOT NULL,
    [AddrKey]        INT          NULL
);

