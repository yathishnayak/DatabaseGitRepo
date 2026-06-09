CREATE TABLE [dbo].[COST_CostDataOutput_PrePull] (
    [Market]                VARCHAR (100)   NULL,
    [Terminal]              VARCHAR (100)   NULL,
    [City]                  VARCHAR (100)   NULL,
    [State]                 VARCHAR (100)   NULL,
    [ZipCode]               VARCHAR (100)   NULL,
    [Zone]                  VARCHAR (100)   NULL,
    [Prepulllocation]       VARCHAR (100)   NULL,
    [PrepullCost]           DECIMAL (18, 2) NULL,
    [EffectiveDate]         DATETIME        NULL,
    [EffectiveDateFrom]     VARCHAR (100)   NULL,
    [CostOutputDataKey]     INT             IDENTITY (1, 1) NOT NULL,
    [FromCostOutputDataKey] INT             NULL,
    [FileProcesskey]        INT             NULL,
    [RecordSL]              INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_PrePull_Market_Terminal_City_State]
    ON [dbo].[COST_CostDataOutput_PrePull]([Market] ASC, [Terminal] ASC, [City] ASC, [State] ASC) WITH (FILLFACTOR = 90);

