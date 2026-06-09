CREATE TABLE [dbo].[AuditLog] (
    [MaintAuditLogKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CompanyKey]       SMALLINT      NULL,
    [FieldName]        VARCHAR (255) NULL,
    [IDValue]          VARCHAR (255) NULL,
    [NewValue]         VARCHAR (255) NULL,
    [OldValue]         VARCHAR (255) NULL,
    [Operation]        VARCHAR (50)  NULL,
    [ProgramName]      VARCHAR (80)  NULL,
    [SysDate]          DATETIME      NULL,
    [TableName]        VARCHAR (255) NULL,
    [UserID]           VARCHAR (30)  NULL,
    [NewKey]           INT           NULL,
    [OldKey]           INT           NULL,
    [OrderKey]         INT           NULL,
    [OrderDetailKey]   INT           NULL,
    [RouteKey]         INT           NULL,
    [VoucherKey]       INT           NULL,
    [VoucherLineKey]   INT           NULL,
    CONSTRAINT [PK__tciMaint__FFE71A17E1BD0128] PRIMARY KEY CLUSTERED ([MaintAuditLogKey] ASC)
);

