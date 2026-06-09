CREATE TABLE [dbo].[Gnosis_TrackingContainerRequestResponseDetail_20240919] (
    [TrackingContainerDetailKey] INT          IDENTITY (1, 1) NOT NULL,
    [TrackingContainerKey]       INT          NULL,
    [MBL]                        VARCHAR (50) NULL,
    [MBLTrackingReqUUID]         VARCHAR (50) NULL,
    [ContainerNo]                VARCHAR (50) NULL,
    [OrderDetailKey]             INT          NULL,
    [ContainerTrackingReqUUID]   VARCHAR (50) NULL,
    [IsTrackingEnabled]          BIT          NULL,
    [TrackingStatus]             VARCHAR (20) NULL,
    [CreatedDate]                DATETIME     NULL,
    [TrackingStatusUpdateDate]   DATETIME     NULL
);

