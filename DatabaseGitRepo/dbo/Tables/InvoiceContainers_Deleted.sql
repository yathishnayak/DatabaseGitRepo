CREATE TABLE [dbo].[InvoiceContainers_Deleted] (
    [InvoiceKey]      INT          NULL,
    [OrderDetailsKey] INT          NULL,
    [ContainerNo]     VARCHAR (20) NULL,
    [TerminationDate] DATETIME     NULL,
    [DeleteUserKey]   INT          NULL,
    [DeletedDate]     DATETIME     NULL
);

