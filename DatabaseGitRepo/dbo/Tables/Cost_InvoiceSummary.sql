CREATE TABLE [dbo].[Cost_InvoiceSummary] (
    [InvoiceSummaryKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceKey]        INT             NULL,
    [PrePull_value]     NUMERIC (18, 3) NULL,
    [YardShuttle_value] NUMERIC (18, 3) NULL,
    [StopOff_value]     NUMERIC (18, 3) NULL,
    [DrayBase_Value]    NUMERIC (18, 3) NULL,
    [Accessorial_Value] NUMERIC (18, 3) NULL,
    [Total_value]       NUMERIC (18, 3) NULL,
    [CreatedDate]       DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([InvoiceSummaryKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_Cost_InvoiceSummary_InvoiceKey]
    ON [dbo].[Cost_InvoiceSummary]([InvoiceKey] ASC) WITH (FILLFACTOR = 90);

