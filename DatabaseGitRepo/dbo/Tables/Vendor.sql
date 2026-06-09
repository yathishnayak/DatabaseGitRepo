CREATE TABLE [dbo].[Vendor] (
    [VendKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [VendID]     VARCHAR (20)  NOT NULL,
    [VendName]   VARCHAR (255) NOT NULL,
    [AddrKey]    INT           NOT NULL,
    [StatusKey]  SMALLINT      NOT NULL,
    [StatusDate] DATETIME      NOT NULL,
    [CompanyKey] SMALLINT      CONSTRAINT [DF_Vendor_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [Vendor_pkey] PRIMARY KEY CLUSTERED ([VendKey] ASC),
    CONSTRAINT [FK_Vendor_AddrKey] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Vendor_CompanyKey] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Vendor_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

