CREATE TABLE [dbo].[OrderDetail_AuditLog] (
    [OrderDetailKey]  INT           NOT NULL,
    [LogDate]         DATETIME      NOT NULL,
    [LogText]         VARCHAR (500) NULL,
    [ActionUserKey]   INT           NULL,
    [MainAuditLogKey] INT           NOT NULL,
    CONSTRAINT [PK_OrderDetail_Log] PRIMARY KEY CLUSTERED ([OrderDetailKey] ASC, [MainAuditLogKey] ASC, [LogDate] ASC) WITH (FILLFACTOR = 90)
);

