CREATE TABLE [dbo].[DriverRouteAcceptance_Log] (
    [LogKey]            INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AcceptanceKey]     INT          NOT NULL,
    [RouteKey]          INT          NOT NULL,
    [Description]       VARCHAR (50) NULL,
    [CreateDate]        DATETIME     NOT NULL,
    [RejectReasonKey]   SMALLINT     NULL,
    [RejectReasonDescr] VARCHAR (50) NULL,
    [CreateUserKey]     INT          NULL,
    [ActionDate]        DATETIME     CONSTRAINT [DF_DriverRouteAcceptance_Log_ActionDate] DEFAULT (getdate()) NULL,
    [ActionUser]        VARCHAR (50) NULL,
    [ActionType]        VARCHAR (50) NULL,
    CONSTRAINT [PK_DriverRouteAcceptance_Log] PRIMARY KEY CLUSTERED ([LogKey] ASC) WITH (FILLFACTOR = 90)
);

