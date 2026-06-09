CREATE TABLE [dbo].[ConatinerTypeComment] (
    [CommentType]      INT          IDENTITY (1, 1) NOT NULL,
    [OrderDetailKey]   INT          NULL,
    [ContainerTypeKey] INT          NULL,
    [CommentKey]       VARCHAR (50) NULL
);

