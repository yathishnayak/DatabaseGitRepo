CREATE TABLE [dbo].[DA_AppDriverScreenDetails] (
    [DriverRouteKey]    INT      IDENTITY (1, 1) NOT NULL,
    [DriverKey]         INT      NULL,
    [UserKey]           INT      NULL,
    [RouteKey]          INT      NULL,
    [ConfirmPickup]     BIT      NULL,
    [ConfirmEquipments] BIT      NULL,
    [PickUpDocs]        BIT      NULL,
    [ConfirmDelivery]   BIT      NULL,
    [DeliveryDocs]      BIT      NULL,
    [PairContainer]     BIT      NULL,
    [Charges]           BIT      NULL,
    [Complete]          BIT      NULL,
    [CompleteDate]      DATETIME NULL,
    [CreatedDate]       DATETIME NULL,
    [UpdatedDate]       DATETIME NULL,
    CONSTRAINT [PK_DA_AppDriverScreenDetails] PRIMARY KEY CLUSTERED ([DriverRouteKey] ASC) WITH (FILLFACTOR = 90)
);

