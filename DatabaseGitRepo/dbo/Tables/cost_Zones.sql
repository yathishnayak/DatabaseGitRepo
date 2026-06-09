CREATE TABLE [dbo].[cost_Zones] (
    [ZoneKey]    INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ZoneName]   VARCHAR (50) NULL,
    [MarketKey]  INT          NULL,
    [CreateDate] DATETIME     DEFAULT (getdate()) NULL,
    [HighestOf]  VARCHAR (50) NULL,
    [IsPrePull]  BIT          NULL,
    [IsStopOff]  BIT          NULL,
    PRIMARY KEY CLUSTERED ([ZoneKey] ASC)
);

