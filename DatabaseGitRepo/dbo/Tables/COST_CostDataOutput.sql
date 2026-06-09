CREATE TABLE [dbo].[COST_CostDataOutput] (
    [CostOutputDataKey]     INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Market]                VARCHAR (100)   NULL,
    [Terminal]              VARCHAR (100)   NULL,
    [City]                  VARCHAR (100)   NULL,
    [State]                 VARCHAR (100)   NULL,
    [ZipCode]               VARCHAR (100)   NULL,
    [Zone]                  VARCHAR (100)   NULL,
    [DriverType]            VARCHAR (100)   NULL,
    [YardPortType]          VARCHAR (50)    NULL,
    [Cost]                  DECIMAL (18, 2) NULL,
    [FSFCost]               DECIMAL (18, 2) NULL,
    [FSF]                   DECIMAL (18, 2) NULL,
    [DrayBase]              DECIMAL (18, 2) NULL,
    [EffectiveDate]         DATETIME        NULL,
    [EffectiveDateFrom]     VARCHAR (100)   NULL,
    [FromCostOutputDataKey] INT             NULL,
    [FileProcesskey]        INT             NULL,
    [RecordSL]              INT             NULL,
    CONSTRAINT [PK_COST_CostDataOutput] PRIMARY KEY CLUSTERED ([CostOutputDataKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_Market_Terminal_City_State_DriverType_YardPortType]
    ON [dbo].[COST_CostDataOutput]([Market] ASC, [Terminal] ASC, [City] ASC, [State] ASC, [DriverType] ASC, [YardPortType] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_Cost]
    ON [dbo].[COST_CostDataOutput]([Cost] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_City]
    ON [dbo].[COST_CostDataOutput]([City] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_Terminal_FromCostOutputDataKey]
    ON [dbo].[COST_CostDataOutput]([Terminal] ASC, [FromCostOutputDataKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_City_Cost]
    ON [dbo].[COST_CostDataOutput]([City] ASC, [Cost] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_COST_CostDataOutput_Demography]
    ON [dbo].[COST_CostDataOutput]([State] ASC, [City] ASC, [ZipCode] ASC, [Cost] ASC);

