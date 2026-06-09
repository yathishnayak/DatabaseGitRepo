CREATE TABLE [dbo].[AuditLogDetail] (
    [AuditKey]    BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DateCreated] DATETIME       NULL,
    [CreateUser]  VARCHAR (100)  NULL,
    [RefType]     VARCHAR (50)   NULL,
    [RefId]       VARCHAR (50)   NULL,
    [RefKey]      INT            NULL,
    [Stage]       VARCHAR (50)   NULL,
    [CommentType] VARCHAR (20)   NULL,
    [Comments]    NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_AuditLogDetail] PRIMARY KEY CLUSTERED ([AuditKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_AuditLogDetail_RefKey]
    ON [dbo].[AuditLogDetail]([RefKey] ASC)
    INCLUDE([DateCreated], [Comments]);


GO
CREATE NONCLUSTERED INDEX [IX_AuditLogDetail_RefType_RefKey]
    ON [dbo].[AuditLogDetail]([RefType] ASC, [RefKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AuditLogDetail_RefType_RefKey_2]
    ON [dbo].[AuditLogDetail]([RefType] ASC, [RefKey] ASC)
    INCLUDE([DateCreated], [CreateUser], [RefId], [Stage], [CommentType], [Comments]);

