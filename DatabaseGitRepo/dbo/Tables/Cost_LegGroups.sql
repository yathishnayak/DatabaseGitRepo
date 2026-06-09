CREATE TABLE [dbo].[Cost_LegGroups] (
    [LegGroupKey]       SMALLINT      NOT NULL,
    [LegGroupID]        VARCHAR (50)  NULL,
    [LegTypesCombined]  VARCHAR (50)  NULL,
    [LegTypeHeaderText] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([LegGroupKey] ASC)
);

