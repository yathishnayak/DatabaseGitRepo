CREATE TABLE [dbo].[ItemRateCal] (
    [ItemKey]        INT             NULL,
    [ItemDesc]       VARCHAR (200)   NULL,
    [CityKey1]       INT             NULL,
    [CDKey]          INT             NULL,
    [LocationRate1]  DECIMAL (18, 2) NULL,
    [CityKey2]       INT             NULL,
    [LocationRate2]  DECIMAL (18, 2) NULL,
    [ItemMasterRate] DECIMAL (18, 2) NULL,
    [ItemType]       VARCHAR (50)    NULL
);

