CREATE TABLE [dbo].[ShippingPort] (
    [ShippingPortKey]   INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ShippingPortID]    VARCHAR (50) NOT NULL,
    [AddrKey]           INT          NOT NULL,
    [StatusKey]         SMALLINT     CONSTRAINT [DF_ShippingPort_Status] DEFAULT ((1)) NOT NULL,
    [CompanyKey]        SMALLINT     CONSTRAINT [DF_ShippingPort_CompanyKey] DEFAULT ((1)) NULL,
    [MarketLocationKey] INT          NULL,
    [IsActive]          BIT          NULL,
    [IsDeleted]         BIT          NULL,
    [CreateDate]        DATETIME     NULL,
    [CreateUserKey]     INT          NULL,
    [Updatedate]        DATETIME     NULL,
    [UpdateUserKey]     INT          NULL,
    [PriceGroupingKey]  INT          NULL,
    CONSTRAINT [Shippingport_pkey] PRIMARY KEY CLUSTERED ([ShippingPortKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_ShippingPort_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_ShippingPort_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_ShippingPort_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

