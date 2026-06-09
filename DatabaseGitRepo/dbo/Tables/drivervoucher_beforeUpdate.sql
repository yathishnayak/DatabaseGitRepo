CREATE TABLE [dbo].[drivervoucher_beforeUpdate] (
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
    [ContainerNo]         VARCHAR (50)    NULL
);

