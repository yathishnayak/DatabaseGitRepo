CREATE TABLE [dbo].[OrderStatus] (
    [Status]      SMALLINT      NOT NULL,
    [Description] VARCHAR (200) NOT NULL,
    [OrderBy]     SMALLINT      CONSTRAINT [DF_OrderStatus_OrderBy] DEFAULT ((0)) NULL,
    [IsActive]    BIT           CONSTRAINT [DF_OrderStatus_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [TMS_orderstatus_pkey] PRIMARY KEY CLUSTERED ([Status] ASC)
);

