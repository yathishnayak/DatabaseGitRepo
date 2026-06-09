CREATE TABLE [dbo].[DriverPayByCity] (
    [CityKey] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [City]    VARCHAR (50)    NOT NULL,
    [Amount]  DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_DriverPayByCity] PRIMARY KEY CLUSTERED ([CityKey] ASC) WITH (FILLFACTOR = 90)
);

