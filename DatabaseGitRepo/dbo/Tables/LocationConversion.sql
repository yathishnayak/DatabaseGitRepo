CREATE TABLE [dbo].[LocationConversion] (
    [Location]        VARCHAR (50) NOT NULL,
    [LocationConvert] VARCHAR (50) NULL,
    CONSTRAINT [PK_LocationConversion] PRIMARY KEY CLUSTERED ([Location] ASC)
);

