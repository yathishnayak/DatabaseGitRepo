CREATE TABLE [dbo].[LinkSearch] (
    [LinkSearchKey]     INT IDENTITY (1, 1) NOT NULL,
    [SearchCriteriaKey] INT NOT NULL,
    [ScreenKey]         INT NOT NULL,
    CONSTRAINT [PK_LinkSearch] PRIMARY KEY CLUSTERED ([LinkSearchKey] ASC)
);

