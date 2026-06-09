CREATE TABLE [dbo].[CustomerCompany] (
    [CustomerCompanyKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CompanyName]        VARCHAR (100) NULL,
    [IsActive]           BIT           NULL,
    [IsDeleted]          BIT           NULL,
    [CreatedBy]          INT           NULL,
    [CreateDate]         DATETIME      NULL,
    [UpdatedBy]          INT           NULL,
    [UpdateDate]         DATETIME      NULL,
    CONSTRAINT [PK_CustomerCompany] PRIMARY KEY CLUSTERED ([CustomerCompanyKey] ASC)
);

