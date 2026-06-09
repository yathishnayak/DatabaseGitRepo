CREATE TABLE [dbo].[Routes_ActualLog] (
    [ActualLogKey]    INT          IDENTITY (1, 1) NOT NULL,
    [RouteKey]        INT          NOT NULL,
    [CreateDate]      DATETIME     DEFAULT (getdate()) NOT NULL,
    [DateSource]      VARCHAR (50) NULL,
    [ActualArrival]   DATETIME     NULL,
    [ActualDeparture] DATETIME     NULL,
    [CreateUserKey]   INT          NULL,
    PRIMARY KEY CLUSTERED ([ActualLogKey] ASC)
);

