CREATE TABLE [dbo].[DriverLocationItem] (
    [DriverRateKey]     INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Driverkey]         INT             NULL,
    [ItemKey]           INT             NULL,
    [CityKey]           INT             NULL,
    [UnitCost]          DECIMAL (18, 2) NULL,
    [EffectiveDate]     DATE            NULL,
    [CreateDate]        DATETIME        NULL,
    [CreateUserKey]     INT             NULL,
    [LastUpdateDate]    DATE            NULL,
    [LastUpdateUserKey] INT             NULL,
    [CompanyKey]        SMALLINT        NULL,
    CONSTRAINT [PK_DriverLocationItem] PRIMARY KEY CLUSTERED ([DriverRateKey] ASC),
    CONSTRAINT [FK_DriverLocationItem_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_DriverLocationItem_Item] FOREIGN KEY ([ItemKey]) REFERENCES [dbo].[Item] ([ItemKey]),
    CONSTRAINT [FK_DriverLocationItem_LocationData] FOREIGN KEY ([CityKey]) REFERENCES [dbo].[LocationData] ([CityKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_DriverLocationItem_ItemKey_Driverkey_EffectiveDate]
    ON [dbo].[DriverLocationItem]([ItemKey] ASC, [Driverkey] ASC, [EffectiveDate] ASC);

