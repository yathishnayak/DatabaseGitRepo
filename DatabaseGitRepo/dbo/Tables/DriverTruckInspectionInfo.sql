CREATE TABLE [dbo].[DriverTruckInspectionInfo] (
    [DriverKey]      INT             NOT NULL,
    [SlNo]           SMALLINT        NOT NULL,
    [InspectionDate] DATE            NULL,
    [IsPass]         BIT             NULL,
    [isFail]         BIT             NULL,
    [InvoiceNo]      VARCHAR (50)    NULL,
    [InvoiceDate]    DATE            NULL,
    [InvoiceAmount]  DECIMAL (18, 3) NULL,
    [CreateDate]     DATETIME        NULL,
    [UpdateDate]     DATETIME        NULL,
    [CreateUserKey]  INT             NULL,
    [UpdateUserKey]  INT             NULL,
    CONSTRAINT [PK_DriverTruckInspectionInfo] PRIMARY KEY CLUSTERED ([DriverKey] ASC, [SlNo] ASC) WITH (FILLFACTOR = 90)
);

