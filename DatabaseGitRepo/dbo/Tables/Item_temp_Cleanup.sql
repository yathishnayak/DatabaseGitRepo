CREATE TABLE [dbo].[Item_temp_Cleanup] (
    [ItemKey]         INT           NULL,
    [Description]     VARCHAR (200) NULL,
    [InvoiceItemDesc] VARCHAR (200) NULL,
    [ItemType]        VARCHAR (50)  NULL,
    [ItemCostGroup]   VARCHAR (50)  NULL,
    [CostItemType]    VARCHAR (50)  NULL,
    [InvoiceCount]    INT           NULL,
    [ChargesCount]    INT           NULL,
    [VoucherCount]    INT           NULL,
    [ToDelete]        VARCHAR (5)   NULL,
    [ReplaceItemKey]  INT           NULL,
    [ReplaceItemName] VARCHAR (200) NULL,
    [Notes]           VARCHAR (500) NULL
);

