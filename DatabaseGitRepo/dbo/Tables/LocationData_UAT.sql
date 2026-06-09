CREATE TABLE [dbo].[LocationData_UAT] (
    [CityKey]          INT           NOT NULL,
    [Country]          VARCHAR (50)  NOT NULL,
    [State]            VARCHAR (100) NOT NULL,
    [City]             VARCHAR (100) NOT NULL,
    [ZipCode]          VARCHAR (100) NOT NULL,
    [StatusKey]        SMALLINT      NOT NULL,
    [CreateDate]       SMALLDATETIME NOT NULL,
    [IsActive]         BIT           NULL,
    [IsDelete]         BIT           NULL,
    [PriceGroupingKey] INT           NULL
);

