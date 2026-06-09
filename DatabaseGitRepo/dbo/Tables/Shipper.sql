CREATE TABLE [dbo].[Shipper] (
    [ShipperID]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]              VARCHAR (100) NULL,
    [ShipperVesselName] VARCHAR (300) NULL,
    [AddrKey]           INT           NULL,
    [StatusKey]         SMALLINT      CONSTRAINT [DF_Shipper_Status] DEFAULT ((1)) NULL,
    [CreateUserKey]     INT           CONSTRAINT [DF_Shipper_CreateUserKey] DEFAULT ((1)) NULL,
    [CreateDate]        DATETIME      NULL,
    [CompanyKey]        SMALLINT      CONSTRAINT [DF_Shipper_CompanyKey] DEFAULT ((1)) NULL,
    CONSTRAINT [PK__Shipper__1F8AFFB9A3E77AA3] PRIMARY KEY CLUSTERED ([ShipperID] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Shipper_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Shipper_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

