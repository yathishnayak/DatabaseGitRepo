CREATE TABLE [dbo].[CustomerRateType] (
    [RateTypeKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RateType]    VARCHAR (100) NOT NULL,
    [IsActive]    BIT           NULL,
    [IsDeleted]   BIT           NULL,
    [CreatedBy]   INT           NULL,
    [UpdatedBy]   INT           NULL,
    [CreateDate]  DATETIME      NULL,
    [UpdateDate]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([RateTypeKey] ASC)
);

