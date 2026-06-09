CREATE TABLE [dbo].[ShippingPortTerminals] (
    [TerminalKey]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TerminaID]         VARCHAR (100) NOT NULL,
    [PortKey]           INT           NULL,
    [AddrKey]           INT           NOT NULL,
    [StatusKey]         SMALLINT      CONSTRAINT [DF_ShippingPortTerminals_Status] DEFAULT ((1)) NOT NULL,
    [IsActive]          BIT           NULL,
    [IsDeleted]         BIT           NULL,
    [CreateDate]        DATETIME      NULL,
    [CreateUserKey]     INT           NULL,
    [UpdateDate]        DATETIME      NULL,
    [UpdateUserKey]     INT           NULL,
    [PriceGroupingKey]  INT           NULL,
    [MarketLocationKey] INT           NULL,
    CONSTRAINT [shippingPortTerminals_pkey] PRIMARY KEY CLUSTERED ([TerminalKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ShippingPortTerminals_address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_ShippingPortTerminals_Shippingport] FOREIGN KEY ([PortKey]) REFERENCES [dbo].[ShippingPort] ([ShippingPortKey]),
    CONSTRAINT [FK_ShippingPortTerminals_Statukey] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_ShippingPortTerminals_MarketLocationKey]
    ON [dbo].[ShippingPortTerminals]([MarketLocationKey] ASC)
    INCLUDE([TerminaID], [AddrKey], [StatusKey], [IsActive], [IsDeleted]);


GO
CREATE NONCLUSTERED INDEX [IX_ShippingPortTerminals_AddrKey]
    ON [dbo].[ShippingPortTerminals]([AddrKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ShippingPortTerminals_TerminaID]
    ON [dbo].[ShippingPortTerminals]([TerminaID] ASC);

