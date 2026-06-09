CREATE TABLE [dbo].[InvoiceHeader] (
    [InvoiceKey]             INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [InvoiceNo]              VARCHAR (50)    NOT NULL,
    [InvoiceDate]            DATE            NOT NULL,
    [CustKey]                INT             NOT NULL,
    [BillToAddrKey]          INT             NOT NULL,
    [InvoiceAmount]          DECIMAL (18, 2) NOT NULL,
    [DueDate]                DATE            NOT NULL,
    [InvoiceType]            SMALLINT        NULL,
    [CompanyKey]             SMALLINT        CONSTRAINT [DF_InvoiceHeader_CompanyKey] DEFAULT ((1)) NULL,
    [StatusKey]              SMALLINT        CONSTRAINT [DF_InvoiceHeader_StatusKey] DEFAULT ((1)) NOT NULL,
    [CreateUserKey]          INT             NOT NULL,
    [IsInvoiceApproved]      BIT             CONSTRAINT [DF_InvoiceHeader_IsInvoiceApproved] DEFAULT ((0)) NULL,
    [IsPaymentReceived]      BIT             CONSTRAINT [DF_InvoiceHeader_IsPaymentReceived] DEFAULT ((0)) NULL,
    [CreateDate]             DATETIME        CONSTRAINT [DF_InvoiceHeader_CreateDate] DEFAULT (getdate()) NOT NULL,
    [UpdateUserKey]          INT             NULL,
    [UpdateDate]             DATETIME        NULL,
    [InvoiceApprovedUserKey] INT             NULL,
    [InvoiceApprovedDate]    DATETIME        NULL,
    [OrderKey]               INT             NULL,
    [CustomerNote]           VARCHAR (3000)  NULL,
    [InternalNote]           VARCHAR (3000)  NULL,
    [IsPrinted]              BIT             NULL,
    [PrintedUserKey]         INT             NULL,
    [PrintedDate]            DATETIME        NULL,
    [PaymentRecdUserKey]     INT             NULL,
    [PaymentRecdDate]        DATETIME        NULL,
    [IsRevised]              BIT             NULL,
    [RevisionDate]           DATETIME        NULL,
    [RevisionUserKey]        INT             NULL,
    [BrokerRefNo]            VARCHAR (50)    NULL,
    [InvoiceCompanyKey]      INT             NULL,
    [DestinationAddrKey]     INT             NULL,
    [ReasoncodeKey]          INT             NULL,
    [CustApproved]           BIT             NULL,
    [AprovedReasonCodeKey]   INT             NULL,
    CONSTRAINT [PK_InvoiceHeader] PRIMARY KEY CLUSTERED ([InvoiceKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_InvoiceHeader_Billtoaddrkey] FOREIGN KEY ([BillToAddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_InvoiceHeader_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_InvoiceHeader_Custkey] FOREIGN KEY ([CustKey]) REFERENCES [dbo].[Customer] ([CustKey]),
    CONSTRAINT [FK_InvoiceHeader_Invoicekey] FOREIGN KEY ([InvoiceKey]) REFERENCES [dbo].[InvoiceHeader] ([InvoiceKey]),
    CONSTRAINT [FK_InvoiceHeader_InvoiceStatus] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[InvoiceStatus] ([StatusKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_InvoiceHeader_InvoiceNo_StatusKey]
    ON [dbo].[InvoiceHeader]([InvoiceNo] ASC, [StatusKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_InvoiceHeader_CustKey]
    ON [dbo].[InvoiceHeader]([CustKey] ASC)
    INCLUDE([InvoiceAmount], [StatusKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_InvoiceHeader_StatusKey]
    ON [dbo].[InvoiceHeader]([StatusKey] ASC)
    INCLUDE([CreateUserKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_InvoiceHeader_StatusKey_2]
    ON [dbo].[InvoiceHeader]([StatusKey] ASC)
    INCLUDE([InvoiceNo], [InvoiceDate], [InvoiceAmount]);

