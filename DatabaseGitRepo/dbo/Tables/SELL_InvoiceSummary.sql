CREATE TABLE [dbo].[SELL_InvoiceSummary] (
    [InvoiceSummaryKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceKey]        INT           NULL,
    [Market]            VARCHAR (50)  NULL,
    [MArketKey]         INT           NULL,
    [Terminal]          VARCHAR (50)  NULL,
    [TerminalKey]       INT           NULL,
    [ZoneKey]           INT           NULL,
    [ZoneName]          VARCHAR (50)  NULL,
    [city]              VARCHAR (50)  NULL,
    [State]             VARCHAR (20)  NULL,
    [CustKey]           INT           NULL,
    [CustName]          VARCHAR (100) NULL,
    [IsDryRun]          BIT           NULL,
    [IsBobTail]         BIT           NULL,
    [CreatedDate]       DATETIME      NULL,
    CONSTRAINT [PK__SELL_Inv__E7F9A02369038AC0] PRIMARY KEY CLUSTERED ([InvoiceSummaryKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_SELL_InvoiceSummary_InvoiceKey]
    ON [dbo].[SELL_InvoiceSummary]([InvoiceKey] ASC) WITH (FILLFACTOR = 90);

