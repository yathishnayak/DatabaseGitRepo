CREATE TABLE [dbo].[PrePayInvoiceComments] (
    [PPInvoiceKey]  INT            NOT NULL,
    [CommentDate]   DATETIME       NOT NULL,
    [CreateUserKey] INT            NULL,
    [Comment]       NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PrePayInvoiceComment] PRIMARY KEY CLUSTERED ([PPInvoiceKey] ASC, [CommentDate] ASC) WITH (FILLFACTOR = 90)
);

