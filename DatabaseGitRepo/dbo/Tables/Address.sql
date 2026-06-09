CREATE TABLE [dbo].[Address] (
    [AddrKey]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AddrName]        VARCHAR (255) NOT NULL,
    [Address1]        VARCHAR (255) NOT NULL,
    [Address2]        VARCHAR (255) NULL,
    [City]            VARCHAR (255) NULL,
    [State]           VARCHAR (255) NULL,
    [ZipCode]         VARCHAR (50)  NULL,
    [Country]         CHAR (3)      NULL,
    [Website]         VARCHAR (255) NULL,
    [Phone]           VARCHAR (20)  NULL,
    [Email]           VARCHAR (255) NULL,
    [Fax]             VARCHAR (20)  NULL,
    [Phone2]          VARCHAR (20)  NULL,
    [Email2]          VARCHAR (50)  NULL,
    [CityKey]         INT           NULL,
    [IsValid]         SMALLINT      NULL,
    [ValidAddressKey] INT           NULL,
    CONSTRAINT [Address_PKey] PRIMARY KEY CLUSTERED ([AddrKey] ASC),
    CONSTRAINT [FK_Address_LocationData] FOREIGN KEY ([CityKey]) REFERENCES [dbo].[LocationData] ([CityKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_Address_AddrName_City_State_ZipCode_24386]
    ON [dbo].[Address]([AddrName] ASC, [City] ASC, [State] ASC, [ZipCode] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Address_Address1]
    ON [dbo].[Address]([Address1] ASC);

