CREATE TABLE [dbo].[DriverRouteAbandon] (
    [AbandonKey]       INT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RouteKey]         INT      NOT NULL,
    [CreateDate]       DATETIME NOT NULL,
    [AbandonReasonKey] SMALLINT NULL,
    [CreateUserKey]    INT      NULL,
    [DriverKey]        INT      NULL,
    CONSTRAINT [PK_DriverRouteAbandon] PRIMARY KEY CLUSTERED ([AbandonKey] ASC)
);

