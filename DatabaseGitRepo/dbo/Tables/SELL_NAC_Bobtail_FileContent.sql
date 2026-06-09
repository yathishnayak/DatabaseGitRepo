CREATE TABLE [dbo].[SELL_NAC_Bobtail_FileContent] (
    [FileProcessKey] INT            NOT NULL,
    [JsonContent]    NVARCHAR (MAX) NULL,
    [DateUploaded]   DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([FileProcessKey] ASC)
);

