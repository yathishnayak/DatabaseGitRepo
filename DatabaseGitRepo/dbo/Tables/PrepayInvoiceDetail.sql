CREATE TABLE [dbo].[PrepayInvoiceDetail] (
    [PPInvoiceKey]     BIGINT          NOT NULL,
    [PPInvoiceLineKey] BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ItemKey]          INT             NULL,
    [UnitPrice]        DECIMAL (18, 5) NULL,
    [Quantity]         DECIMAL (18, 5) NULL,
    [ExtCost]          DECIMAL (18, 5) NULL,
    [CreatedDate]      DATETIME        NULL,
    [CreatedUserKey]   INT             NULL,
    [UpdateDate]       DATETIME        NULL,
    [UpdatedUserKey]   INT             NULL,
    [ContainerNo]      VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([PPInvoiceKey] ASC, [PPInvoiceLineKey] ASC) WITH (FILLFACTOR = 90)
);

