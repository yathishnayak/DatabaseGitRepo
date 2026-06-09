CREATE TABLE [dbo].[Sell_Config] (
    [SellConfigKey]    INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MarketKey]        INT             NULL,
    [ZoneKey]          INT             NULL,
    [TerminalKey]      INT             NULL,
    [IsPrePull]        BIT             NULL,
    [PrePullValue]     NUMERIC (18, 2) NULL,
    [IsStopOff]        BIT             NULL,
    [StopOffValue]     NUMERIC (18, 2) NULL,
    [HighestOff]       VARCHAR (50)    NULL,
    [DrayBaseValue]    NUMERIC (18, 2) NULL,
    [Effective_date]   DATETIME        NULL,
    [EffectiveFromKey] INT             NULL,
    [YardType]         VARCHAR (20)    NULL,
    [CreateDate]       DATETIME        CONSTRAINT [DF__Sell_Conf__Creat__7953D99F] DEFAULT (getdate()) NULL,
    [CreateUser]       INT             NULL,
    [UpdateDate]       DATETIME        CONSTRAINT [DF__Sell_Conf__Updat__7A47FDD8] DEFAULT (getdate()) NULL,
    [UpdateUser]       INT             NULL,
    CONSTRAINT [PK__Sell_Con__BC2B25C6741B5C79] PRIMARY KEY CLUSTERED ([SellConfigKey] ASC)
);

