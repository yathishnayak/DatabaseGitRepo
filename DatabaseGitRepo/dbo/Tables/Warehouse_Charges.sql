CREATE TABLE [dbo].[Warehouse_Charges] (
    [WarehouseItemKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderDetailKey]   INT             NOT NULL,
    [ItemKey]          INT             NOT NULL,
    [Qty]              DECIMAL (18, 2) NULL,
    [Rate]             DECIMAL (18, 4) NULL,
    [TimeDuration]     VARCHAR (10)    NULL,
    [ExtAmt]           DECIMAL (18, 4) NULL,
    [CreateUserKey]    INT             NULL,
    [CreateDate]       DATETIME        NULL,
    [UpdateUserKey]    INT             NULL,
    [UpdateDate]       DATETIME        NULL,
    [FreeTime]         INT             NULL,
    [BvsNB]            BIT             NULL,
    [MinCnt]           INT             NULL,
    [MaxCnt]           INT             NULL,
    [SellRate]         DECIMAL (18, 5) NULL,
    CONSTRAINT [PK_Warehouse_Charges] PRIMARY KEY CLUSTERED ([WarehouseItemKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Warehouse_Charges_Item] FOREIGN KEY ([ItemKey]) REFERENCES [dbo].[Item] ([ItemKey]),
    CONSTRAINT [FK_Warehouse_Charges_OrderDetail] FOREIGN KEY ([OrderDetailKey]) REFERENCES [dbo].[OrderDetail] ([OrderDetailKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_Warehouse_Charges_OrderDetailKey]
    ON [dbo].[Warehouse_Charges]([OrderDetailKey] ASC);

