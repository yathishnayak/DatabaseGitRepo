CREATE TABLE [dbo].[ContainerLegDocuments] (
    [RouteKey]    INT NOT NULL,
    [DocumentKey] INT NOT NULL,
    CONSTRAINT [TMS_ContainerLegDocuments_pkey] PRIMARY KEY CLUSTERED ([RouteKey] ASC, [DocumentKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_TMS_ContainerLegDocuments_Document] FOREIGN KEY ([DocumentKey]) REFERENCES [dbo].[Document] ([DocumentKey])
);

