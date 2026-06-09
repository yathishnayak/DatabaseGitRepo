CREATE TABLE [dbo].[TruckStatus] (
    [TruckStatusKey] INT            IDENTITY (1, 1) NOT NULL,
    [TruckStatus]    NVARCHAR (200) NULL,
    [IsActive]       BIT            NULL,
    [IsDelete]       BIT            NULL,
    [OrderBy]        INT            NULL,
    CONSTRAINT [PK_TruckStatus] PRIMARY KEY CLUSTERED ([TruckStatusKey] ASC)
);

