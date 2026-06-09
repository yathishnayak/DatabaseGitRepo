CREATE TABLE [dbo].[TruckType] (
    [TruckTypeKey] INT           NOT NULL,
    [TruckType]    VARCHAR (100) NULL,
    [IsActive]     BIT           NULL,
    [IsDeleted]    BIT           NULL,
    [CreatedDate]  DATETIME      NULL,
    CONSTRAINT [PK_TruckType] PRIMARY KEY CLUSTERED ([TruckTypeKey] ASC)
);

