CREATE TABLE [dbo].[Email] (
    [EmailKey]        BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderKey]        INT            NOT NULL,
    [OrderDetailKey]  INT            NULL,
    [SlNo]            INT            NULL,
    [FromAddress]     VARCHAR (1000) NULL,
    [ToAddress]       VARCHAR (1000) NULL,
    [NoOfAttachments] SMALLINT       NULL,
    [Subject]         VARCHAR (500)  NULL,
    [Content]         NVARCHAR (MAX) NULL,
    [SentReceived]    CHAR (1)       NULL,
    [Status]          BIT            NULL,
    [DocumentKey]     INT            NULL,
    [CreatedDate]     DATETIME       NULL,
    [CreatedUserKey]  INT            NULL,
    CONSTRAINT [PK_Email] PRIMARY KEY CLUSTERED ([OrderKey] ASC, [EmailKey] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'S: Sent, R: Received', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Email', @level2type = N'COLUMN', @level2name = N'SentReceived';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'True: Sent/Received, False: Save as Draft', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Email', @level2type = N'COLUMN', @level2name = N'Status';

