CREATE TABLE [dbo].[OrderDetailComments_Log] (
    [OrderDetailKey] INT          NOT NULL,
    [CommentKey]     INT          NOT NULL,
    [ActionType]     VARCHAR (30) NULL,
    [ActionUser]     VARCHAR (50) NULL,
    [ActionDate]     DATETIME     NULL
);

