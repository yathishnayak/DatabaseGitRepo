CREATE TABLE [dbo].[ManualInvoiceHeader] (
    [MInvoiceKey]         BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MInvoiceNo]          VARCHAR (20)    NULL,
    [MInvoiceDate]        DATETIME        NOT NULL,
    [MInvoiceAmount]      DECIMAL (18, 4) NULL,
    [OrderKey]            INT             NULL,
    [CustomerKey]         INT             NULL,
    [BillToAddressKey]    INT             NULL,
    [MInvoiceSentDate]    DATETIME        NULL,
    [MInvoiceConfirmDate] DATETIME        NULL,
    [CreatedDate]         DATETIME        NULL,
    [CreatedUserKey]      INT             NULL,
    [UpdateDate]          DATETIME        NULL,
    [UpdatedUserKey]      INT             NULL,
    [OrderNo]             VARCHAR (50)    NULL,
    [StatusKey]           INT             NULL,
    [InternalNotes]       VARCHAR (2000)  NULL,
    [CustomerNotes]       VARCHAR (2000)  NULL,
    [RevisionDate]        DATETIME        NULL,
    [RevisionUserKey]     INT             NULL,
    [InternalNote]        VARCHAR (MAX)   NULL,
    [PreVoidStatusKey]    INT             NULL,
    [VoidedDate]          DATETIME        NULL,
    [IsVoid]              BIT             DEFAULT ((0)) NULL,
    [VoidedUserKey]       INT             NULL,
    [BrokerRef]           VARCHAR (50)    NULL,
    [SteamShipLineKey]    INT             NULL,
    [SteamShipLineRef]    VARCHAR (100)   NULL,
    [OriginalInvoiceNo]   VARCHAR (50)    NULL,
    [InvoiceCompanyKey]   INT             NULL,
    [InvoiceType]         VARCHAR (10)    CONSTRAINT [DF_ManualInvoiceHeader_InvoiceType] DEFAULT ('M') NULL,
    PRIMARY KEY CLUSTERED ([MInvoiceKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_ManualInvoiceHeader_MInvoiceNo_StatusKey]
    ON [dbo].[ManualInvoiceHeader]([MInvoiceNo] ASC, [StatusKey] ASC) WITH (FILLFACTOR = 90);

