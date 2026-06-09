CREATE TABLE [dbo].[Gnosis_Integration_ContainerDataJson] (
    [RecordKey]         INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [GroupRecordID]     VARCHAR (50)   NULL,
    [PageNo]            INT            NULL,
    [ContainerDataJson] NVARCHAR (MAX) NULL,
    [CreatedDate]       DATETIME       NULL,
    [TOtalRecords]      INT            NULL,
    CONSTRAINT [PK_Gnosis_Integration_ContainerDataJson] PRIMARY KEY CLUSTERED ([RecordKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_ContainerDataJson_GroupRecordID_PageNo]
    ON [dbo].[Gnosis_Integration_ContainerDataJson]([GroupRecordID] ASC, [PageNo] ASC) WITH (FILLFACTOR = 90);

