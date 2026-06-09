CREATE TABLE [dbo].[Cost_BaseCostForSellDatabase] (
    [MarketKey]   INT             NOT NULL,
    [TerminalKey] INT             NOT NULL,
    [Zone]        VARCHAR (50)    NOT NULL,
    [Cost]        NUMERIC (18, 3) NULL,
    [FSF]         NUMERIC (18, 3) NULL,
    [Draybase]    NUMERIC (18, 3) NULL,
    [PrePullCost] NUMERIC (18, 3) NULL,
    [StopOffCost] NUMERIC (18, 3) NULL,
    [DateCreated] DATETIME        NULL,
    CONSTRAINT [Cost_BaseCostForSellDatabase_primarykey] PRIMARY KEY CLUSTERED ([MarketKey] ASC, [TerminalKey] ASC, [Zone] ASC) WITH (FILLFACTOR = 90)
);

