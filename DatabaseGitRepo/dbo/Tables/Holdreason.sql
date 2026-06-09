CREATE TABLE [dbo].[Holdreason] (
    [HoldReasonKey] SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description]   VARCHAR (255) NOT NULL,
    [CompanyKey]    SMALLINT      CONSTRAINT [DF_Holdreason_CompanyKey] DEFAULT ((1)) NOT NULL,
    [StatusKey]     SMALLINT      NOT NULL,
    CONSTRAINT [TMS_Holdreason_pkey] PRIMARY KEY CLUSTERED ([HoldReasonKey] ASC),
    CONSTRAINT [FK_Holdreason_CompanyKey] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Holdreason_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

