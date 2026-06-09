CREATE TABLE [dbo].[TMS_Customer] (
    [CustKey]         INT             NOT NULL,
    [CustID]          VARCHAR (100)   NOT NULL,
    [CustName]        VARCHAR (100)   NOT NULL,
    [AddrKey]         INT             NOT NULL,
    [CreateDate]      DATETIME        NOT NULL,
    [CustomerGroup]   SMALLINT        NULL,
    [StatusKey]       SMALLINT        NOT NULL,
    [StatusDate]      DATETIME        NOT NULL,
    [CreditCheck]     BIT             NULL,
    [CreditLimit]     DECIMAL (18, 2) NULL,
    [CreditStatus]    SMALLINT        NULL,
    [Ach_Required]    BIT             NULL,
    [PaymentTermsKey] SMALLINT        NOT NULL,
    [CompanyKey]      SMALLINT        NOT NULL,
    [BillToAddrKey]   INT             NULL,
    [IsFactored]      BIT             NULL,
    [Notes]           VARCHAR (1000)  NULL
);

