CREATE TABLE [dbo].[OrderInvoices] (
    [OrderKey]   INT NOT NULL,
    [InvoiceKey] INT NOT NULL,
    CONSTRAINT [TMS_OrderInvoices_pkey] PRIMARY KEY CLUSTERED ([OrderKey] ASC, [InvoiceKey] ASC),
    CONSTRAINT [FK_TMS_OrderInvoices_InvoiceHeader] FOREIGN KEY ([InvoiceKey]) REFERENCES [dbo].[InvoiceHeader] ([InvoiceKey]),
    CONSTRAINT [FK_TMS_OrderInvoices_TMS_OrderHeader] FOREIGN KEY ([OrderKey]) REFERENCES [dbo].[OrderHeader] ([OrderKey])
);

