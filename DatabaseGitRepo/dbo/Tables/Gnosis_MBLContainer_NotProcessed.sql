CREATE TABLE [dbo].[Gnosis_MBLContainer_NotProcessed] (
    [MBL]            VARCHAR (50) NOT NULL,
    [ContainerNo]    VARCHAR (50) NULL,
    [OrderDetailKey] INT          NOT NULL,
    [CreatedDate]    DATETIME     NULL,
    CONSTRAINT [PK_Gnosis_MBLContainer_NotProcessed] PRIMARY KEY CLUSTERED ([MBL] ASC, [OrderDetailKey] ASC) WITH (FILLFACTOR = 90)
);

