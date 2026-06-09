CREATE TABLE [dbo].[EDRAY_StopList] (
    [StopKey]             INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ContainerKey]        INT           NOT NULL,
    [stopType]            VARCHAR (50)  NULL,
    [stopName]            VARCHAR (100) NULL,
    [stopNumber]          VARCHAR (10)  NULL,
    [facilityCode]        VARCHAR (50)  NULL,
    [stopReferenceNumber] VARCHAR (10)  NULL,
    [address1]            VARCHAR (100) NULL,
    [city]                VARCHAR (100) NULL,
    [state]               VARCHAR (20)  NULL,
    [country]             VARCHAR (20)  NULL,
    [postalCode]          VARCHAR (20)  NULL,
    [equipmentNumber]     VARCHAR (50)  NULL,
    [equipmentTypeCode]   VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([StopKey] ASC)
);

