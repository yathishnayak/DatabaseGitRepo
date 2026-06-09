CREATE TABLE [dbo].[DriverVoucherDeductionDetail] (
    [DriverVoucherLineKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DriverVoucherKey]     INT             NOT NULL,
    [ItemKey]              INT             NOT NULL,
    [Description]          VARCHAR (255)   NULL,
    [UnitCost]             DECIMAL (18, 5) NULL,
    [Qty]                  DECIMAL (18, 5) NULL,
    [ExtCost]              DECIMAL (18, 5) NULL,
    [Remarks]              VARCHAR (2000)  NULL,
    [CreateUser]           VARCHAR (50)    NULL,
    [CreateDate]           DATETIME        NULL,
    [UpdateDate]           DATETIME        NULL,
    [UpdateUser]           VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([DriverVoucherLineKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_DriverVoucherDeductionDetail_DriverVoucherKey]
    ON [dbo].[DriverVoucherDeductionDetail]([DriverVoucherKey] ASC)
    INCLUDE([ItemKey], [Description], [UnitCost], [Qty], [ExtCost], [Remarks]) WITH (FILLFACTOR = 90);

