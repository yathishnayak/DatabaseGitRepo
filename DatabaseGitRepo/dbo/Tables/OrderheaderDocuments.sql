CREATE TABLE [dbo].[OrderheaderDocuments] (
    [DocumentKey] INT NOT NULL,
    [OrderKey]    INT NOT NULL,
    CONSTRAINT [PK_TMS_OrderheaderDocuments] PRIMARY KEY CLUSTERED ([DocumentKey] ASC, [OrderKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TMS_OrderheaderDocuments_OrderKey] FOREIGN KEY ([OrderKey]) REFERENCES [dbo].[OrderHeader] ([OrderKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderheaderDocuments_OrderKey]
    ON [dbo].[OrderheaderDocuments]([OrderKey] ASC) WITH (FILLFACTOR = 90);

