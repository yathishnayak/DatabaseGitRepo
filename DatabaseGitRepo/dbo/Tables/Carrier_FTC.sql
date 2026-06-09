CREATE TABLE [dbo].[Carrier_FTC] (
    [FTCKey]     SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FTCName]    VARCHAR (200) NOT NULL,
    [CreateDate] DATETIME      NULL,
    [IsActive]   BIT           NULL,
    CONSTRAINT [PK_Carrier_FTC] PRIMARY KEY CLUSTERED ([FTCKey] ASC)
);

