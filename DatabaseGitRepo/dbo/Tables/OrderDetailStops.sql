CREATE TABLE [dbo].[OrderDetailStops] (
    [OrderDetailStopKey]            BIGINT        IDENTITY (1, 1) NOT NULL,
    [OrderDetailKey]                INT           NOT NULL,
    [OrderStopKey]                  BIGINT        NULL,
    [StopTypeKey]                   SMALLINT      NULL,
    [StopName]                      VARCHAR (100) NULL,
    [StopNameSetUserKey]            INT           NULL,
    [StopNameSetDateTime]           DATETIME      NULL,
    [StopAddrKey]                   INT           NULL,
    [StopNumber]                    SMALLINT      NULL,
    [LocationType]                  VARCHAR (20)  NULL,
    [SchedulePickupDate]            DATETIME      NULL,
    [SchedulePickupUserKey]         INT           NULL,
    [SchedulePickupSetDateTime]     DATETIME      NULL,
    [SchedulePickupDateTo]          DATETIME      NULL,
    [SchedulePickupToUserKey]       DATETIME      NULL,
    [SchedulePickupToSetDateTime]   DATETIME      NULL,
    [ActualPickupDate]              DATETIME      NULL,
    [ActualPickupUserKey]           INT           NULL,
    [ActualPickupSetDateTime]       DATETIME      NULL,
    [ScheduleDeliveryDate]          DATETIME      NULL,
    [ScheduleDeliveryUserKey]       INT           NULL,
    [ScheduleDeliverySetDateTime]   DATETIME      NULL,
    [ScheduleDeliveryDateTo]        DATETIME      NULL,
    [ScheduleDeliveryToUserKey]     DATETIME      NULL,
    [ScheduleDeliveryToSetDateTime] DATETIME      NULL,
    [ActualDeliveryDate]            DATETIME      NULL,
    [ActualDeliveryUserKey]         INT           NULL,
    [ActualDeliverySetDateTime]     DATETIME      NULL,
    [ToRouteKey]                    INT           NULL,
    [FromRouteKey]                  INT           NULL,
    [StatusKey]                     SMALLINT      NULL,
    [CreateDate]                    DATETIME      NULL,
    [CreateUserKey]                 INT           NULL,
    [UpdateDate]                    DATETIME      NULL,
    [UpdateUserKey]                 INT           NULL,
    [IsDryRunPort]                  BIT           NULL,
    [DryRunPortSetDateTime]         DATETIME      NULL,
    [DryRunPortSetUserKey]          INT           NULL,
    [IsDryRunCustomer]              BIT           NULL,
    [DryRunCustomerSetDateTime]     DATETIME      NULL,
    [DryRunCustomerSetUserKey]      INT           NULL,
    [RefNo]                         VARCHAR (50)  NULL,
    [IsTMFChecked]                  BIT           NULL,
    [IsCTFChecked]                  BIT           NULL,
    [TMFCheckUserKey]               INT           NULL,
    [CTFCheckUserKey]               INT           NULL,
    [TMFCheckDate]                  DATETIME      NULL,
    [CTFCheckDate]                  DATETIME      NULL,
    [ReasonCode]                    INT           NULL,
    [DropOrLive]                    CHAR (1)      NULL,
    [DropOrLiveSetUserKey]          INT           NULL,
    [DropOrLiveSetDatetime]         DATETIME      NULL,
    [ExceptionReasonCode]           INT           NULL,
    [ExceptionRCSetUserKey]         INT           NULL,
    [ExceptionRCSetDateTime]        DATETIME      NULL,
    [IsDeleted]                     BIT           NULL,
    [DeleteUserKey]                 INT           NULL,
    [DeleteDate]                    DATETIME      NULL,
    [IsBobTail]                     BIT           NULL,
    [BobtailSetDateTime]            DATETIME      NULL,
    [BobtailSetUserKey]             INT           NULL,
    [IsEmpty]                       BIT           NULL,
    [EmptySetDateTime]              DATETIME      NULL,
    [EmptySetUserKey]               INT           NULL,
    [IsStreetTurn]                  BIT           NULL,
    [StreetSturnSetDateTime]        DATETIME      NULL,
    [StreetSturnSetUserKey]         INT           NULL,
    [IsChassisSplit]                BIT           NULL,
    [ChassisSplitSetDateTime]       DATETIME      NULL,
    [ChassisSplitSetUserKey]        INT           NULL,
    [Is247Pickup]                   BIT           NULL,
    [Is247PickupMarkedby]           INT           NULL,
    [Is247PickupMarkedDate]         DATETIME      NULL,
    [Is247Delivery]                 BIT           NULL,
    [Is247DeliveryMarkedBy]         INT           NULL,
    [Is247DeliveryMarkedDate]       DATETIME      NULL,
    [StopIndex]                     INT           NULL,
    CONSTRAINT [PK_OrderDetailStops] PRIMARY KEY CLUSTERED ([OrderDetailStopKey] ASC),
    CONSTRAINT [FK_OrderDetailStops_Address] FOREIGN KEY ([StopAddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_OrderDetailStops_OrderDetail] FOREIGN KEY ([OrderDetailKey]) REFERENCES [dbo].[OrderDetail] ([OrderDetailKey]),
    CONSTRAINT [FK_OrderDetailStops_OrderStops] FOREIGN KEY ([OrderStopKey]) REFERENCES [dbo].[OrderStops] ([OrderStopKey]),
    CONSTRAINT [FK_OrderDetailStops_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey]),
    CONSTRAINT [FK_OrderDetailStops_StopsMaster] FOREIGN KEY ([StopTypeKey]) REFERENCES [dbo].[StopsMaster] ([StopTypeKey]),
    CONSTRAINT [FK_OrderDetailStops_User] FOREIGN KEY ([DeleteUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserActualSet] FOREIGN KEY ([ActualPickupUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserCreated] FOREIGN KEY ([CreateUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserCTFSet] FOREIGN KEY ([CTFCheckUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserDropLiveSet] FOREIGN KEY ([DropOrLiveSetUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserExceptionRCSet] FOREIGN KEY ([ExceptionRCSetUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserScheduled] FOREIGN KEY ([SchedulePickupUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserTMFSet] FOREIGN KEY ([TMFCheckUserKey]) REFERENCES [dbo].[User] ([UserKey]),
    CONSTRAINT [FK_OrderDetailStops_UserUpdated] FOREIGN KEY ([UpdateUserKey]) REFERENCES [dbo].[User] ([UserKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailStops]
    ON [dbo].[OrderDetailStops]([OrderDetailStopKey] ASC, [StopTypeKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailStops_FromRouteKey]
    ON [dbo].[OrderDetailStops]([FromRouteKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailStops_2]
    ON [dbo].[OrderDetailStops]([OrderDetailKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailStops_ToRouteKey]
    ON [dbo].[OrderDetailStops]([ToRouteKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailStops_LocationType]
    ON [dbo].[OrderDetailStops]([LocationType] ASC)
    INCLUDE([OrderStopKey]);


GO
CREATE NONCLUSTERED INDEX [IX_OrderDetailStops_StopTypeKey]
    ON [dbo].[OrderDetailStops]([StopTypeKey] ASC)
    INCLUDE([OrderDetailKey], [StopAddrKey], [IsDryRunCustomer]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Port / Customer / Consignee / Shipper / Yard / Etc', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'OrderDetailStops', @level2type = N'COLUMN', @level2name = N'LocationType';

