CREATE TABLE [dbo].[Gnosis_Integration_ImportDrayageDetails] (
    [UUID]        VARCHAR (100) NULL,
    [DrayageUUID] VARCHAR (100) NULL,
    [ContainerNo] VARCHAR (50)  NULL,
    [BOL]         VARCHAR (50)  NULL,
    [DrayageType] VARCHAR (20)  NULL,
    [IsProcessed] BIT           NULL,
    [CreatedDate] DATETIME      NULL,
    [EmptyDate]   DATETIME      NULL
);

