CREATE TABLE [dbo].[OrderSource] (
    [SourceKey]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description] VARCHAR (200) NOT NULL,
    [CompanyKey]  SMALLINT      CONSTRAINT [DF_OrderSource_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [TMS_OrderSource_pkey] PRIMARY KEY CLUSTERED ([SourceKey] ASC),
    CONSTRAINT [FK_TMS_OrderSource_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey])
);

