CREATE TABLE [dbo].[ACERInvoiceProcess_Delete] (
    [OrderNo]            VARCHAR (20)    NOT NULL,
    [WorkOrdernumber]    VARCHAR (20)    NOT NULL,
    [InvoiceNo]          VARCHAR (50)    NOT NULL,
    [InvoiceDate]        DATE            NOT NULL,
    [InvoiceAmount]      DECIMAL (18, 2) NOT NULL,
    [InvoiceKey]         INT             NOT NULL,
    [OrderKey]           INT             NOT NULL,
    [DataKey]            INT             NOT NULL,
    [OrderDetailKey]     INT             NOT NULL,
    [ContainerNo]        VARCHAR (20)    NOT NULL,
    [SiteID]             VARCHAR (20)    NULL,
    [ContainerKey]       INT             NOT NULL,
    [ItemDetails]        NVARCHAR (MAX)  NULL,
    [ItemWOEDICodeCount] INT             NULL
);

