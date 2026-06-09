CREATE TABLE [dbo].[RouteInvoice] (
    [OrderDetailKey] INT NOT NULL,
    [InvoiceKey]     INT NOT NULL,
    CONSTRAINT [PK_RouteInvoice] PRIMARY KEY CLUSTERED ([OrderDetailKey] ASC, [InvoiceKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_RouteInvoice_Invoice] FOREIGN KEY ([InvoiceKey]) REFERENCES [dbo].[InvoiceHeader] ([InvoiceKey]),
    CONSTRAINT [FK_RouteInvoice_OrderDetail] FOREIGN KEY ([OrderDetailKey]) REFERENCES [dbo].[OrderDetail] ([OrderDetailKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_RouteInvoice_InvoiceKey]
    ON [dbo].[RouteInvoice]([InvoiceKey] ASC);

