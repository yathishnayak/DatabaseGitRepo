CREATE TABLE [dbo].[OrderHeaderComments] (
    [OrderKey]   INT NOT NULL,
    [CommentKey] INT NOT NULL,
    CONSTRAINT [TMS_OrderHeaderComments_pkey] PRIMARY KEY CLUSTERED ([OrderKey] ASC, [CommentKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_OrderHeaderComments_Comment] FOREIGN KEY ([CommentKey]) REFERENCES [dbo].[Comment] ([CommentKey]),
    CONSTRAINT [FK_OrderHeaderComments_OrderHeader] FOREIGN KEY ([OrderKey]) REFERENCES [dbo].[OrderHeader] ([OrderKey])
);

