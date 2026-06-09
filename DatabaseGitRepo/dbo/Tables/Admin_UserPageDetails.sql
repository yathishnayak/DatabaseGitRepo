CREATE TABLE [dbo].[Admin_UserPageDetails] (
    [UserPageKey] INT IDENTITY (1, 1) NOT NULL,
    [UserKey]     INT NULL,
    [PageKey]     INT NULL,
    CONSTRAINT [PK_Admin_UserPageDetails] PRIMARY KEY CLUSTERED ([UserPageKey] ASC)
);

