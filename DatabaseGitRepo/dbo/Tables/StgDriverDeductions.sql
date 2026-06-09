CREATE TABLE [dbo].[StgDriverDeductions] (
    [RowKey]        INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [VehicleNo]     VARCHAR (20)    NULL,
    [VoucherDate]   DATE            NULL,
    [TranDate]      DATE            NULL,
    [ItemId]        VARCHAR (30)    NULL,
    [Quantity]      DECIMAL (18, 2) NULL,
    [Amount]        DECIMAL (18, 2) NULL,
    [Remarks]       VARCHAR (50)    NULL,
    [ProcessStatus] BIT             CONSTRAINT [DF_StgDriverDeductions_ProcessStatus] DEFAULT ((0)) NULL,
    [DriverId]      VARCHAR (20)    NULL,
    CONSTRAINT [PK_StgDriverDeductions] PRIMARY KEY CLUSTERED ([RowKey] ASC)
);

