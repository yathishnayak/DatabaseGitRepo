CREATE TABLE [dbo].[Driver] (
    [DriverKey]                INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DriverID]                 VARCHAR (20)  NULL,
    [FirstName]                VARCHAR (100) NOT NULL,
    [LastName]                 VARCHAR (100) NULL,
    [AddrKey]                  INT           NULL,
    [CarrierKey]               INT           NULL,
    [DrivingLicenseNo]         VARCHAR (50)  NULL,
    [DrivingLicenseExpiryDate] DATETIME      NULL,
    [CreateDate]               DATETIME      CONSTRAINT [DF_Driver_CreateDate] DEFAULT (getdate()) NOT NULL,
    [StatusKey]                SMALLINT      CONSTRAINT [DF_Driver_Status] DEFAULT ((1)) NOT NULL,
    [StatusDate]               DATETIME      NOT NULL,
    [VendKey]                  INT           NULL,
    [CompanyKey]               SMALLINT      CONSTRAINT [DF_Driver_CompanyKey] DEFAULT ((1)) NOT NULL,
    [HireDate]                 DATETIME      NULL,
    [Plate]                    VARCHAR (20)  NULL,
    [YearMake]                 VARCHAR (20)  NULL,
    [VINId]                    VARCHAR (50)  NULL,
    [RFID]                     VARCHAR (20)  NULL,
    [ContactNo]                VARCHAR (30)  NULL,
    [OrgName]                  VARCHAR (100) NULL,
    [OrgZipCode]               VARCHAR (20)  NULL,
    [FuelCardNo]               VARCHAR (50)  NULL,
    [OrgCity]                  VARCHAR (100) NULL,
    [OrgState]                 VARCHAR (100) NULL,
    [OrgCountry]               VARCHAR (100) NULL,
    [LastUpdateDate]           DATETIME      NULL,
    [CreateUserKey]            INT           NULL,
    [LastUpdateUserKey]        INT           NULL,
    [TractorLicenseNo]         VARCHAR (50)  NULL,
    [DriverHubKey]             INT           NULL,
    [PhysicalAddrKey]          INT           NULL,
    [TelePhone]                VARCHAR (50)  NULL,
    [BusinessNumber]           VARCHAR (50)  NULL,
    [CellNumber]               VARCHAR (50)  NULL,
    [FaxNumber]                VARCHAR (50)  NULL,
    [EmailAddress]             VARCHAR (200) NULL,
    [DOTNumber]                VARCHAR (100) NULL,
    [MCNumber]                 VARCHAR (100) NULL,
    [TaxIDNumber]              VARCHAR (100) NULL,
    [YearsUnderCurrentName]    INT           NULL,
    [FactoringCompany]         VARCHAR (100) NULL,
    [InsuranceCompany]         VARCHAR (100) NULL,
    [PolicyNumber]             VARCHAR (100) NULL,
    [PolicyExpDate]            DATETIME      NULL,
    [insuranceAgentName]       VARCHAR (100) NULL,
    [InsuranceAgentNumber]     VARCHAR (100) NULL,
    [PayTypeKey]               SMALLINT      NULL,
    [NoOfTrucks]               INT           NULL,
    [IsActive]                 BIT           NULL,
    [IsDelete]                 BIT           NULL,
    [MarketLocationKey]        INT           NULL,
    [TruckTypeKey]             INT           NULL,
    CONSTRAINT [Driver_pkey] PRIMARY KEY CLUSTERED ([DriverKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Driver_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Driver_Carrier] FOREIGN KEY ([CarrierKey]) REFERENCES [dbo].[Carrier] ([CarrierKey]),
    CONSTRAINT [FK_Driver_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Driver_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey]),
    CONSTRAINT [FK_Driver_Vendor] FOREIGN KEY ([VendKey]) REFERENCES [dbo].[Vendor] ([VendKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_Driver_CellNumber]
    ON [dbo].[Driver]([CellNumber] ASC)
    INCLUDE([DriverID], [FirstName], [LastName]);


GO
CREATE NONCLUSTERED INDEX [IX_Driver_DriverID_DriverKey]
    ON [dbo].[Driver]([DriverID] ASC, [DriverKey] ASC);

