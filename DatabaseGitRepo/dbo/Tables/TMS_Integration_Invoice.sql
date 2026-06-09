CREATE TABLE [dbo].[TMS_Integration_Invoice] (
    [SiteID]         VARCHAR (20) NOT NULL,
    [DataKey]        INT          NOT NULL,
    [InvoiceKey]     INT          NOT NULL,
    [ORderDetailKey] INT          NULL,
    CONSTRAINT [PK_TMS_Integration_Invoice] PRIMARY KEY CLUSTERED ([SiteID] ASC, [DataKey] ASC, [InvoiceKey] ASC) WITH (FILLFACTOR = 90)
);

