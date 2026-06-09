CREATE TABLE [dbo].[Customer] (
    [CustKey]            INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustID]             VARCHAR (100)   NOT NULL,
    [CustName]           VARCHAR (100)   NOT NULL,
    [AddrKey]            INT             NOT NULL,
    [CreateDate]         DATETIME        NOT NULL,
    [CustomerGroup]      SMALLINT        NULL,
    [StatusKey]          SMALLINT        CONSTRAINT [DF_Customer_StatusKey] DEFAULT ((1)) NOT NULL,
    [StatusDate]         DATETIME        CONSTRAINT [DF_Customer_StatusDate] DEFAULT (getdate()) NOT NULL,
    [CreditCheck]        BIT             NULL,
    [CreditLimit]        DECIMAL (18, 2) NULL,
    [CreditStatus]       SMALLINT        NULL,
    [Ach_Required]       BIT             CONSTRAINT [DF_Customer_Ach_Required] DEFAULT ((0)) NULL,
    [PaymentTermsKey]    SMALLINT        NOT NULL,
    [CompanyKey]         SMALLINT        CONSTRAINT [DF_Customer_CompanyKey] DEFAULT ((1)) NOT NULL,
    [BillToAddrKey]      INT             NULL,
    [IsFactored]         BIT             NULL,
    [Notes]              VARCHAR (1000)  NULL,
    [IsActive]           BIT             NULL,
    [IsDelete]           BIT             NULL,
    [CSRKey]             INT             NULL,
    [CSRManagerKey]      INT             NULL,
    [SalesPersonKey]     INT             NULL,
    [MarketLocationKey]  INT             NULL,
    [CustomerSegmentKey] INT             NULL,
    [CustomerNotes]      NVARCHAR (MAX)  NULL,
    [CustomerCompanyKey] INT             NULL,
    [RateTypeKey]        INT             NULL,
    [IncludeFSF]         BIT             NULL,
    [RatePercent]        DECIMAL (18, 2) NULL,
    [IsMaster]           BIT             NULL,
    [MasterCustKey]      INT             NULL,
    [IsKeyAccount]       BIT             NULL,
    [ExpiryMonths]       INT             NULL,
    CONSTRAINT [Customer_pkey] PRIMARY KEY CLUSTERED ([CustKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Customer_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Customer_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Customer_PmtTerms] FOREIGN KEY ([PaymentTermsKey]) REFERENCES [dbo].[PaymentTerms] ([PaymentTermsKey]),
    CONSTRAINT [FK_Customer_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_Customer_SalesPersonKey]
    ON [dbo].[Customer]([SalesPersonKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Customer_CustID]
    ON [dbo].[Customer]([CustID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_515_514_Customer]
    ON [dbo].[Customer]([StatusKey] ASC)
    INCLUDE([CustID], [CustName], [AddrKey], [CreditCheck], [CreditLimit], [CreditStatus], [Ach_Required], [IsFactored]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_1303_1302_Customer]
    ON [dbo].[Customer]([StatusKey] ASC)
    INCLUDE([CustID], [CustName], [AddrKey], [IsFactored]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Customer_IsActive_IsDelete_IsMaster]
    ON [dbo].[Customer]([IsActive] ASC, [IsDelete] ASC, [IsMaster] ASC)
    INCLUDE([CustID], [CustName]);


GO
CREATE NONCLUSTERED INDEX [IX_Customer_CustName]
    ON [dbo].[Customer]([CustName] ASC);

