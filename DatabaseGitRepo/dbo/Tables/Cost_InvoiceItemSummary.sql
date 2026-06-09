CREATE TABLE [dbo].[Cost_InvoiceItemSummary] (
    [InvoiceItemSummaryKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceSummaryKey]     INT             NULL,
    [itemkey]               INT             NULL,
    [LineItem]              VARCHAR (100)   NULL,
    [Per]                   VARCHAR (50)    NULL,
    [UnitCost]              DECIMAL (18, 2) NULL,
    [Qty]                   INT             NULL,
    [TotalCost]             DECIMAL (18, 2) NULL,
    [CreatedDate]           DATETIME        NULL,
    [ContainerNo]           VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([InvoiceItemSummaryKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Cost_InvoiceItemSummary_InvoiceSummaryKey]
    ON [dbo].[Cost_InvoiceItemSummary]([InvoiceSummaryKey] ASC) WITH (FILLFACTOR = 90);

