CREATE TABLE [dbo].[DriverExceptionDetails] (
    [DriverExceptionDetailsKey] INT            IDENTITY (1, 1) NOT NULL,
    [DriverKey]                 INT            NULL,
    [OrderDetailKey]            INT            NULL,
    [RouteKey]                  INT            NULL,
    [DriverExceptionKey]        INT            NULL,
    [DriverExceptionText]       VARCHAR (1000) NULL,
    [CreateDate]                DATETIME       NULL,
    CONSTRAINT [PK_DriverExceptionDetails_1] PRIMARY KEY CLUSTERED ([DriverExceptionDetailsKey] ASC)
);

