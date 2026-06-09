CREATE TABLE [dbo].[DryRunType] (
    [DryRunTypeKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DryRunType]    VARCHAR (100) NULL,
    [IsActive]      BIT           NULL,
    [IsDeleted]     BIT           NULL,
    [CreatedBy]     INT           NULL,
    [CreateDate]    DATETIME      NULL,
    [UpdatedBy]     INT           NULL,
    [UpdateDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([DryRunTypeKey] ASC)
);

