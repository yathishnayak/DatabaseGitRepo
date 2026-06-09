CREATE TABLE [dbo].[Cheque_Detail] (
    [ChequeDetailKey] INT             IDENTITY (1, 1) NOT NULL,
    [ChequeKey]       INT             NULL,
    [InvoiceKey]      INT             NULL,
    [InvAdjAmount]    DECIMAL (18, 4) NULL,
    [InvAdjDate]      DATETIME        NULL,
    [CreateDate]      DATETIME        NULL,
    [UpdateDate]      DATETIME        NULL,
    [CreateUser]      VARCHAR (50)    NULL,
    [UpdateUser]      VARCHAR (50)    NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Cheque_Detail_ChequeKey]
    ON [dbo].[Cheque_Detail]([ChequeKey] ASC) WITH (FILLFACTOR = 90);

