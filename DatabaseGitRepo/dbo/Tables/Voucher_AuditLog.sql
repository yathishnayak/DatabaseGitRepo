CREATE TABLE [dbo].[Voucher_AuditLog] (
    [VoucherKey]      INT           NOT NULL,
    [LogDate]         DATETIME      NOT NULL,
    [LogText]         VARCHAR (500) NULL,
    [ActionUserKey]   INT           NULL,
    [MainAuditLogKey] INT           NOT NULL,
    CONSTRAINT [PK_Voucher_Log] PRIMARY KEY CLUSTERED ([VoucherKey] ASC, [MainAuditLogKey] ASC, [LogDate] ASC)
);

