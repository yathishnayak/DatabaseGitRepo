CREATE TABLE [dbo].[DriverVoucherDeduction] (
    [DriverVoucherKey]       INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DriverVoucherdate]      DATETIME        NULL,
    [DriverVoucherNumber]    VARCHAR (50)    NULL,
    [DriverVoucherAmount]    DECIMAL (18, 5) NULL,
    [DriverKey]              INT             NULL,
    [PaymentApprover]        VARCHAR (50)    NULL,
    [CreateUser]             VARCHAR (50)    NULL,
    [CreateDate]             DATETIME        NULL,
    [UpdateDate]             DATETIME        NULL,
    [UpdateUser]             VARCHAR (50)    NULL,
    [WeekNumber]             INT             NULL,
    [IsRecurring]            BIT             NULL,
    [RecurrSourceVoucherKey] INT             NULL,
    PRIMARY KEY CLUSTERED ([DriverVoucherKey] ASC) WITH (FILLFACTOR = 90)
);

