CREATE TABLE [dbo].[Document] (
    [DocumentKey]      INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DocumentType]     INT             NULL,
    [CreateDate]       DATETIME        CONSTRAINT [DF_Document_CreateDate] DEFAULT (getdate()) NOT NULL,
    [CreateUserKey]    INT             NOT NULL,
    [OriginalFileName] VARCHAR (500)   NULL,
    [OriginalFileType] VARCHAR (50)    NULL,
    [FileSizeinMB]     DECIMAL (18, 2) NULL,
    [IsDeleted]        BIT             CONSTRAINT [DF_Document_IsDeleted] DEFAULT ((0)) NOT NULL,
    [DeletedDate]      DATETIME        NULL,
    [DeletedUserKey]   INT             NULL,
    [FilePath]         VARCHAR (500)   NULL,
    CONSTRAINT [Document_pkey] PRIMARY KEY CLUSTERED ([DocumentKey] ASC),
    CONSTRAINT [FK_Document_DocumentType] FOREIGN KEY ([DocumentType]) REFERENCES [dbo].[DocumenType] ([DocumentTypeKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_Document_IsDeleted]
    ON [dbo].[Document]([IsDeleted] ASC)
    INCLUDE([DocumentType]);


GO
CREATE NONCLUSTERED INDEX [IX_Document_OriginalFileName]
    ON [dbo].[Document]([OriginalFileName] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-DocumentType]
    ON [dbo].[Document]([DocumentType] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-CreateDate]
    ON [dbo].[Document]([CreateDate] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Document_DocumentType_IsDeleted]
    ON [dbo].[Document]([DocumentType] ASC, [IsDeleted] ASC)
    INCLUDE([CreateDate], [CreateUserKey], [OriginalFileName], [OriginalFileType], [FileSizeinMB]);

