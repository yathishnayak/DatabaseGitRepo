CREATE TABLE [dbo].[ManualInvoiceDetail] (
    [MInvoiceKey]     BIGINT          NOT NULL,
    [MInvoiceLineKey] BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ItemKey]         INT             NULL,
    [UnitPrice]       DECIMAL (18, 5) NULL,
    [Quantity]        DECIMAL (18, 5) NULL,
    [ExtCost]         DECIMAL (18, 5) NULL,
    [CreatedDate]     DATETIME        NULL,
    [CreatedUserKey]  INT             NULL,
    [UpdateDate]      DATETIME        NULL,
    [UpdatedUserKey]  INT             NULL,
    [ContainerNo]     VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([MInvoiceKey] ASC, [MInvoiceLineKey] ASC) WITH (FILLFACTOR = 90)
);

