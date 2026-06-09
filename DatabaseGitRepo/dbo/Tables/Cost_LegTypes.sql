CREATE TABLE [dbo].[Cost_LegTypes] (
    [LegTypeID]   VARCHAR (3)  NOT NULL,
    [LegTypeName] VARCHAR (50) NULL,
    [LegName]     VARCHAR (50) NULL,
    [LegOrderBy]  INT          NULL,
    PRIMARY KEY CLUSTERED ([LegTypeID] ASC)
);

