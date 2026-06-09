CREATE TABLE [dbo].[OrderDetailStatus] (
    [Status]      SMALLINT      NOT NULL,
    [Description] VARCHAR (100) NOT NULL,
    [IsActive]    BIT           CONSTRAINT [DF_TMS_OrderDetailStatus_IsActive] DEFAULT ((1)) NOT NULL,
    [StatusType]  VARCHAR (50)  NULL,
    [OrderBy]     INT           NULL,
    [IsScheduler] BIT           NULL,
    [IsDispatch]  BIT           NULL,
    CONSTRAINT [TMS_OrderDetailStatus_pkey] PRIMARY KEY CLUSTERED ([Status] ASC)
);

