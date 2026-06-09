CREATE TABLE [dbo].[CommentLog] (
    [LogKey]          INT           NULL,
    [CommentKey]      INT           NULL,
    [OriginalComment] VARCHAR (MAX) NULL,
    [ModifiedComment] VARCHAR (MAX) NULL,
    [CreatedDate]     DATETIME      NULL,
    [CreatedUserKey]  INT           NULL,
    [Isdeleted]       BIT           NULL
);

