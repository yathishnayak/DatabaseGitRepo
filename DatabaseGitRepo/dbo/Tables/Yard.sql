CREATE TABLE [dbo].[Yard] (
    [YardId]            SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ShortName]         VARCHAR (20)  NOT NULL,
    [Name]              VARCHAR (100) NOT NULL,
    [AddrKey]           INT           NULL,
    [IsActive]          BIT           CONSTRAINT [DF_Yard_IsActive] DEFAULT ((1)) NOT NULL,
    [MarketLocationKey] INT           NULL,
    [IsDeleted]         BIT           NULL,
    [CreateDate]        DATETIME      NULL,
    [CreateUserKey]     INT           NULL,
    [UpdateDate]        DATETIME      NULL,
    [UpdateUserKey]     INT           NULL,
    [IsShuttleLocation] BIT           CONSTRAINT [DF_Yard_IsShuttleLocation] DEFAULT ((0)) NULL,
    [YardType]          VARCHAR (20)  NULL,
    CONSTRAINT [PK_Yard] PRIMARY KEY CLUSTERED ([YardId] ASC)
);

