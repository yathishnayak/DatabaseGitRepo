CREATE TABLE [dbo].[Gnosis_Integration_Holds] (
    [DataKey] INT          NULL,
    [CTF]     VARCHAR (50) NULL,
    [TMF]     VARCHAR (50) NULL,
    [Line]    VARCHAR (50) NULL,
    [Other]   VARCHAR (50) NULL,
    [Customs] VARCHAR (50) NULL,
    [Freight] VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [Ind_Gnosis_base_Holds_DataKey]
    ON [dbo].[Gnosis_Integration_Holds]([DataKey] ASC)
    INCLUDE([CTF], [TMF], [Line], [Other], [Customs]) WITH (FILLFACTOR = 90);

