CREATE TABLE [dbo].[TMS_Integration_AuditLog] (
    [LogKey]      INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SiteID]      VARCHAR (20) NOT NULL,
    [DateCreated] DATETIME     NOT NULL,
    [IsEmailSent] BIT          DEFAULT ((0)) NULL,
    CONSTRAINT [PK_TMS_Integration_AuditLog_1] PRIMARY KEY CLUSTERED ([LogKey] ASC, [SiteID] ASC) WITH (FILLFACTOR = 90),
    UNIQUE NONCLUSTERED ([LogKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_AuditLog__DateCreated]
    ON [dbo].[TMS_Integration_AuditLog]([DateCreated] ASC);

