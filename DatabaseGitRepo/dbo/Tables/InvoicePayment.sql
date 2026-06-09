CREATE TABLE [dbo].[InvoicePayment] (
    [PaymentKey]       INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceKey]       INT             NULL,
    [PaymentDate]      DATETIME        NULL,
    [PaidAmount]       DECIMAL (10, 2) NULL,
    [UserKey]          INT             NULL,
    [PaymentType]      VARCHAR (50)    NULL,
    [PaymentReference] VARCHAR (250)   NULL,
    [Note]             VARCHAR (250)   NULL,
    [ChequeKey]        INT             NULL,
    [ChequeDetailKey]  INT             NULL,
    [InvoiceType]      VARCHAR (1)     NULL,
    [CreatedDate]      DATETIME        NULL,
    [StatusKey]        INT             NULL,
    CONSTRAINT [PK__InvoiceP__A7050C0E23F118A1] PRIMARY KEY CLUSTERED ([PaymentKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_InvoicePayment_InvoiceKey]
    ON [dbo].[InvoicePayment]([InvoiceKey] ASC) WITH (FILLFACTOR = 90);

