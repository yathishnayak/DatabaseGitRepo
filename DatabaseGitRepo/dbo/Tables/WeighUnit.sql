CREATE TABLE [dbo].[WeighUnit] (
    [WeightUnitKey] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WeightUnit]    VARCHAR (10) NULL,
    [IsActive]      BIT          NULL,
    [IsDeleted]     BIT          NULL,
    [CreateDate]    DATETIME     NULL,
    [CreateUserKey] INT          NULL,
    [UpdateDate]    DATETIME     NULL,
    [UpdateUserKey] INT          NULL,
    PRIMARY KEY CLUSTERED ([WeightUnitKey] ASC)
);

