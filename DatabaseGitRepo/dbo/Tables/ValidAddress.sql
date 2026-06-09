CREATE TABLE [dbo].[ValidAddress] (
    [ValidAddressKey] INT           IDENTITY (1, 1) NOT NULL,
    [Address1]        VARCHAR (MAX) NULL,
    [Address2]        VARCHAR (MAX) NULL,
    [City]            VARCHAR (MAX) NULL,
    [State]           VARCHAR (MAX) NULL,
    [ZipCode]         VARCHAR (50)  NULL,
    [Country]         CHAR (3)      NULL,
    PRIMARY KEY CLUSTERED ([ValidAddressKey] ASC)
);

