CREATE TABLE [dbo].[VoucherStatus] (
    [StatusKey]   SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description] VARCHAR (200) NOT NULL,
    [OrderBy]     SMALLINT      CONSTRAINT [DF_VoucherStatus_OrderBy] DEFAULT ((0)) NOT NULL,
    [IsActive]    BIT           CONSTRAINT [DF_VoucherStatus_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_VoucherStatus] PRIMARY KEY CLUSTERED ([StatusKey] ASC)
);

