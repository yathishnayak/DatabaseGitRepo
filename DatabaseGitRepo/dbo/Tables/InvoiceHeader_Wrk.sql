CREATE TABLE [dbo].[InvoiceHeader_Wrk] (
    [InvoiceNo]              VARCHAR (50)    NOT NULL,
    [InvoiceDate]            DATE            NOT NULL,
    [CustKey]                INT             NOT NULL,
    [BillToAddrKey]          INT             NOT NULL,
    [InvoiceAmount]          DECIMAL (18, 2) NOT NULL,
    [DueDate]                DATE            NOT NULL,
    [InvoiceType]            SMALLINT        NULL,
    [CompanyKey]             SMALLINT        CONSTRAINT [DF_InvoiceHeader_Wrk_CompanyKey] DEFAULT ((1)) NULL,
    [StatusKey]              SMALLINT        CONSTRAINT [DF_InvoiceHeader_Wrk_StatusKey] DEFAULT ((1)) NOT NULL,
    [CreateUserKey]          INT             NOT NULL,
    [IsInvoiceApproved]      BIT             CONSTRAINT [DF_InvoiceHeader_Wrk_IsInvoiceApproved] DEFAULT ((0)) NULL,
    [IsPaymentReceived]      BIT             CONSTRAINT [DF_InvoiceHeader_Wrk_IsPaymentReceived] DEFAULT ((0)) NULL,
    [CreateDate]             DATETIME        CONSTRAINT [DF_InvoiceHeader_Wrk_CreateDate] DEFAULT (getdate()) NOT NULL,
    [UpdateUserKey]          INT             NULL,
    [UpdateDate]             DATETIME        NULL,
    [InvoiceApprovedUserKey] INT             NULL,
    [InvoiceApprovedDate]    DATETIME        NULL,
    CONSTRAINT [FK_InvoiceHeader_Wrk_Billtoaddrkey] FOREIGN KEY ([BillToAddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_InvoiceHeader_Wrk_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_InvoiceHeader_Wrk_Custkey] FOREIGN KEY ([CustKey]) REFERENCES [dbo].[Customer] ([CustKey]),
    CONSTRAINT [FK_InvoiceHeader_Wrk_InvoiceStatus] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[InvoiceStatus] ([StatusKey])
);

