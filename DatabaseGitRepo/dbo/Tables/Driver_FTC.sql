CREATE TABLE [dbo].[Driver_FTC] (
    [DriverKey]  INT      NOT NULL,
    [FTCKey]     SMALLINT NOT NULL,
    [IsSelected] BIT      NULL,
    [CreateDate] DATETIME NULL,
    [CreateUser] INT      NULL,
    [UpdateDate] DATETIME NULL,
    [UpdateUser] INT      NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Driver_FTC_DriverKey]
    ON [dbo].[Driver_FTC]([DriverKey] ASC);

