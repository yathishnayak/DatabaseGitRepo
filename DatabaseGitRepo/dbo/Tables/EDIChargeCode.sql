CREATE TABLE [dbo].[EDIChargeCode] (
    [Code]        VARCHAR (3)   NOT NULL,
    [Description] VARCHAR (500) NULL,
    CONSTRAINT [PK_EDIChargeCode] PRIMARY KEY CLUSTERED ([Code] ASC) WITH (FILLFACTOR = 90)
);

