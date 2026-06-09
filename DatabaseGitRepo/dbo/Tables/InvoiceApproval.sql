CREATE TABLE [dbo].[InvoiceApproval] (
    [InvoiceType]     VARCHAR (10) NOT NULL,
    [InvoiceKey]      INT          NOT NULL,
    [IsApproved]      BIT          CONSTRAINT [DF_InvoiceApproval_IsApproved] DEFAULT ((0)) NULL,
    [ApprovedUserKey] INT          NULL,
    [ApprovedDate]    DATETIME     NULL,
    CONSTRAINT [PK_InvoiceApproval] PRIMARY KEY CLUSTERED ([InvoiceType] ASC, [InvoiceKey] ASC)
);

