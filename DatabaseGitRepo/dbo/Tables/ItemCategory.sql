CREATE TABLE [dbo].[ItemCategory] (
    [CategoryKey] SMALLINT     IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]        VARCHAR (50) NULL,
    [StatusKey]   SMALLINT     CONSTRAINT [DF_ItemCategory_StatusKey] DEFAULT ((1)) NULL,
    [CompanyKey]  INT          CONSTRAINT [DF_ItemCategory_CompanyKey] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_ItemCategory] PRIMARY KEY CLUSTERED ([CategoryKey] ASC)
);

