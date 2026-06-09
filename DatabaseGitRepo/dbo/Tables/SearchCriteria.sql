CREATE TABLE [dbo].[SearchCriteria] (
    [SearchCriteriaKey]  INT            IDENTITY (1, 1) NOT NULL,
    [SearchCriteriaName] NVARCHAR (100) NULL,
    [IsActive]           BIT            NULL,
    [IsDeleted]          BIT            NULL,
    CONSTRAINT [PK_SerachCritera] PRIMARY KEY CLUSTERED ([SearchCriteriaKey] ASC)
);

