CREATE TABLE [dbo].[OrderHeader_AuditLog] (
    [OrderKey]        INT           NOT NULL,
    [LogDate]         DATETIME      NOT NULL,
    [LogText]         VARCHAR (500) NULL,
    [ActionUserKey]   INT           NULL,
    [MainAuditLogKey] INT           NOT NULL,
    CONSTRAINT [PK_OrderHeader_Log] PRIMARY KEY CLUSTERED ([OrderKey] ASC, [MainAuditLogKey] ASC, [LogDate] ASC) WITH (FILLFACTOR = 90)
);

