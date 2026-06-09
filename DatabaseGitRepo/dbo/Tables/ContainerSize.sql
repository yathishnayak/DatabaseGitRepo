CREATE TABLE [dbo].[ContainerSize] (
    [ContainerSizeKey] SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]      VARCHAR (200) NOT NULL,
    [WarehouseSizeMap] VARCHAR (20)  NULL,
    [ISOCode]          VARCHAR (20)  NULL,
    [StatusKey]        INT           NULL,
    CONSTRAINT [TMS_ContainerSize_pkey] PRIMARY KEY CLUSTERED ([ContainerSizeKey] ASC)
);

