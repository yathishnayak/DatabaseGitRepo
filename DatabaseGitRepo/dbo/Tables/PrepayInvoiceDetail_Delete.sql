CREATE TABLE [dbo].[PrepayInvoiceDetail_Delete] (
    [PPInvoiceKey]     BIGINT          NULL,
    [PPInvoiceLineKey] BIGINT          NULL,
    [ItemKey]          INT             NULL,
    [UnitPrice]        DECIMAL (18, 5) NULL,
    [Quantity]         DECIMAL (18, 5) NULL,
    [ExtCost]          DECIMAL (18, 5) NULL,
    [CreatedDate]      DATETIME        NULL,
    [CreatedUserKey]   INT             NULL,
    [UpdateDate]       DATETIME        NULL,
    [UpdatedUserKey]   INT             NULL,
    [ContainerNo]      NVARCHAR (20)   NULL,
    [DeletedBy]        INT             NULL,
    [DeletedOn]        DATETIME        NULL
);

