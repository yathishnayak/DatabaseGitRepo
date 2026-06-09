CREATE TABLE [dbo].[OrderExpense_log] (
    [OrderExpenseKey] INT             NOT NULL,
    [Itemkey]         INT             NULL,
    [RouteKey]        INT             NULL,
    [UnitCost]        DECIMAL (18, 2) NULL,
    [Qty]             DECIMAL (18, 2) NULL,
    [NewUnitCost]     DECIMAL (18, 2) NULL,
    [CreateDate]      DATETIME        NULL,
    [CreateUserKey]   INT             NULL,
    [LastUpdateDate]  DATETIME        NULL,
    [UpdateUserKey]   INT             NULL,
    [ActionType]      VARCHAR (30)    NULL,
    [ActionUser]      VARCHAR (50)    NULL,
    [ActionDate]      DATETIME        NULL
);

