CREATE TABLE [dbo].[Carrier_LLC] (
    [LLCKey]     SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LLCName]    VARCHAR (200) NOT NULL,
    [CreateDate] DATETIME      NULL,
    [IsActive]   BIT           NULL,
    CONSTRAINT [PK_Carrier_LLC] PRIMARY KEY CLUSTERED ([LLCKey] ASC)
);

