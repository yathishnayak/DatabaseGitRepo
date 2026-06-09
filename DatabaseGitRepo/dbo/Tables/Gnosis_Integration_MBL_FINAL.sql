CREATE TABLE [dbo].[Gnosis_Integration_MBL_FINAL] (
    [UUID]       VARCHAR (50) NOT NULL,
    [MBL_number] VARCHAR (50) NULL,
    [Dropped]    VARCHAR (50) NULL,
    CONSTRAINT [PK_Gnosis_Integration_MBL_FINAL] PRIMARY KEY CLUSTERED ([UUID] ASC) WITH (FILLFACTOR = 90)
);

