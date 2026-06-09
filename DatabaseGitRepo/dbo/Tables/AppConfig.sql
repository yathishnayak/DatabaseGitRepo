CREATE TABLE [dbo].[AppConfig] (
    [CompanyKey]   INT           NOT NULL,
    [ConfigId]     INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ConfigName]   VARCHAR (100) NOT NULL,
    [ConfigValue1] VARCHAR (100) NOT NULL,
    [ConfigValue2] VARCHAR (100) NULL,
    [ConfigValue3] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([CompanyKey] ASC, [ConfigId] ASC) WITH (FILLFACTOR = 90)
);

