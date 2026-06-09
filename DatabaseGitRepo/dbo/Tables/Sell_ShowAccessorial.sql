CREATE TABLE [dbo].[Sell_ShowAccessorial] (
    [LineItem]     VARCHAR (100) NOT NULL,
    [ShowinSellDB] BIT           NULL,
    [ItemKey]      INT           NULL,
    CONSTRAINT [PK_Sell_ShowAccessorial] PRIMARY KEY CLUSTERED ([LineItem] ASC)
);

