CREATE TABLE [dbo].[ItemType] (
    [ItemTypeKey]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ItemType]          VARCHAR (50)  NULL,
    [Description]       VARCHAR (500) NOT NULL,
    [CreateDate]        DATETIME2 (7) NULL,
    [CreateUserKey]     INT           NULL,
    [LastUpdateDate]    DATETIME2 (7) NULL,
    [LastUpdateUserKey] INT           NULL,
    [CompanyKey]        SMALLINT      CONSTRAINT [DF_ItemType_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ItemType] PRIMARY KEY CLUSTERED ([ItemTypeKey] ASC),
    CONSTRAINT [FK_ItemType_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey])
);

