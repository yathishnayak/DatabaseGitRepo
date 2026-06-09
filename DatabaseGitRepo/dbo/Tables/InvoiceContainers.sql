CREATE TABLE [dbo].[InvoiceContainers] (
    [InvoiceKey]      INT          NOT NULL,
    [OrderDetailsKey] INT          NOT NULL,
    [ContainerNo]     VARCHAR (20) NULL,
    [TerminationDate] DATETIME     NULL,
    CONSTRAINT [PK_InvoiceContainers] PRIMARY KEY CLUSTERED ([InvoiceKey] ASC, [OrderDetailsKey] ASC),
    CONSTRAINT [FK_InvoiceContainers_InvoiceContainers] FOREIGN KEY ([InvoiceKey], [OrderDetailsKey]) REFERENCES [dbo].[InvoiceContainers] ([InvoiceKey], [OrderDetailsKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_InvoiceContainers_InvoiceKey]
    ON [dbo].[InvoiceContainers]([InvoiceKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_InvoiceContainers_OrderDetailsKey]
    ON [dbo].[InvoiceContainers]([OrderDetailsKey] ASC)
    INCLUDE([InvoiceKey], [ContainerNo]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_InvoiceContainers_ContainerNo]
    ON [dbo].[InvoiceContainers]([ContainerNo] ASC);

