CREATE TABLE [dbo].[SELL_InvoiceItemSummary] (
    [InvoiceItemSummaryKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceSummaryKey]     INT             NULL,
    [ContainerNo]           VARCHAR (20)    NULL,
    [RecordSL]              INT             NULL,
    [MarketLocation]        VARCHAR (50)    NULL,
    [itemkey]               INT             NULL,
    [LineItem]              VARCHAR (100)   NULL,
    [BvsNB]                 VARCHAR (5)     NULL,
    [Rate]                  DECIMAL (18, 6) NULL,
    [CostGroup]             VARCHAR (50)    NULL,
    [EffectiveDate]         DATETIME        NULL,
    [EffectiveDateFrom]     VARCHAR (50)    NULL,
    [CreatedDate]           DATETIME        NULL,
    [FileName]              VARCHAR (100)   NULL,
    [DateUploaded]          DATETIME        NULL,
    [UploadedBy]            VARCHAR (100)   NULL,
    CONSTRAINT [PK__SELL_Inv__EE93B33EB2DB43E6] PRIMARY KEY CLUSTERED ([InvoiceItemSummaryKey] ASC)
);

