CREATE TABLE [dbo].[DriverDocuments] (
    [DocumentKey]          INT          NOT NULL,
    [DriverKey]            INT          NOT NULL,
    [IsContainerOrChassis] VARCHAR (50) NULL,
    [DocSource]            VARCHAR (50) NULL,
    [DocumentTypeDesc]     VARCHAR (50) NULL,
    CONSTRAINT [PK_TMS_DriverDocuments] PRIMARY KEY CLUSTERED ([DocumentKey] ASC, [DriverKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TMS_DriverDocuments_DriverKey] FOREIGN KEY ([DriverKey]) REFERENCES [dbo].[Driver] ([DriverKey])
);

