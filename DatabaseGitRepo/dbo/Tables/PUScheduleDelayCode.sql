CREATE TABLE [dbo].[PUScheduleDelayCode] (
    [CodeKey]     INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Code]        VARCHAR (500) NULL,
    [IsActive]    BIT           NULL,
    [IsDeleted]   BIT           NULL,
    [CreatedBy]   INT           NULL,
    [CreatedDate] DATETIME      NULL,
    [UpdatedBy]   INT           NULL,
    [UpdatedDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([CodeKey] ASC)
);

