CREATE TABLE [dbo].[Gnosis_TrackingContainerRequestResponse] (
    [TrackingContainerKey] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RequestSent]          NVARCHAR (MAX) NULL,
    [ResponseRcvd]         NVARCHAR (MAX) NULL,
    [CreatedDate]          DATETIME       NULL,
    CONSTRAINT [PK_Gnosis_TrackingContainerRequestResponse] PRIMARY KEY CLUSTERED ([TrackingContainerKey] ASC)
);

