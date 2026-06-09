CREATE TABLE [dbo].[DriverVoucherDeductionDetail_Deleted] (
    [DriverVoucherLineKey] INT             NOT NULL,
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
    [DeleteUserKey]        INT             NULL,
    [DeletedDate]          DATETIME        NULL
);

