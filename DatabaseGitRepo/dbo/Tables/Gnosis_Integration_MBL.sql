CREATE TABLE [dbo].[Gnosis_Integration_MBL] (
    [DataKey]    INT          NULL,
    [UUID]       VARCHAR (50) NULL,
    [MBL_number] VARCHAR (50) NULL,
    [Dropped]    VARCHAR (50) NULL
);


GO
CREATE NONCLUSTERED INDEX [Ind_Gnosis_base_MBL_DataKey]
    ON [dbo].[Gnosis_Integration_MBL]([DataKey] ASC)
    INCLUDE([Dropped]) WITH (FILLFACTOR = 90);

