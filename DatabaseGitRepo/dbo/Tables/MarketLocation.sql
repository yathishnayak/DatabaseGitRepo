CREATE TABLE [dbo].[MarketLocation] (
    [MarketLocationKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MarketLocation]    VARCHAR (100) NULL,
    [AddrKey]           INT           NULL,
    [IsActive]          BIT           NULL,
    [IsDeleted]         BIT           NULL,
    [CreateDate]        DATETIME      NULL,
    [CreateUserKey]     INT           NULL,
    [UpdateDate]        DATETIME      NULL,
    [UpdateUserKey]     INT           NULL,
    PRIMARY KEY CLUSTERED ([MarketLocationKey] ASC)
);

