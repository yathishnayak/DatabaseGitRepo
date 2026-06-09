CREATE TABLE [dbo].[DriverScreeningInfo] (
    [DriverKey]      INT             NOT NULL,
    [ScreenTypeKey]  SMALLINT        NOT NULL,
    [SlNo]           SMALLINT        NOT NULL,
    [ScreenDate]     DATE            NULL,
    [IsPass]         BIT             NULL,
    [IsFail]         BIT             NULL,
    [InvoiceNo]      VARCHAR (50)    NULL,
    [InvoiceDate]    DATE            NULL,
    [InvoiceAmount]  DECIMAL (18, 3) NULL,
    [CreateUserKey]  INT             NULL,
    [UpdateUserKey]  INT             NULL,
    [CreateDate]     DATETIME        NULL,
    [LastUpdateDate] DATETIME        NULL,
    CONSTRAINT [PK_DriverScreeningInfo] PRIMARY KEY CLUSTERED ([DriverKey] ASC, [ScreenTypeKey] ASC, [SlNo] ASC) WITH (FILLFACTOR = 90)
);

