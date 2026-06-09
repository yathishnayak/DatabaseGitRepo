CREATE TABLE [dbo].[Comment] (
    [CommentKey]        INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]       VARCHAR (MAX)  NULL,
    [CreateDate]        DATETIME2 (7)  NULL,
    [CreateUserKey]     INT            NULL,
    [isDeleted]         BIT            DEFAULT ((0)) NULL,
    [DeleteDate]        DATETIME       NULL,
    [DeleteUserKey]     INT            NULL,
    [OriginalComment]   NVARCHAR (MAX) NULL,
    [UpdateDate]        DATETIME       NULL,
    [UpdateUserKey]     INT            NULL,
    [IsPermanentDelete] BIT            NULL,
    [IsUsercomment]     BIT            NULL,
    [ParentCommentKey]  INT            NULL,
    CONSTRAINT [Comment_PKey] PRIMARY KEY CLUSTERED ([CommentKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_Comment_CreateDate]
    ON [dbo].[Comment]([CreateDate] ASC);

