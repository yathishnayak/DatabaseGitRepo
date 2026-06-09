CREATE TABLE [dbo].[DA_ActiveDriverRoutes] (
    [DriverKey]   INT      NOT NULL,
    [RouteKey]    INT      NULL,
    [CreatedDate] DATETIME NULL,
    CONSTRAINT [PK_DA_ActiveDriverRoutes] PRIMARY KEY CLUSTERED ([DriverKey] ASC)
);

