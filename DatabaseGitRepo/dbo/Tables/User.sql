CREATE TABLE [dbo].[User] (
    [UserKey]           INT          NOT NULL,
    [UserName]          VARCHAR (50) NOT NULL,
    [MarketLocationKey] INT          CONSTRAINT [DF_User_MarketLocationKey] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([UserKey] ASC) WITH (FILLFACTOR = 90)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identity Column', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'UserKey';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Store User Name from AspNetUsers', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'User', @level2type = N'COLUMN', @level2name = N'UserName';

