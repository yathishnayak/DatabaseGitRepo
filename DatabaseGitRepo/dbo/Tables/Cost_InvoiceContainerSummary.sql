CREATE TABLE [dbo].[Cost_InvoiceContainerSummary] (
    [InvoiceContainerSummaryKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceSummaryKey]          INT             NULL,
    [ContainerNo]                VARCHAR (20)    NULL,
    [PrePull_value]              NUMERIC (18, 3) NULL,
    [YardShuttle_value]          NUMERIC (18, 3) NULL,
    [StopOff_value]              NUMERIC (18, 3) NULL,
    [DrayBase_Value]             NUMERIC (18, 3) NULL,
    [Accessorial_Value]          NUMERIC (18, 3) NULL,
    [Total_value]                NUMERIC (18, 3) NULL,
    [CreatedDate]                DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([InvoiceContainerSummaryKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_Cost_InvoiceContainerSummary_InvoiceSummaryKey]
    ON [dbo].[Cost_InvoiceContainerSummary]([InvoiceSummaryKey] ASC);

