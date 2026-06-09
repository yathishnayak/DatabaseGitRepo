CREATE TABLE [dbo].[Admin_MenuDetails] (
    [MenuKey]  INT          NOT NULL,
    [MenuName] VARCHAR (50) NULL,
    [OrderBy]  INT          NULL,
    CONSTRAINT [PK_Admin_MenuDetails] PRIMARY KEY CLUSTERED ([MenuKey] ASC)
);

