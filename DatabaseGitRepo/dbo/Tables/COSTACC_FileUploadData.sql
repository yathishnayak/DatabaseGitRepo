CREATE TABLE [dbo].[COSTACC_FileUploadData] (
    [FileProcesskey]    INT           NOT NULL,
    [RecordSL]          INT           NOT NULL,
    [LineItem]          VARCHAR (100) NULL,
    [Market]            VARCHAR (100) NULL,
    [Terminal]          VARCHAR (100) NULL,
    [TruckType]         VARCHAR (100) NULL,
    [YardPort]          VARCHAR (100) NULL,
    [Zone]              VARCHAR (50)  NULL,
    [Group]             VARCHAR (100) NULL,
    [FixVsNonFix]       VARCHAR (100) NULL,
    [Per]               VARCHAR (100) NULL,
    [UnitCost]          VARCHAR (100) NULL,
    [EffectiveDate]     VARCHAR (100) NULL,
    [EffectiveDateFrom] VARCHAR (100) NULL,
    [FreePer]           VARCHAR (20)  NULL,
    [SplitPercent]      VARCHAR (20)  NULL,
    [RecordStatus]      BIT           NULL,
    [RecordRemarks]     VARCHAR (500) NULL,
    CONSTRAINT [PK_COSTACC_FileUploadData] PRIMARY KEY CLUSTERED ([FileProcesskey] ASC, [RecordSL] ASC)
);

