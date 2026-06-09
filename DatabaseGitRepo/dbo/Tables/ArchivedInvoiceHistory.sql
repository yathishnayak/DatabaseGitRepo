CREATE TABLE [dbo].[ArchivedInvoiceHistory] (
    [ArchivedKey]           INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderKey]              INT          NULL,
    [InvoiceKey]            INT          NULL,
    [OrderDetailKey]        INT          NULL,
    [InvoiceNo]             VARCHAR (20) NULL,
    [PrevOrderDetailStatus] INT          NULL,
    [PrevInvoiceStatus]     INT          NULL,
    [ArchivedDate]          DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([ArchivedKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-InvoiceKey]
    ON [dbo].[ArchivedInvoiceHistory]([InvoiceKey] ASC) WITH (FILLFACTOR = 90);

