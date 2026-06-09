CREATE TABLE [dbo].[City] (
    [CityKey]    INT           NOT NULL,
    [Country]    VARCHAR (20)  CONSTRAINT [DF_City_Country] DEFAULT ('USA') NULL,
    [State]      NCHAR (10)    NULL,
    [City]       VARCHAR (255) NULL,
    [ZipCode]    NCHAR (10)    NULL,
    [Statuskey]  INT           NULL,
    [CreateDate] DATETIME      CONSTRAINT [DF_City_CreateDate] DEFAULT (getdate()) NOT NULL,
    [IsActive]   BIT           NULL,
    [IsDelete]   BIT           NULL,
    CONSTRAINT [PK_City] PRIMARY KEY CLUSTERED ([CityKey] ASC)
);

