CREATE TABLE [dbo].[OrderExpenseDocuments] (
    [OEDocumentKey]  INT IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderDetailKey] INT NULL,
    [ItemKey]        INT NULL,
    [RouteKey]       INT NULL,
    [DocumentKey]    INT NULL,
    CONSTRAINT [PK__OrderExp__93AD1A9869BD845E] PRIMARY KEY CLUSTERED ([OEDocumentKey] ASC),
    CONSTRAINT [FK_OrderExpenseDocuments_Item] FOREIGN KEY ([ItemKey]) REFERENCES [dbo].[Item] ([ItemKey]),
    CONSTRAINT [FK_OrderExpenseDocuments_OrderDetail] FOREIGN KEY ([OrderDetailKey]) REFERENCES [dbo].[OrderDetail] ([OrderDetailKey]),
    CONSTRAINT [FK_OrderExpenseDocuments_Routes] FOREIGN KEY ([RouteKey]) REFERENCES [dbo].[Routes] ([RouteKey])
);

