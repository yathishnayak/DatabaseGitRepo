CREATE TABLE [dbo].[Invoice_Log] (
    [InvoiceKey]    INT            NULL,
    [LogDate]       DATETIME       NULL,
    [LogText]       VARCHAR (1000) NULL,
    [ActionUserKey] INT            NULL
);

