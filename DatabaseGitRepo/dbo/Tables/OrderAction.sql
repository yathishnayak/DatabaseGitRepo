CREATE TABLE [dbo].[OrderAction] (
    [ActionKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]  VARCHAR (100) NOT NULL,
    [OrderTypeKey] INT           NOT NULL,
    CONSTRAINT [PK_OrderAction] PRIMARY KEY CLUSTERED ([ActionKey] ASC)
);

