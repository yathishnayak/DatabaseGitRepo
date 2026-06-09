CREATE TABLE [dbo].[DriverLicenseInfo] (
    [DriverKey]              INT          NOT NULL,
    [TractorLicenseNo]       VARCHAR (50) NULL,
    [TwicExpiryDate]         DATE         NULL,
    [TruckRegExpiryDate]     DATE         NULL,
    [ApportionedPlateExpiry] DATE         NULL,
    [GPSSerialNo]            VARCHAR (50) NULL,
    [LeaseDateExpiry]        DATE         NULL,
    [PDTRLB]                 DATETIME     NULL,
    [PDTRLA]                 DATETIME     NULL,
    [DMVPNDateAdd]           DATE         NULL,
    [DMVPNDateDelete]        DATE         NULL,
    [CreateUserKey]          INT          NULL,
    [UpdateUserKey]          INT          NULL,
    [CreateDate]             DATETIME     NULL,
    [LastUpdateDate]         DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([DriverKey] ASC) WITH (FILLFACTOR = 90)
);

