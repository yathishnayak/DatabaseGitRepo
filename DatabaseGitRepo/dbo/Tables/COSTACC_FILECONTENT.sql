CREATE TABLE [dbo].[COSTACC_FILECONTENT] (
    [FileProcessKey] INT            NOT NULL,
    [JCONContent]    NVARCHAR (MAX) NULL,
    [DateCreated]    DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([FileProcessKey] ASC)
);

