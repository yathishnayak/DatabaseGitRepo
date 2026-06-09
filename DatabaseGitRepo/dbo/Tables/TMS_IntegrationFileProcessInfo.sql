CREATE TABLE [dbo].[TMS_IntegrationFileProcessInfo] (
    [FileProcessKey]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileName]         VARCHAR (500) NOT NULL,
    [DateReceived]     DATETIME      NOT NULL,
    [DateProcessed]    DATETIME      NULL,
    [IsProcessed]      BIT           NULL,
    [DataKey]          INT           NULL,
    [SiteID]           VARCHAR (50)  NULL,
    [ResponseType]     VARCHAR (20)  NULL,
    [IsResponseSent]   BIT           NULL,
    [ResponseSentDate] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([FileProcessKey] ASC)
);

