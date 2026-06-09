CREATE TABLE [dbo].[Company] (
    [CompanyKey]  SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CompanyID]   VARCHAR (20)  NOT NULL,
    [CompanyName] VARCHAR (50)  NOT NULL,
    [AddrKey]     INT           NOT NULL,
    [CreateDate]  DATETIME      CONSTRAINT [DF_Company_CreateDate] DEFAULT (getdate()) NOT NULL,
    [StatusKey]   SMALLINT      CONSTRAINT [DF_Company_Status] DEFAULT ((1)) NOT NULL,
    [StatusDate]  SMALLDATETIME NULL,
    CONSTRAINT [Company_pkey] PRIMARY KEY CLUSTERED ([CompanyKey] ASC),
    CONSTRAINT [FK_Company_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Company_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

