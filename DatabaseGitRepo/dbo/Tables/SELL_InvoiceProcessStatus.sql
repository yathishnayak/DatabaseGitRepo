CREATE TABLE [dbo].[SELL_InvoiceProcessStatus] (
    [InvoiceKey]        INT            NOT NULL,
    [ProcStatus]        BIT            NULL,
    [ProcReason]        VARCHAR (500)  NULL,
    [DrayReason]        VARCHAR (1000) NULL,
    [BobtailReason]     VARCHAR (1000) NULL,
    [AccessorialReason] VARCHAR (1000) NULL,
    [CreateDate]        DATETIME       NULL,
    CONSTRAINT [PK__SELL_Inv__0A0624E0DC897E87] PRIMARY KEY CLUSTERED ([InvoiceKey] ASC) WITH (FILLFACTOR = 90)
);

