CREATE TABLE [dbo].[TMS_Integration_AuditLogDetail] (
    [LogDetailKey] BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LogKey]       INT            NOT NULL,
    [EDIGroup]     VARCHAR (5)    NULL,
    [ActionHead]   VARCHAR (50)   NULL,
    [DataType]     VARCHAR (10)   NULL,
    [ActionDetail] NVARCHAR (MAX) NULL,
    [DateCreated]  DATETIME       DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TMS_Integration_AuditLogDetail] PRIMARY KEY CLUSTERED ([LogDetailKey] ASC),
    CONSTRAINT [FK_TMS_Integration_AuditLogDetail_TMS_Integration_AuditLogDetail] FOREIGN KEY ([LogKey]) REFERENCES [dbo].[TMS_Integration_AuditLog] ([LogKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_AuditLogDetail_Logkey]
    ON [dbo].[TMS_Integration_AuditLogDetail]([LogKey] ASC);

