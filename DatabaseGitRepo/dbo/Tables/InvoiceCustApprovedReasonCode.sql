CREATE TABLE [dbo].[InvoiceCustApprovedReasonCode] (
    [AprovedReasonCodeKey] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ApprovedReasonCode]   VARCHAR (100) NOT NULL,
    [CreatedBy]            INT           NULL,
    [CreatedDate]          DATETIME      NULL,
    [UpdatedBy]            INT           NULL,
    [UpdatedDate]          DATETIME      NULL,
    [IsActive]             BIT           NULL,
    [IsDeleted]            BIT           NULL,
    PRIMARY KEY CLUSTERED ([AprovedReasonCodeKey] ASC)
);

