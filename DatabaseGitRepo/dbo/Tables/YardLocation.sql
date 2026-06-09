CREATE TABLE [dbo].[YardLocation] (
    [LocationKey] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]        VARCHAR (50) NULL,
    [IsActive]    BIT          CONSTRAINT [DF_YardLocation_ISActive] DEFAULT ((1)) NULL,
    [CreatedDate] DATETIME     CONSTRAINT [DF_YardLocation_CreatedDate] DEFAULT (getdate()) NULL,
    [YardID]      SMALLINT     NOT NULL,
    CONSTRAINT [PK_YardLocation] PRIMARY KEY CLUSTERED ([LocationKey] ASC),
    CONSTRAINT [FK_YardLocation_Yard] FOREIGN KEY ([YardID]) REFERENCES [dbo].[Yard] ([YardId])
);

