CREATE TABLE [dbo].[LogDeduction] (
    [LogKey]           BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DriverVoucherKey] INT            NULL,
    [Comment1]         VARCHAR (1000) NULL,
    [Comment2]         VARCHAR (1000) NULL,
    PRIMARY KEY CLUSTERED ([LogKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [LogDeduction_DriverVoucherKey]
    ON [dbo].[LogDeduction]([DriverVoucherKey] ASC, [LogKey] ASC) WITH (FILLFACTOR = 90);

