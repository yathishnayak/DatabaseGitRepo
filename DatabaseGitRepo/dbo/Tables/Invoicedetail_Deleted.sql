CREATE TABLE [dbo].[Invoicedetail_Deleted] (
    [InvoicelineKey] INT             NOT NULL,
    [InvoiceKey]     INT             NOT NULL,
    [ItemKey]        INT             NOT NULL,
    [Description]    VARCHAR (255)   NULL,
    [UnitPrice]      DECIMAL (18, 5) NULL,
    [Qty]            DECIMAL (18, 5) NULL,
    [ExtAmt]         DECIMAL (18, 2) NULL,
    [Container]      VARCHAR (50)    NULL,
    [OrderDetailKey] INT             NULL,
    [CreateUserKey]  INT             NOT NULL,
    [CreateDate]     DATETIME        NOT NULL,
    [UpdateUserKey]  INT             NULL,
    [UpdateDate]     DATETIME        NULL,
    [DeleteUserKey]  INT             NOT NULL,
    [DeletedDate]    DATETIME        NULL
);

