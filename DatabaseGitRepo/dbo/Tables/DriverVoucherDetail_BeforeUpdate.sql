CREATE TABLE [dbo].[DriverVoucherDetail_BeforeUpdate] (
    [DriverVoucherLineKey] INT             IDENTITY (1, 1) NOT NULL,
    [DriverVoucherKey]     INT             NOT NULL,
    [ItemKey]              INT             NOT NULL,
    [Description]          VARCHAR (255)   NULL,
    [UnitCost]             DECIMAL (18, 5) NULL,
    [Qty]                  DECIMAL (18, 5) NULL,
    [ExtCost]              DECIMAL (18, 5) NULL,
    [Remarks]              VARCHAR (2000)  NULL,
    [CreateUser]           INT             NULL,
    [CreateDate]           DATETIME        NULL,
    [UpdateDate]           DATETIME        NULL,
    [UpdateUser]           INT             NULL
);

