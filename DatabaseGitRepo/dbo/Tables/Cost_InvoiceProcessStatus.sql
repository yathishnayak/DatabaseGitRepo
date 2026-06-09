CREATE TABLE [dbo].[Cost_InvoiceProcessStatus] (
    [InvoiceKey] INT           NOT NULL,
    [ProcStatus] BIT           NULL,
    [ProcReason] VARCHAR (500) NULL,
    [CreateDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([InvoiceKey] ASC) WITH (FILLFACTOR = 90)
);

