CREATE TABLE [dbo].[Gnosis_TrackingContainerRequestResponseDetail] (
    [TrackingContainerDetailKey] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TrackingContainerKey]       INT          NULL,
    [MBL]                        VARCHAR (50) NULL,
    [MBLTrackingReqUUID]         VARCHAR (50) NULL,
    [ContainerNo]                VARCHAR (50) NULL,
    [OrderDetailKey]             INT          NULL,
    [ContainerTrackingReqUUID]   VARCHAR (50) NULL,
    [IsTrackingEnabled]          BIT          NULL,
    [TrackingStatus]             VARCHAR (20) NULL,
    [CreatedDate]                DATETIME     NULL,
    [TrackingStatusUpdateDate]   DATETIME     NULL,
    CONSTRAINT [PK_Gnosis_TrackingContainerRequestResponseDetail] PRIMARY KEY CLUSTERED ([TrackingContainerDetailKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_TrackingContainerRequestResponseDetail_ContainerNo_ContainerTrackingReqUUID]
    ON [dbo].[Gnosis_TrackingContainerRequestResponseDetail]([ContainerNo] ASC, [ContainerTrackingReqUUID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_TrackingContainerRequestResponseDetail_IsTrackingEnabled]
    ON [dbo].[Gnosis_TrackingContainerRequestResponseDetail]([IsTrackingEnabled] ASC)
    INCLUDE([MBL], [ContainerNo]);

