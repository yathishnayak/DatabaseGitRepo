CREATE TABLE [dbo].[DataPeriod] (
    [PeriodKey]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PeriodID]    SMALLINT      NOT NULL,
    [Description] VARCHAR (100) NULL,
    [IsDefault]   BIT           CONSTRAINT [DF_Period_IsDefault] DEFAULT ((0)) NOT NULL,
    [StatusKey]   SMALLINT      NOT NULL,
    CONSTRAINT [PK_Period] PRIMARY KEY CLUSTERED ([PeriodKey] ASC),
    CONSTRAINT [FK_DataPeriod_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

