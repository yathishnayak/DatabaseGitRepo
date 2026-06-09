CREATE TABLE [dbo].[Cost_EffectiveFrom] (
    [EffectiveKey]  INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [EffectiveFrom] VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([EffectiveKey] ASC)
);

