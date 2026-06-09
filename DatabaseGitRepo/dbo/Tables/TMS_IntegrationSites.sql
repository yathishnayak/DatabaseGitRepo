CREATE TABLE [dbo].[TMS_IntegrationSites] (
    [SiteId]                     VARCHAR (50)  NOT NULL,
    [LocalWrkFolder]             VARCHAR (500) NOT NULL,
    [ImportFolder]               VARCHAR (500) NOT NULL,
    [ExportFolder]               VARCHAR (500) NOT NULL,
    [ErrorFolder]                VARCHAR (500) NOT NULL,
    [BackupFolder]               VARCHAR (500) NOT NULL,
    [LogFolder]                  VARCHAR (500) NOT NULL,
    [FtpHost]                    VARCHAR (500) NOT NULL,
    [FtpInBox]                   VARCHAR (500) NOT NULL,
    [FtpOutBox]                  VARCHAR (500) NOT NULL,
    [FtpId]                      VARCHAR (500) NOT NULL,
    [FtpPwd]                     VARCHAR (500) NOT NULL,
    [FtpDownload_FilenameFilter] VARCHAR (50)  NOT NULL,
    [TopNRecordsToProcess]       INT           NOT NULL,
    [FtpArchive]                 VARCHAR (500) NULL
);

