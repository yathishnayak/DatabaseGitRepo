CREATE TABLE [dbo].[PriceGrouping] (
    [PriceGroupingKey]  INT           NOT NULL,
    [PriceGrouping]     VARCHAR (100) NULL,
    [MarketLocationKey] INT           NULL,
    [IsActive]          BIT           NULL,
    [IsDeleted]         BIT           NULL,
    [CreatedDate]       DATETIME      NULL,
    CONSTRAINT [PK_PriceGrouping] PRIMARY KEY CLUSTERED ([PriceGroupingKey] ASC)
);

