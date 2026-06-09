CREATE TABLE [dbo].[DriverOrder] (
    [OrderKey]     INT      NOT NULL,
    [StartDate]    DATETIME NULL,
    [CompleteDate] DATETIME NULL,
    CONSTRAINT [PK_DriverOrder] PRIMARY KEY CLUSTERED ([OrderKey] ASC)
);

