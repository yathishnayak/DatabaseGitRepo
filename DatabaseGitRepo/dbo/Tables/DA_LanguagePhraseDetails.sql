CREATE TABLE [dbo].[DA_LanguagePhraseDetails] (
    [LangPhraseDetailskey] INT            IDENTITY (1, 1) NOT NULL,
    [LanguageName]         NVARCHAR (MAX) NULL,
    [LangPhraseKey]        INT            NULL,
    [PhraseName]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_DA_LanguagePhraseDetails] PRIMARY KEY CLUSTERED ([LangPhraseDetailskey] ASC) WITH (FILLFACTOR = 90)
);

