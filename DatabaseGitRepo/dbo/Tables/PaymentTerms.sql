CREATE TABLE [dbo].[PaymentTerms] (
    [PaymentTermsKey] SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PaymentTermsID]  VARCHAR (50)  NOT NULL,
    [Days]            SMALLINT      NULL,
    [Description]     VARCHAR (300) NULL,
    [CompanyKey]      SMALLINT      CONSTRAINT [DF_PaymentTerms_CompanyKey] DEFAULT ((1)) NOT NULL,
    [StatusKey]       SMALLINT      CONSTRAINT [DF_PaymentTerms_StatusKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_PaymentTerms] PRIMARY KEY CLUSTERED ([PaymentTermsKey] ASC),
    CONSTRAINT [FK_PaymentTerms_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_PaymentTerms_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

