CREATE TABLE [dbo].[Routes_DateTracker] (
    [RouteKey]      INT         NULL,
    [DateType]      VARCHAR (5) NULL,
    [DateTime]      DATETIME    NULL,
    [CreateDate]    DATETIME    NULL,
    [CreateUserKey] INT         NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_DateTracker_RouteKey]
    ON [dbo].[Routes_DateTracker]([RouteKey] ASC);


GO
CREATE NONCLUSTERED INDEX [DateType_Includes]
    ON [dbo].[Routes_DateTracker]([DateType] ASC)
    INCLUDE([RouteKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_DateTracker_DateType]
    ON [dbo].[Routes_DateTracker]([DateType] ASC)
    INCLUDE([RouteKey], [DateTime]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_Routes_DateTracker_RouteKey_DateType]
    ON [dbo].[Routes_DateTracker]([RouteKey] ASC, [DateType] ASC);

