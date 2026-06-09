CREATE TABLE [dbo].[Consignee] (
    [ConsigneeKey]  INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ConsigneeID]   VARCHAR (50)  NULL,
    [Name]          VARCHAR (500) NULL,
    [AddrKey]       INT           NULL,
    [CustKey]       INT           NULL,
    [StatusKey]     SMALLINT      CONSTRAINT [DF_Consignee_Status] DEFAULT ((1)) NULL,
    [CompanyKey]    SMALLINT      CONSTRAINT [DF_Consignee_CompanyKey] DEFAULT ((1)) NULL,
    [CreateUserKey] INT           CONSTRAINT [DF_Consignee_CreateUserKey] DEFAULT ((1)) NULL,
    [CreateDate]    DATETIME      NULL,
    [UpdateUserKey] INT           NULL,
    [UpdateDate]    DATETIME      NULL,
    [CSRKey]        INT           NULL,
    [CSRManagerKey] INT           NULL,
    CONSTRAINT [PK_Consignee] PRIMARY KEY CLUSTERED ([ConsigneeKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Consignee_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Consignee_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Consignee_Customer] FOREIGN KEY ([CustKey]) REFERENCES [dbo].[Customer] ([CustKey]),
    CONSTRAINT [FK_Consignee_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_Consignee_CustKey]
    ON [dbo].[Consignee]([CustKey] ASC);

