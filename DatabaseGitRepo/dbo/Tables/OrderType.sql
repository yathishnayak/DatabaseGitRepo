CREATE TABLE [dbo].[OrderType] (
    [OrderTypeKey] SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [OrderType]    VARCHAR (100) NOT NULL,
    [Description]  VARCHAR (100) NULL,
    [StatusKey]    SMALLINT      CONSTRAINT [DF_TMS_OrderType_Status] DEFAULT ((1)) NOT NULL,
    [CompanyKey]   SMALLINT      CONSTRAINT [DF_OrderType_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [TMS_OrderType_pkey] PRIMARY KEY CLUSTERED ([OrderTypeKey] ASC),
    CONSTRAINT [FK_TMS_OrderType_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_TMS_OrderType_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

