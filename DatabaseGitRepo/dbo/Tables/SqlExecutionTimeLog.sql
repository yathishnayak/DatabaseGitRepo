CREATE TABLE [dbo].[SqlExecutionTimeLog] (
    [UserKEY]        INT           NULL,
    [ProcedureName]  VARCHAR (100) NULL,
    [CommentText]    VARCHAR (500) NULL,
    [AdditionalInfo] VARCHAR (500) NULL,
    [CreatedDate]    DATETIME      NULL
);

