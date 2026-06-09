CREATE TABLE [dbo].[DriverVoucherDeduction_deleted] (
    [DriverVoucherKey]       INT             NOT NULL,
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
    [DeleteUserKey]          INT             NULL,
    [DeletedDate]            DATETIME        NULL
);

