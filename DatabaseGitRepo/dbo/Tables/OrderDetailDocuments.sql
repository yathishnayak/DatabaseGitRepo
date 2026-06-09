CREATE TABLE [dbo].[OrderDetailDocuments] (
    [OrderDetailKey] INT NOT NULL,
    [DocumentKey]    INT NOT NULL,
    CONSTRAINT [TMS_OrderDetailDocuments_pkey] PRIMARY KEY CLUSTERED ([OrderDetailKey] ASC, [DocumentKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TMS_OrderDetailDocuments_Document] FOREIGN KEY ([DocumentKey]) REFERENCES [dbo].[Document] ([DocumentKey]),
    CONSTRAINT [FK_TMS_OrderDetailDocuments_TMS_OrderDetail] FOREIGN KEY ([OrderDetailKey]) REFERENCES [dbo].[OrderDetail] ([OrderDetailKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailDocuments_DocumentKey]
    ON [dbo].[OrderDetailDocuments]([DocumentKey] ASC);

