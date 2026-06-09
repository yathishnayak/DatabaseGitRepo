CREATE TABLE [dbo].[Menu] (
    [MenuKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MenuName]   VARCHAR (255) NOT NULL,
    [StatusKey]  SMALLINT      NOT NULL,
    [StatusDate] SMALLDATETIME NOT NULL,
    [CompanyKey] SMALLINT      CONSTRAINT [DF_Menu_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Menu] PRIMARY KEY CLUSTERED ([MenuKey] ASC),
    CONSTRAINT [FK_Menu_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Menu_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

