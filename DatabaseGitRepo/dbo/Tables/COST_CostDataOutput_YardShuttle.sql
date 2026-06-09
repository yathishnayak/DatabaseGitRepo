CREATE TABLE [dbo].[COST_CostDataOutput_YardShuttle] (
    [Market]                VARCHAR (100)   NULL,
    [Terminal]              VARCHAR (100)   NULL,
    [City]                  VARCHAR (100)   NULL,
    [State]                 VARCHAR (100)   NULL,
    [ZipCode]               VARCHAR (100)   NULL,
    [Zone]                  VARCHAR (100)   NULL,
    [YardFrom]              VARCHAR (100)   NULL,
    [YardTo]                VARCHAR (100)   NULL,
    [YardCost]              DECIMAL (18, 2) NULL,
    [EffectiveDate]         DATETIME        NULL,
    [EffectiveDateFrom]     VARCHAR (100)   NULL,
    [CostOutputDataKey]     INT             IDENTITY (1, 1) NOT NULL,
    [FromCostOutputDataKey] INT             NULL,
    [FileProcesskey]        INT             NULL,
    [RecordSL]              INT             NULL
);

