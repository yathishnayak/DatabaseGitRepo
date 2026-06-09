CREATE TABLE [dbo].[ScreenNames] (
    [ScreenKey]  INT            IDENTITY (1, 1) NOT NULL,
    [ScreenName] NVARCHAR (100) NOT NULL,
    [ShortCode]  NVARCHAR (50)  NULL,
    CONSTRAINT [PK_ScreenNames] PRIMARY KEY CLUSTERED ([ScreenKey] ASC)
);

