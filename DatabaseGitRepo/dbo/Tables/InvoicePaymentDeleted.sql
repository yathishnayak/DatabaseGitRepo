CREATE TABLE [dbo].[InvoicePaymentDeleted] (
    [PaymentKey]       INT             NOT NULL,
    [InvoiceKey]       INT             NULL,
    [PaymentDate]      DATETIME        NULL,
    [PaidAmount]       DECIMAL (10, 2) NULL,
    [UserKey]          INT             NULL,
    [PaymentType]      VARCHAR (50)    NULL,
    [PaymentReference] VARCHAR (250)   NULL,
    [Note]             VARCHAR (250)   NULL,
    [ChequeKey]        INT             NULL,
    [DeleteUserKey]    INT             NULL,
    [DeleteDate]       DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([PaymentKey] ASC) WITH (FILLFACTOR = 90)
);

