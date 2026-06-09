CREATE TABLE [dbo].[Item_UAT] (
    [ItemKey]            INT             NOT NULL,
    [ItemID]             VARCHAR (30)    NULL,
    [Description]        VARCHAR (255)   NULL,
    [ItemTypeKey]        SMALLINT        NULL,
    [UnitCost]           DECIMAL (18, 2) NULL,
    [StatusKey]          SMALLINT        NULL,
    [CompanyKey]         SMALLINT        NULL,
    [PriceBasisKey]      SMALLINT        NULL,
    [CreateDate]         SMALLDATETIME   NULL,
    [StatusDate]         SMALLDATETIME   NULL,
    [CategoryKey]        SMALLINT        NULL,
    [InvoiceItemDesc]    VARCHAR (255)   NULL,
    [EDICode]            VARCHAR (3)     NULL,
    [ItemTypeMappingKey] INT             NULL,
    [CostGrp]            INT             NULL,
    [InternalCost]       DECIMAL (18, 5) NULL,
    [itemDescrOld]       VARCHAR (255)   NULL,
    [Remarks]            VARCHAR (100)   NULL,
    [ItemCostGroup]      VARCHAR (100)   NULL
);

