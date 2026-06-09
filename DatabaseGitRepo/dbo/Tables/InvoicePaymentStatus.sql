CREATE TABLE [dbo].[InvoicePaymentStatus] (
    [StatusKey]   INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description] VARCHAR (50) NULL,
    [OrderBy]     INT          NULL,
    [IsActive]    BIT          NULL,
    [IsDeleted]   BIT          NULL,
    [StatusType]  VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([StatusKey] ASC)
);

