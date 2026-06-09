CREATE TABLE [dbo].[Sell_Config_History] (
    [SellConfigKey]    INT             NOT NULL,
    [MarketKey]        INT             NULL,
    [ZoneKey]          INT             NULL,
    [TerminalKey]      INT             NULL,
    [IsPrePull]        BIT             NULL,
    [PrePullValue]     NUMERIC (18, 2) NULL,
    [IsStopOff]        BIT             NULL,
    [StopOffValue]     NUMERIC (18, 2) NULL,
    [HighestOff]       VARCHAR (20)    NULL,
    [DrayBaseValue]    NUMERIC (18, 2) NULL,
    [Effective_date]   DATETIME        NULL,
    [EffectiveFromKey] INT             NULL,
    [YardType]         VARCHAR (20)    NULL,
    [CreateDate]       DATETIME        NULL,
    [CreateUser]       INT             NULL,
    [UpdateDate]       DATETIME        NULL,
    [UpdateUser]       INT             NULL
);

