CREATE TABLE [dbo].[InvoiceDetail_SellPriceLog] (
    [InvoiceLineKey] INT             NULL,
    [LogDate]        DATETIME        NULL,
    [ItemKey]        INT             NULL,
    [UnitPrice]      DECIMAL (18, 5) NULL,
    [Qty]            DECIMAL (18, 5) NULL,
    [ExtAmt]         DECIMAL (18, 5) NULL,
    [Container]      VARCHAR (50)    NULL,
    [Charges]        DECIMAL (18, 5) NULL,
    [SellPrice]      DECIMAL (18, 5) NULL,
    [BvsNB]          VARCHAR (2)     NULL,
    [FreeTime]       SMALLINT        NULL,
    [Minval]         INT             NULL,
    [MaxVal]         INT             NULL,
    [UserKey]        INT             NULL
);

