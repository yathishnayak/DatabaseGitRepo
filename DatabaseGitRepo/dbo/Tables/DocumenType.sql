CREATE TABLE [dbo].[DocumenType] (
    [DocumentTypeKey] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]     VARCHAR (100)  NULL,
    [StoragePath]     VARCHAR (1000) NULL,
    [LinkTo]          VARCHAR (50)   NULL,
    [Shortcode]       VARCHAR (10)   NULL,
    CONSTRAINT [Documenttype_pkey] PRIMARY KEY CLUSTERED ([DocumentTypeKey] ASC)
);

