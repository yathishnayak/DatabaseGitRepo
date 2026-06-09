CREATE TABLE [dbo].[Sell_InvoiceBobtailSummary] (
    [InvoiceBobtailKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceSummaryKey] INT             NOT NULL,
    [ContainerNo]       VARCHAR (20)    NOT NULL,
    [BobtailFormat]     VARCHAR (50)    NULL,
    [BobtailRate]       NUMERIC (18, 6) NULL,
    [BobtailCalc]       NUMERIC (18, 6) NULL,
    [EffectiveDate]     DATETIME        NULL,
    [EffectiveDateFrom] VARCHAR (50)    NULL,
    [FileName]          VARCHAR (100)   NULL,
    [DateUploaded]      DATETIME        NULL,
    [UploadedBy]        VARCHAR (100)   NULL,
    [OutputDataKey]     INT             NULL,
    CONSTRAINT [PK_Sell_InvoiceBobtailSummary] PRIMARY KEY CLUSTERED ([InvoiceBobtailKey] ASC)
);

