CREATE TABLE [dbo].[VoucherDetail_Log] (
    [VoucherLineKey] INT             NOT NULL,
    [Voucherkey]     INT             NOT NULL,
    [ItemKey]        INT             NULL,
    [Description]    VARCHAR (255)   NULL,
    [UnitCost]       DECIMAL (18, 5) NULL,
    [Qty]            DECIMAL (18, 2) NULL,
    [ExtCost]        DECIMAL (18, 2) NULL,
    [RouteKey]       INT             NULL,
    [CreateUserKey]  INT             NOT NULL,
    [CreateDate]     DATETIME        NULL,
    [UpdateUserKey]  INT             NULL,
    [UpdateDate]     DATETIME        NULL,
    [ActionType]     VARCHAR (30)    NULL,
    [ActionUser]     VARCHAR (50)    NULL,
    [ActionDate]     DATETIME        NULL
);

