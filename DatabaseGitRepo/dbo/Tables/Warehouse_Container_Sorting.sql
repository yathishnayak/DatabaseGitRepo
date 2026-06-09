CREATE TABLE [dbo].[Warehouse_Container_Sorting] (
    [SortingKey]  INT           IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (100) NULL,
    [IsActive]    BIT           NULL,
    [Isdeleted]   BIT           NULL,
    [CreateDate]  DATETIME      NULL,
    [UpdateDate]  DATETIME      NULL,
    [CreatedBy]   INT           NULL,
    [UpdatedBy]   INT           NULL,
    PRIMARY KEY CLUSTERED ([SortingKey] ASC)
);

