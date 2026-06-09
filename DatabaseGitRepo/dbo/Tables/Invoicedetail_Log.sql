CREATE TABLE [dbo].[Invoicedetail_Log] (
    [InvoicelineKey] INT             NOT NULL,
    [InvoiceKey]     INT             NOT NULL,
    [ItemKey]        INT             NULL,
    [Description]    VARCHAR (255)   NULL,
    [UnitPrice]      DECIMAL (18, 5) NULL,
    [Qty]            DECIMAL (18, 2) NULL,
    [ExtAmt]         DECIMAL (18, 2) NULL,
    [Container]      VARCHAR (255)   NULL,
    [OrderDetailKey] INT             NULL,
    [CreateUserKey]  INT             NULL,
    [CreateDate]     DATETIME        NULL,
    [UpdateUserKey]  INT             NULL,
    [UpdateDate]     DATETIME        NULL,
    [ActionType]     VARCHAR (30)    NULL,
    [ActionUser]     VARCHAR (50)    NULL,
    [ActionDate]     DATETIME        NULL
);

