CREATE TABLE [dbo].[Routes_AuditLog] (
    [RouteKey]        INT           NOT NULL,
    [LogDate]         DATETIME      NOT NULL,
    [LogText]         VARCHAR (500) NULL,
    [ActionUserKey]   INT           NULL,
    [MainAuditLogKey] INT           NOT NULL,
    CONSTRAINT [PK_Routes_Log] PRIMARY KEY CLUSTERED ([RouteKey] ASC, [MainAuditLogKey] ASC, [LogDate] ASC)
);

