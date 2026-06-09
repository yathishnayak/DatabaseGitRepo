CREATE TABLE [dbo].[DriverContacts] (
    [DriverContactKey]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DriverKey]          INT           NULL,
    [ContactName]        VARCHAR (100) NULL,
    [ContactDesignation] VARCHAR (100) NULL,
    [ContactNumber]      VARCHAR (100) NULL,
    [ContactEmail]       VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([DriverContactKey] ASC)
);

