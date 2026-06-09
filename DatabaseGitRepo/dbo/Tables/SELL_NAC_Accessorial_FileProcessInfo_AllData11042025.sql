CREATE TABLE [dbo].[SELL_NAC_Accessorial_FileProcessInfo_AllData11042025] (
    [FileProcessKey]    INT           IDENTITY (1, 1) NOT NULL,
    [FileName]          VARCHAR (100) NULL,
    [CustKey]           INT           NULL,
    [DateUploaded]      DATETIME      NULL,
    [FileUploadStatus]  BIT           NULL,
    [FileProcessStatus] BIT           NULL,
    [IsEmailSent]       BIT           NULL,
    [IsFileDownloaded]  BIT           NULL,
    [IsRecordUpdated]   BIT           NULL,
    [FileLink]          VARCHAR (100) NULL,
    [UserKey]           INT           NULL
);

