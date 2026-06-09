CREATE TABLE [dbo].[Carrier] (
    [CarrierKey]             INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CarrierID]              VARCHAR (50)  NOT NULL,
    [CarrierName]            VARCHAR (100) NOT NULL,
    [IssteamLine]            BIT           NULL,
    [Addrkey]                INT           NULL,
    [ScacCode]               VARCHAR (4)   NULL,
    [LicensePlate]           VARCHAR (255) NULL,
    [LicensePlateExpiryDate] DATE          NULL,
    [CreateDate]             DATETIME      CONSTRAINT [DF_Carrier_CreateDate] DEFAULT (getdate()) NOT NULL,
    [StatusKey]              SMALLINT      CONSTRAINT [DF_Carrier_Status] DEFAULT ((1)) NOT NULL,
    [StatusDate]             DATETIME      NULL,
    [CompanyKey]             SMALLINT      CONSTRAINT [DF_Carrier_CompanyKey] DEFAULT ((1)) NULL,
    [IsActive]               BIT           NULL,
    [IsDelete]               BIT           NULL,
    CONSTRAINT [Carrier_PKey] PRIMARY KEY CLUSTERED ([CarrierKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Carrier_Address] FOREIGN KEY ([Addrkey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Carrier_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Carrier_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

