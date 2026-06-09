CREATE TABLE [dbo].[ItemCostBreak] (
    [CostBreakKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Itemkey]      INT             NULL,
    [From]         DECIMAL (18, 2) NULL,
    [To]           DECIMAL (18, 2) NULL,
    [UnitCost]     DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_ItemCostBreak] PRIMARY KEY CLUSTERED ([CostBreakKey] ASC)
);

