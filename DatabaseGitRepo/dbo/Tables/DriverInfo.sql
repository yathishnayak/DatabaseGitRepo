CREATE TABLE [dbo].[DriverInfo] (
    [DriverKey]       INT             NOT NULL,
    [SSNNo]           VARBINARY (100) NULL,
    [BirthDate]       DATE            NULL,
    [DateLeftCompany] DATE            NULL,
    [Notes]           VARCHAR (1000)  NULL,
    [EmmContactName]  VARCHAR (100)   NULL,
    [EmmContactPhone] VARCHAR (50)    NULL,
    [CreateUserKey]   INT             NULL,
    [UpdateUserKey]   INT             NULL,
    [CreateDate]      DATETIME        NULL,
    [LastUpdateDate]  DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([DriverKey] ASC) WITH (FILLFACTOR = 90)
);

