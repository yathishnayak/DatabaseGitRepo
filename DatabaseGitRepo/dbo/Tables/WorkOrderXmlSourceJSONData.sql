CREATE TABLE [dbo].[WorkOrderXmlSourceJSONData] (
    [FileKey]      INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileName]     NVARCHAR (500) NULL,
    [FileDataJson] NVARCHAR (MAX) NULL,
    [Status]       NVARCHAR (50)  NULL,
    [CreateDate]   DATETIME       NULL,
    [UpdateDate]   DATETIME       NULL,
    CONSTRAINT [PK_WorkOrderXmlSourceJSONData] PRIMARY KEY CLUSTERED ([FileKey] ASC)
);

