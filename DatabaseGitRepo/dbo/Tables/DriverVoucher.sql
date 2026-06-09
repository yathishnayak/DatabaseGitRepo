CREATE TABLE [dbo].[DriverVoucher] (
    [DriverVoucherKey]    INT             IDENTITY (1, 1) NOT NULL,
    [DriverVoucherdate]   DATETIME        NULL,
    [DriverVoucherNumber] VARCHAR (50)    NULL,
    [DriverVoucherAmount] DECIMAL (18, 5) NULL,
    [DriverKey]           INT             NULL,
    [PaymentApprover]     INT             NULL,
    [CreateUser]          INT             NULL,
    [CreateDate]          DATETIME        NULL,
    [UpdateDate]          DATETIME        NULL,
    [UpdateUser]          INT             NULL,
    [WeekNumber]          INT             NULL,
    [ContainerNo]         VARCHAR (50)    NULL,
    [RouteKey]            INT             NULL,
    [LinkedVoucherKey]    INT             NULL,
    [IsRetroPay]          BIT             NULL,
    [StatusKey]           INT             NULL,
    CONSTRAINT [PK_DriverVoucher] PRIMARY KEY CLUSTERED ([DriverVoucherKey] ASC)
);

