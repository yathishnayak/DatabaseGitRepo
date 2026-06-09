CREATE TABLE [dbo].[VersionHistory] (
    [VersionNumber] VARCHAR (10)  NOT NULL,
    [VersionDate]   DATETIME      NOT NULL,
    [VersionDetail] VARCHAR (MAX) NULL,
    [CreateUserKey] INT           NULL,
    [CreateDate]    DATETIME      NULL,
    [UpdateUserKey] INT           NULL,
    [UpdateDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([VersionDate] ASC) WITH (FILLFACTOR = 90)
);

