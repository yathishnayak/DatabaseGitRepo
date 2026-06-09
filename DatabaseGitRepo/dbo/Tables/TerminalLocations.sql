CREATE TABLE [dbo].[TerminalLocations] (
    [TerminalLocationKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TerminalLocation]    VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([TerminalLocationKey] ASC)
);

