CREATE TABLE [dbo].[Gnosis_Integration_Holds_Final] (
    [UUID]       VARCHAR (50) NOT NULL,
    [CTF]        VARCHAR (50) NULL,
    [TMF]        VARCHAR (50) NULL,
    [Line]       VARCHAR (50) NULL,
    [Other]      VARCHAR (50) NULL,
    [Customs]    VARCHAR (50) NULL,
    [Freight]    VARCHAR (50) NULL,
    [ClosedArea] VARCHAR (50) CONSTRAINT [DF_Gnosis_ClosedArea] DEFAULT ('false') NULL,
    CONSTRAINT [PK_Gnosis_Integration_Holds_Final] PRIMARY KEY CLUSTERED ([UUID] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Holds_Final_CTF]
    ON [dbo].[Gnosis_Integration_Holds_Final]([CTF] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Holds_Final_Customs]
    ON [dbo].[Gnosis_Integration_Holds_Final]([Customs] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Holds_Final_Freight]
    ON [dbo].[Gnosis_Integration_Holds_Final]([Freight] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Holds_Final_Line]
    ON [dbo].[Gnosis_Integration_Holds_Final]([Line] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Holds_Final_Other]
    ON [dbo].[Gnosis_Integration_Holds_Final]([Other] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Gnosis_Integration_Holds_Final_TMF]
    ON [dbo].[Gnosis_Integration_Holds_Final]([TMF] ASC);

