CREATE TABLE [dbo].[CollectionAuditLog] (
    [AuditLogKey]         INT            IDENTITY (1, 1) NOT NULL,
    [CollectionRecordKey] INT            NULL,
    [StatusCodeKey]       INT            NULL,
    [DateCreated]         DATETIME       NULL,
    [CreateUser]          INT            NULL,
    [Comments]            NVARCHAR (MAX) NULL
);

