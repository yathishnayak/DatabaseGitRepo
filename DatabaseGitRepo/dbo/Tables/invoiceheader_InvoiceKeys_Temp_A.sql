CREATE TABLE [dbo].[invoiceheader_InvoiceKeys_Temp_A] (
    [invoicekey]      INT          IDENTITY (1, 1) NOT NULL,
    [Invoiceno]       VARCHAR (50) NOT NULL,
    [PreviousUserKey] INT          NOT NULL,
    [CorrectUserKey]  INT          NULL
);

