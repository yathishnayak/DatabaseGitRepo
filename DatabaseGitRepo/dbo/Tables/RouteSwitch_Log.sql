CREATE TABLE [dbo].[RouteSwitch_Log] (
    [Logkey]        INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FromRouteKey]  INT          NULL,
    [ToRouteKey]    INT          NULL,
    [CreateDate]    DATETIME     NULL,
    [CreateUserKey] INT          NULL,
    [ActionDate]    DATETIME     CONSTRAINT [DF_RouteSwitch_Log_ActionDate] DEFAULT (getdate()) NULL,
    [ActionUser]    VARCHAR (50) NULL,
    [ActionType]    VARCHAR (50) NULL,
    CONSTRAINT [PK_RouteSwitch_Log] PRIMARY KEY CLUSTERED ([Logkey] ASC)
);

