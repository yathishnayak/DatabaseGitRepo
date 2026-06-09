CREATE TABLE [dbo].[GeoEventTracking] (
    [RecordKey]       BIGINT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UserKey]         INT               NULL,
    [EventKey]        SMALLINT          NULL,
    [GeoCordinates]   [sys].[geography] NULL,
    [CaptureDateTime] DATETIME          NULL,
    CONSTRAINT [PK_GeoEventTracking] PRIMARY KEY CLUSTERED ([RecordKey] ASC)
);

