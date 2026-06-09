CREATE TABLE [dbo].[VoucherLine_AuditLog] (
    [VoucherLineKey]  INT           NOT NULL,
    [LogDate]         DATETIME      NOT NULL,
    [LogText]         VARCHAR (500) NULL,
    [ActionUserKey]   INT           NULL,
    [MainAuditLogKey] INT           NOT NULL,
    CONSTRAINT [PK_VoucherLine_Log] PRIMARY KEY CLUSTERED ([VoucherLineKey] ASC, [MainAuditLogKey] ASC, [LogDate] ASC) WITH (FILLFACTOR = 90)
);

