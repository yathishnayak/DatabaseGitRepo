CREATE TABLE [dbo].[ItemsForAccounting] (
    [Itemkey]           INT           NOT NULL,
    [OrderDetailKey]    INT           NOT NULL,
    [CustomerKey]       INT           NULL,
    [CreateDate]        DATETIME2 (7) NULL,
    [CreateUserKey]     INT           NULL,
    [LastUpdateDate]    DATETIME2 (7) NULL,
    [LastUpdateUserKey] INT           NULL,
    CONSTRAINT [PK_ItemsForAccounting_1] PRIMARY KEY CLUSTERED ([Itemkey] ASC, [OrderDetailKey] ASC),
    CONSTRAINT [FK_ItemsForAccounting_Customerkey] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[Customer] ([CustKey]),
    CONSTRAINT [FK_ItemsForAccounting_Itemkey] FOREIGN KEY ([Itemkey]) REFERENCES [dbo].[Item] ([ItemKey])
);

