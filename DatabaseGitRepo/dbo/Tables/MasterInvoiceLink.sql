CREATE TABLE [dbo].[MasterInvoiceLink] (
    [MasterInvoiceKey] INT            IDENTITY (1, 1) NOT NULL,
    [MasterInvoiceNo]  NVARCHAR (100) NULL,
    [InvoiceKey]       INT            NULL,
    PRIMARY KEY CLUSTERED ([MasterInvoiceKey] ASC)
);

