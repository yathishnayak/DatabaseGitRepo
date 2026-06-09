CREATE TABLE [dbo].[Warehouse] (
    [WarehouseKey] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [WarehouseID]  VARCHAR (10) NULL,
    [AddrKey]      INT          NULL,
    [StatusKey]    SMALLINT     NOT NULL,
    [CompanyKey]   SMALLINT     CONSTRAINT [DF_Warehouse_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_Warehouse] PRIMARY KEY CLUSTERED ([WarehouseKey] ASC),
    CONSTRAINT [FK_Warehouse_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Warehouse_SmallInt] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Warehouse_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

