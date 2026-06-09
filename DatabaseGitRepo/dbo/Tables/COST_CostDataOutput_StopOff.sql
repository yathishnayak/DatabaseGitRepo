CREATE TABLE [dbo].[COST_CostDataOutput_StopOff] (
    [Market]                VARCHAR (100)   NULL,
    [Terminal]              VARCHAR (100)   NULL,
    [City]                  VARCHAR (100)   NULL,
    [State]                 VARCHAR (100)   NULL,
    [ZipCode]               VARCHAR (100)   NULL,
    [Zone]                  VARCHAR (100)   NULL,
    [StopOfflocation]       VARCHAR (100)   NULL,
    [StopOffCost]           DECIMAL (18, 2) NULL,
    [EffectiveDate]         DATETIME        NULL,
    [EffectiveDateFrom]     VARCHAR (100)   NULL,
    [CostOutputDataKey]     INT             IDENTITY (1, 1) NOT NULL,
    [FromCostOutputDataKey] INT             NULL,
    [FileProcesskey]        INT             NULL,
    [RecordSL]              INT             NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_StopOff_Market_Terminal_City_State_StopOfflocation]
    ON [dbo].[COST_CostDataOutput_StopOff]([Market] ASC, [Terminal] ASC, [City] ASC, [State] ASC, [StopOfflocation] ASC)
    INCLUDE([StopOffCost]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_StopOff_Market_Terminal_City_State]
    ON [dbo].[COST_CostDataOutput_StopOff]([Market] ASC, [Terminal] ASC, [City] ASC, [State] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_StopOff_Terminal_FromCostOutputDataKey]
    ON [dbo].[COST_CostDataOutput_StopOff]([Terminal] ASC, [FromCostOutputDataKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_StopOff_Terminal_City_State_EffectiveDate]
    ON [dbo].[COST_CostDataOutput_StopOff]([Terminal] ASC, [City] ASC, [State] ASC, [EffectiveDate] ASC)
    INCLUDE([Market], [StopOffCost], [EffectiveDateFrom]);

