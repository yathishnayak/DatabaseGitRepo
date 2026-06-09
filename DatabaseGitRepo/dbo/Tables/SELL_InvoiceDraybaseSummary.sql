CREATE TABLE [dbo].[SELL_InvoiceDraybaseSummary] (
    [InvoiceDraybaseSummaryKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceSummaryKey]         INT             NULL,
    [ContainerNo]               VARCHAR (20)    NULL,
    [DrayBase_Value]            NUMERIC (18, 6) NULL,
    [Margin_Percent]            NUMERIC (18, 6) NULL,
    [Margin_Value]              NUMERIC (18, 6) NULL,
    [DrayBase_Rate]             NUMERIC (18, 6) NULL,
    [FSF_Value]                 NUMERIC (18, 6) NULL,
    [FSF_Percent]               NUMERIC (18, 6) NULL,
    [Draybase_Total]            NUMERIC (18, 6) NULL,
    [Total_value]               NUMERIC (18, 6) NULL,
    [CreatedDate]               DATETIME        NULL,
    [NetRevenue]                NUMERIC (18, 6) NULL,
    [EffectiveDate]             DATETIME        NULL,
    [EffectiveDateFrom]         VARCHAR (50)    NULL,
    [FileName]                  VARCHAR (100)   NULL,
    [DateUploaded]              DATETIME        NULL,
    [UploadedBy]                VARCHAR (100)   NULL,
    [OutputDataKey]             INT             NULL,
    CONSTRAINT [PK__SELL_Inv__C78D5779FEE96C91] PRIMARY KEY CLUSTERED ([InvoiceDraybaseSummaryKey] ASC) WITH (FILLFACTOR = 90)
);

