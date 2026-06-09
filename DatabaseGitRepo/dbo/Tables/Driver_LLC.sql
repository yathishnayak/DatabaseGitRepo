CREATE TABLE [dbo].[Driver_LLC] (
    [DriverKey]  INT      NOT NULL,
    [LLCKey]     SMALLINT NOT NULL,
    [IsSelected] BIT      NULL,
    [CreateDate] DATETIME NULL,
    [CreateUser] INT      NULL,
    [UpdateDate] DATETIME NULL,
    [UpdateUser] INT      NULL
);

