CREATE TABLE [dbo].[RouteVouchers] (
    [RouteKey]   INT NOT NULL,
    [VoucherKey] INT NOT NULL,
    CONSTRAINT [TMS_RouteVouchers_pkey] PRIMARY KEY CLUSTERED ([RouteKey] ASC, [VoucherKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TMS_RouteVouchers_TMS_Routes] FOREIGN KEY ([RouteKey]) REFERENCES [dbo].[Routes] ([RouteKey]),
    CONSTRAINT [FK_TMS_RouteVouchers_VoucherHeader] FOREIGN KEY ([VoucherKey]) REFERENCES [dbo].[VoucherHeader] ([VoucherKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_RouteVouchers_VoucherKey]
    ON [dbo].[RouteVouchers]([VoucherKey] ASC);

