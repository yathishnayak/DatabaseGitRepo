CREATE TABLE [dbo].[Cheque_Header_Deleted] (
    [ChequeKey]      INT             NOT NULL,
    [CustKey]        INT             NULL,
    [ChequeRef]      VARCHAR (50)    NULL,
    [ChequeDate]     DATETIME        NULL,
    [ChequeAmount]   DECIMAL (18, 4) NULL,
    [Balance]        DECIMAL (18, 4) NULL,
    [CreateUser]     VARCHAR (50)    NULL,
    [UpdateUser]     VARCHAR (50)    NULL,
    [UpdateDate]     DATETIME        NULL,
    [CreateDate]     DATETIME        NULL,
    [DeletedUserKey] INT             NULL,
    [DeletedDate]    DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([ChequeKey] ASC)
);

