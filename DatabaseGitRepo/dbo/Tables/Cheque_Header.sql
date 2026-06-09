CREATE TABLE [dbo].[Cheque_Header] (
    [ChequeKey]    INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustKey]      INT             NULL,
    [ChequeRef]    VARCHAR (50)    NULL,
    [ChequeDate]   DATETIME        NULL,
    [ChequeAmount] DECIMAL (18, 4) NULL,
    [Balance]      DECIMAL (18, 4) NULL,
    [CreateUser]   VARCHAR (50)    NULL,
    [UpdateUser]   VARCHAR (50)    NULL,
    [UpdateDate]   DATETIME        NULL,
    [CreateDate]   DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([ChequeKey] ASC) WITH (FILLFACTOR = 90)
);

