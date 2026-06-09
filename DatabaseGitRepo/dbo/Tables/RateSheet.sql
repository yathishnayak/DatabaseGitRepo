CREATE TABLE [dbo].[RateSheet] (
    [RateKey]           INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerKey]       INT             NOT NULL,
    [ItemKey]           INT             NOT NULL,
    [UnitPrice]         DECIMAL (18, 5) NULL,
    [UnitCost]          DECIMAL (18, 5) NULL,
    [CreateDate]        DATETIME        CONSTRAINT [DF_RateSheet_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateUserKey]     INT             NOT NULL,
    [LastUpdateDate]    DATETIME2 (7)   NULL,
    [LastUpdateUserKey] INT             NULL,
    CONSTRAINT [Ratekey_pkey] PRIMARY KEY CLUSTERED ([RateKey] ASC),
    CONSTRAINT [FK_RateSheet_Item] FOREIGN KEY ([ItemKey]) REFERENCES [dbo].[Item] ([ItemKey])
);

