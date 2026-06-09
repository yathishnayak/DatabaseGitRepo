CREATE TABLE [dbo].[DA_DeviceDetails] (
    [DeviceKey]      INT           IDENTITY (1, 1) NOT NULL,
    [UniqueID]       VARCHAR (200) NULL,
    [Model]          VARCHAR (100) NULL,
    [DeviceName]     VARCHAR (100) NULL,
    [Brand]          VARCHAR (100) NULL,
    [HardWare]       VARCHAR (100) NULL,
    [DeviceProduct]  VARCHAR (100) NULL,
    [DeviceVersion]  VARCHAR (50)  NULL,
    [Manufacturer]   VARCHAR (100) NULL,
    [AndroidSDK]     VARCHAR (50)  NULL,
    [Machine]        VARCHAR (100) NULL,
    [SystemName]     VARCHAR (100) NULL,
    [LocalizedModel] VARCHAR (100) NULL,
    [CreatedDate]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([DeviceKey] ASC)
);

