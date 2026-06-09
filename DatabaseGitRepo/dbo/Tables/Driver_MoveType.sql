CREATE TABLE [dbo].[Driver_MoveType] (
    [DriverKey]   INT      NOT NULL,
    [MoveTypeKey] SMALLINT NOT NULL,
    [IsSelected]  BIT      CONSTRAINT [DF_Driver_MoveType_IsSelected] DEFAULT ((0)) NULL,
    [CreateDate]  DATETIME NULL,
    [CreateUser]  INT      NULL,
    [UpdateDate]  DATETIME NULL,
    [UpdateUser]  INT      NULL,
    CONSTRAINT [PK_Driver_MoveType] PRIMARY KEY CLUSTERED ([DriverKey] ASC, [MoveTypeKey] ASC) WITH (FILLFACTOR = 90)
);

