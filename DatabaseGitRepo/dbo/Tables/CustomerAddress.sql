CREATE TABLE [dbo].[CustomerAddress] (
    [CustKey]           INT          NOT NULL,
    [AddrKey]           INT          NOT NULL,
    [AddrType]          VARCHAR (50) NULL,
    [MarketLocationKey] INT          NULL,
    CONSTRAINT [CustomerAddress_PKey] PRIMARY KEY CLUSTERED ([CustKey] ASC, [AddrKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_CustomerAddress_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_CustomerAddress_Customer] FOREIGN KEY ([CustKey]) REFERENCES [dbo].[Customer] ([CustKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_CustomerAddress_AddrKey]
    ON [dbo].[CustomerAddress]([AddrKey] ASC) WITH (FILLFACTOR = 90);

