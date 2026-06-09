CREATE TABLE [dbo].[StgApplyInvoices] (
    [RowKey]        INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustId]        VARCHAR (20)    NULL,
    [CheckNo]       VARCHAR (20)    NULL,
    [CheckDate]     DATE            NULL,
    [AdjustDate]    DATE            NULL,
    [InvoiceNo]     VARCHAR (20)    NULL,
    [ApplyAmount]   NUMERIC (18, 2) NULL,
    [CustKey]       INT             NULL,
    [CheckKey]      INT             NULL,
    [InvcKey]       INT             NULL,
    [ProcessStatus] BIT             CONSTRAINT [DF_StgApplyInvoices_ProcessStatus] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_StgApplyInvoices] PRIMARY KEY CLUSTERED ([RowKey] ASC) WITH (FILLFACTOR = 90)
);

