CREATE TABLE [dbo].[CarrierMoveType] (
    [MoveTypeKey]  SMALLINT     IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MoveTypeName] VARCHAR (50) NOT NULL,
    [CreateDate]   DATETIME     CONSTRAINT [DF_CarrierMoveType_CreateDate] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CarrierMoveType] PRIMARY KEY CLUSTERED ([MoveTypeKey] ASC)
);

