CREATE TABLE [dbo].[ManualInvoiceComments] (
    [MInvoiceKey]   INT            NOT NULL,
    [CommentDate]   DATETIME       NOT NULL,
    [CreateUserKey] INT            NULL,
    [Comment]       NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_ManualInvoiceComment] PRIMARY KEY CLUSTERED ([MInvoiceKey] ASC, [CommentDate] ASC) WITH (FILLFACTOR = 90)
);

