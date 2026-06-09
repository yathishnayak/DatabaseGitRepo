CREATE TABLE [dbo].[DriverTruckInfo] (
    [DriverKey]           INT          NOT NULL,
    [DriverType]          SMALLINT     NOT NULL,
    [TruckOwnerFirstName] VARCHAR (50) NULL,
    [TruckOwnerLastName]  VARCHAR (50) NULL,
    [TruckOwnerPhoneNo]   VARCHAR (50) NULL,
    [EIN]                 VARCHAR (50) NULL,
    [TruckInspectionDate] DATE         NULL,
    [CHPInspectionDate]   DATE         NULL,
    [SmokeCheckDate]      DATE         NULL,
    [CreateUserKey]       INT          NULL,
    [UpdateUserKey]       INT          NULL,
    [CreateDate]          DATETIME     NULL,
    [LastUpdateDate]      DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([DriverKey] ASC) WITH (FILLFACTOR = 90)
);

