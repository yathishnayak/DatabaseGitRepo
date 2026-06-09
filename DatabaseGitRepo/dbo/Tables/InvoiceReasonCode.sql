CREATE TABLE [dbo].[InvoiceReasonCode] (
    [ReasoncodeKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ReasonCode]    VARCHAR (100) NULL,
    [Status]        BIT           NULL,
    PRIMARY KEY CLUSTERED ([ReasoncodeKey] ASC)
);

