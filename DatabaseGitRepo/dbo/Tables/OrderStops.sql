CREATE TABLE [dbo].[OrderStops] (
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
    [DeleteDate]    DATETIME      NULL,
    CONSTRAINT [PK_OrderStops] PRIMARY KEY CLUSTERED ([OrderStopKey] ASC),
    CONSTRAINT [FK_OrderStops_Address] FOREIGN KEY ([StopAddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_OrderStops_OrderHeader] FOREIGN KEY ([OrderKey]) REFERENCES [dbo].[OrderHeader] ([OrderKey]),
    CONSTRAINT [FK_OrderStops_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey]),
    CONSTRAINT [FK_OrderStops_StopsMaster] FOREIGN KEY ([StopTypeKey]) REFERENCES [dbo].[StopsMaster] ([StopTypeKey]),
    CONSTRAINT [FK_OrderStops_UserCreated] FOREIGN KEY ([CreateUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderStops_UserDeleted] FOREIGN KEY ([DeleteUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderStops_UserUpdated] FOREIGN KEY ([UpdateUserKey]) REFERENCES [dbo].[User] ([UserKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderStops]
    ON [dbo].[OrderStops]([OrderKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderStops_1]
    ON [dbo].[OrderStops]([OrderStopKey] ASC, [StopTypeKey] ASC, [StopNumber] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Port / Customer / Consignee / Shipper / Yard / Etc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderStops', @level2type = N'COLUMN', @level2name = N'LocationType';

