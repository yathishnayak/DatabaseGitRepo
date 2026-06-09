CREATE TABLE [dbo].[CommentDocuments] (
    [DocumentKey] INT IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CommentKey]  INT NOT NULL,
    CONSTRAINT [CommentDocuments_pkey] PRIMARY KEY CLUSTERED ([DocumentKey] ASC),
    CONSTRAINT [FK_CommentDocuments_comment] FOREIGN KEY ([CommentKey]) REFERENCES [dbo].[Comment] ([CommentKey]),
    CONSTRAINT [FK_CommentDocuments_Document] FOREIGN KEY ([DocumentKey]) REFERENCES [dbo].[Document] ([DocumentKey])
);

