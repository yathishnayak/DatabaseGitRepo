CREATE TABLE [dbo].[Order_Delete] (
    [OrderKey]      INT      NOT NULL,
    [DeleteDate]    DATETIME NULL,
    [DeleteUserKey] INT      NULL,
    PRIMARY KEY CLUSTERED ([OrderKey] ASC) WITH (FILLFACTOR = 90)
);

