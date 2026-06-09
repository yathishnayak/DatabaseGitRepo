CREATE TABLE [dbo].[Address_UAT] (
    [AddrKey]  INT           NOT NULL,
    [AddrName] VARCHAR (255) NOT NULL,
    [Address1] VARCHAR (255) NOT NULL,
    [Address2] VARCHAR (255) NULL,
    [City]     VARCHAR (255) NULL,
    [State]    VARCHAR (255) NULL,
    [ZipCode]  VARCHAR (50)  NULL,
    [Country]  CHAR (3)      NULL,
    [Website]  VARCHAR (255) NULL,
    [Phone]    VARCHAR (20)  NULL,
    [Email]    VARCHAR (255) NULL,
    [Fax]      VARCHAR (20)  NULL,
    [Phone2]   VARCHAR (20)  NULL,
    [Email2]   VARCHAR (50)  NULL,
    [CityKey]  INT           NULL
);

