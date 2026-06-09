CREATE TABLE [dbo].[Cheque_Detail_DELETED] (
    [ChequeDetailKey] INT             NOT NULL,
    [ChequeKey]       INT             NULL,
    [InvoiceKey]      INT             NULL,
    [InvAdjAmount]    DECIMAL (18, 4) NULL,
    [InvAdjDate]      DATETIME        NULL,
    [CreateDate]      DATETIME        NULL,
    [UpdateDate]      DATETIME        NULL,
    [CreateUser]      VARCHAR (50)    NULL,
    [UpdateUser]      VARCHAR (50)    NULL,
    [DeleteUserKey]   INT             NOT NULL,
    [DeleteDate]      DATETIME        NOT NULL
);

