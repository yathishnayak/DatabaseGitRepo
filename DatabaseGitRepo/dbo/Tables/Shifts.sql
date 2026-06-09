CREATE TABLE [dbo].[Shifts] (
    [ShiftKey]  SMALLINT     IDENTITY (1, 1) NOT NULL,
    [ShiftName] VARCHAR (50) NULL,
    [IsActive]  BIT          DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([ShiftKey] ASC)
);

