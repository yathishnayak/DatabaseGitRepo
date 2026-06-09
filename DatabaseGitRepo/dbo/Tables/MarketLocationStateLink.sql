CREATE TABLE [dbo].[MarketLocationStateLink] (
    [StateCode]         VARCHAR (5) NOT NULL,
    [MarketLocationKey] INT         NULL,
    PRIMARY KEY CLUSTERED ([StateCode] ASC)
);

