CREATE TABLE [dbo].[DriverMessageTemplateFields] (
    [FieldKey]   INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FieldValue] VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([FieldKey] ASC)
);

