CREATE TABLE [dbo].[DA_DriverReasonCodeDetails] (
    [DriverReasonCodeKey] INT           IDENTITY (1, 1) NOT NULL,
    [DriverKey]           INT           NULL,
    [RouteKey]            INT           NULL,
    [ReasonCodeKey]       INT           NULL,
    [ReasonCodeText]      VARCHAR (500) NULL,
    [CreatedDate]         DATETIME      NULL,
    CONSTRAINT [PK_DA_DriverReasonCodeDetails] PRIMARY KEY CLUSTERED ([DriverReasonCodeKey] ASC)
);

