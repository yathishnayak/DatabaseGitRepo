CREATE TABLE [dbo].[LicenseTypes] (
    [LicenseTypeKey]  SMALLINT     NOT NULL,
    [LicenseTypeName] VARCHAR (50) NOT NULL,
    [isActive]        BIT          NULL,
    [DateCreated]     DATE         NULL,
    PRIMARY KEY CLUSTERED ([LicenseTypeKey] ASC)
);

