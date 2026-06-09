CREATE TABLE [dbo].[DriverLicenseTypes] (
    [DriverKey]      INT      NOT NULL,
    [LicenseType]    SMALLINT NOT NULL,
    [IsSelected]     BIT      NULL,
    [CreateUserKey]  INT      NULL,
    [UpdateUserKey]  INT      NULL,
    [CreateDate]     DATETIME NULL,
    [LastUpdateDate] DATETIME NULL,
    CONSTRAINT [PK_DriverLicenseTypes] PRIMARY KEY CLUSTERED ([DriverKey] ASC, [LicenseType] ASC) WITH (FILLFACTOR = 90)
);

