CREATE TABLE [dbo].[SearchHistoryList] (
    [SearchID]          INT            IDENTITY (1, 1) NOT NULL,
    [SearchText]        NVARCHAR (MAX) NOT NULL,
    [CreateDate]        DATETIME       NULL,
    [UserKey]           INT            NOT NULL,
    [SearchCriteriaKey] INT            NOT NULL,
    [ScreenKey]         INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([SearchID] ASC)
);

