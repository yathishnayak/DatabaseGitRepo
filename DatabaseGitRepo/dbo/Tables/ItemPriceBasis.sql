CREATE TABLE [dbo].[ItemPriceBasis] (
    [PriceBasisKey] SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PriceBasisID]  VARCHAR (50)  NOT NULL,
    [Description]   VARCHAR (200) NULL,
    [StatusKey]     SMALLINT      CONSTRAINT [DF_ItemPriceBasis_StatusKey] DEFAULT ((1)) NOT NULL,
    [StatusDate]    DATETIME      CONSTRAINT [DF_ItemPriceBasis_StatusDate] DEFAULT (getdate()) NOT NULL,
    [CreateUserKey] INT           NOT NULL,
    [CreateDate]    DATETIME      CONSTRAINT [DF_ItemPriceBasis_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CompanyKey]    SMALLINT      CONSTRAINT [DF_ItemPriceBasis_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_ItemPriceBasis] PRIMARY KEY CLUSTERED ([PriceBasisKey] ASC),
    CONSTRAINT [FK_ItemPriceBasis_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_ItemPriceBasis_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

