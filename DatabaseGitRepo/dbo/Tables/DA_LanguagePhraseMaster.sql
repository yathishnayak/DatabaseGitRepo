CREATE TABLE [dbo].[DA_LanguagePhraseMaster] (
    [LangPhraseKey] INT           IDENTITY (1, 1) NOT NULL,
    [PhraseName]    VARCHAR (100) NULL,
    CONSTRAINT [PK_DA_LanguagePhraseMaster] PRIMARY KEY CLUSTERED ([LangPhraseKey] ASC)
);

