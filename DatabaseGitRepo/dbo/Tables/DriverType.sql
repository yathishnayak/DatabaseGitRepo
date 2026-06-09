CREATE TABLE [dbo].[DriverType] (
    [DriverTypeKey]  SMALLINT     NOT NULL,
    [DriverTypeName] VARCHAR (50) NULL,
    [isActive]       BIT          NULL,
    [DateCreated]    DATETIME     NULL,
    [DateUpdated]    DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([DriverTypeKey] ASC)
);

