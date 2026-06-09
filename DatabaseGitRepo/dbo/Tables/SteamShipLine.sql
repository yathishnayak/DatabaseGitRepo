CREATE TABLE [dbo].[SteamShipLine] (
    [LineKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LineName]   VARCHAR (100) NULL,
    [IsActive]   BIT           DEFAULT ((0)) NULL,
    [CreateUser] INT           NULL,
    [CreateDate] DATETIME      NULL,
    [UpdateUser] INT           NULL,
    [UpdateDate] DATETIME      NULL,
    [ScacCode]   VARCHAR (30)  NULL,
    PRIMARY KEY CLUSTERED ([LineKey] ASC)
);

