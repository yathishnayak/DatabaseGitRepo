CREATE TABLE [dbo].[COST_FileProcessInfo] (
    [FileProcessKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileName]          VARCHAR (100) NULL,
    [DateUploaded]      DATETIME      NULL,
    [MarketLocation]    VARCHAR (50)  NULL,
    [FileUploadStatus]  BIT           NULL,
    [FileProcessStatus] BIT           NULL,
    [IsEmailSent]       BIT           NULL,
    [IsFileDownloaded]  BIT           NULL,
    [IsRecordUpdated]   BIT           NULL,
    [FileLink]          VARCHAR (100) NULL,
    [UserKey]           INT           NULL,
    CONSTRAINT [PK_Cost_FileProcessInfo] PRIMARY KEY CLUSTERED ([FileProcessKey] ASC)
);

