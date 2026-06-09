CREATE TABLE [dbo].[SELL_NAC_Bobtail_FileProcessInfo] (
    [FileProcessKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileName]          VARCHAR (100) NULL,
    [CustKey]           INT           NULL,
    [DateUploaded]      DATETIME      NULL,
    [FileUploadStatus]  BIT           NULL,
    [FileProcessStatus] BIT           NULL,
    [IsEmailSent]       BIT           NULL,
    [IsFileDownloaded]  BIT           NULL,
    [IsRecordUpdated]   BIT           NULL,
    [FileLink]          VARCHAR (100) NULL,
    [UserKey]           INT           NULL,
    CONSTRAINT [PK_SELL_Bobtail_NACFileProcessInfo] PRIMARY KEY CLUSTERED ([FileProcessKey] ASC)
);

