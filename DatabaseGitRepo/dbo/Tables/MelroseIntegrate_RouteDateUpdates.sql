CREATE TABLE [dbo].[MelroseIntegrate_RouteDateUpdates] (
    [Datakey]             INT          IDENTITY (1, 1) NOT NULL,
    [OrderKey]            INT          NULL,
    [RouteKey]            INT          NULL,
    [UpdateColumnName]    VARCHAR (50) NULL,
    [IsRouteRecordUpdate] BIT          NULL,
    [IsInitiated]         BIT          NULL,
    [InitiatedDate]       DATETIME     NULL,
    [IsDataSenttoMelrose] BIT          NULL,
    [SentToMelroseDate]   DATETIME     NULL,
    [CreatedDate]         DATETIME     NULL,
    CONSTRAINT [PK_MelroseIntegrate_RouteDateUpdates] PRIMARY KEY CLUSTERED ([Datakey] ASC)
);

