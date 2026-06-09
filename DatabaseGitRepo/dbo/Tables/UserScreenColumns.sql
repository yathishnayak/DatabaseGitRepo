CREATE TABLE [dbo].[UserScreenColumns] (
    [UserKey]       INT            NOT NULL,
    [ScreenName]    VARCHAR (100)  NOT NULL,
    [ColumnsStatus] NVARCHAR (MAX) NULL,
    [CreateDate]    DATETIME       NULL,
    [UpdateDate]    DATETIME       NULL,
    CONSTRAINT [PK_UserScreenColumns] PRIMARY KEY CLUSTERED ([UserKey] ASC, [ScreenName] ASC) WITH (FILLFACTOR = 90)
);

