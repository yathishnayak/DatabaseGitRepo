CREATE TABLE [dbo].[GeoEvents] (
    [EventKey]  INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [EventName] VARCHAR (100) NULL,
    [ApplnName] VARCHAR (50)  NULL,
    CONSTRAINT [PK_GeoEvents] PRIMARY KEY CLUSTERED ([EventKey] ASC)
);

