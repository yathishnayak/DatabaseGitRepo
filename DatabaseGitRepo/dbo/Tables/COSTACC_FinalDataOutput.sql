CREATE TABLE [dbo].[COSTACC_FinalDataOutput] (
    [OutputDataKey]     BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileProcesskey]    INT             NOT NULL,
    [RecordSL]          INT             NOT NULL,
    [LineItem]          VARCHAR (100)   NULL,
    [Market]            VARCHAR (100)   NULL,
    [Terminal]          VARCHAR (100)   NULL,
    [TruckType]         VARCHAR (100)   NULL,
    [YardPort]          VARCHAR (100)   NULL,
    [Zone]              VARCHAR (100)   NULL,
    [Group]             VARCHAR (100)   NULL,
    [FixVsNonFix]       VARCHAR (100)   NULL,
    [Per]               VARCHAR (100)   NULL,
    [UnitCost]          VARCHAR (100)   NULL,
    [EffectiveDate]     VARCHAR (100)   NULL,
    [EffectiveDateFrom] VARCHAR (100)   NULL,
    [FreePer]           INT             NULL,
    [SplitPercent]      DECIMAL (18, 2) NULL,
    CONSTRAINT [PK_COSTACC_FinalDataOutput] PRIMARY KEY CLUSTERED ([OutputDataKey] ASC)
);

