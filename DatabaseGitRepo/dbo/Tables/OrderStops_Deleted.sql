CREATE TABLE [dbo].[OrderStops_Deleted] (
    [OrderStopKey]  BIGINT        IDENTITY (1, 1) NOT NULL,
    [OrderKey]      INT           NOT NULL,
    [StopTypeKey]   SMALLINT      NULL,
    [StopName]      VARCHAR (100) NULL,
    [StopAddrKey]   INT           NULL,
    [StopNumber]    SMALLINT      NULL,
    [LocationType]  VARCHAR (20)  NULL,
    [StatusKey]     SMALLINT      NULL,
    [CreateDate]    DATETIME      NULL,
    [CreateUserKey] INT           NULL,
    [UpdateDate]    DATETIME      NULL,
    [UpdateUserKey] INT           NULL,
    [IsDeleted]     BIT           NULL,
    [DeleteUserKey] INT           NULL,
    [DeleteDate]    DATETIME      NULL
);

