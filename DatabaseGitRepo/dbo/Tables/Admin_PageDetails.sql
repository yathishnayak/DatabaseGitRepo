CREATE TABLE [dbo].[Admin_PageDetails] (
    [PageKey]   INT          IDENTITY (1, 1) NOT NULL,
    [PageName]  VARCHAR (50) NULL,
    [MenuKey]   INT          NULL,
    [RouteName] VARCHAR (50) NULL,
    [OrderBy]   INT          NULL,
    CONSTRAINT [PK_Admin_PageDetails] PRIMARY KEY CLUSTERED ([PageKey] ASC)
);

