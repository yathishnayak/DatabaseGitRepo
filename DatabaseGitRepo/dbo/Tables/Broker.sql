CREATE TABLE [dbo].[Broker] (
    [BrokerKey]         INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BrokerID]          VARCHAR (20)  NOT NULL,
    [BrokerName]        VARCHAR (255) NOT NULL,
    [AddrKey]           INT           NOT NULL,
    [CreateDate]        DATETIME      CONSTRAINT [DF_Broker_Createdate] DEFAULT (getdate()) NOT NULL,
    [StatusKey]         SMALLINT      CONSTRAINT [DF_Broker_Status] DEFAULT ((1)) NOT NULL,
    [StatusDate]        DATETIME      NOT NULL,
    [CompanyKey]        SMALLINT      CONSTRAINT [DF_Broker_CompanyKey] DEFAULT ((1)) NOT NULL,
    [IsActive]          BIT           NULL,
    [IsDelete]          BIT           NULL,
    [MarketLocationKey] INT           NULL,
    CONSTRAINT [Broker_PKey] PRIMARY KEY CLUSTERED ([BrokerKey] ASC),
    CONSTRAINT [FK_Broker_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Broker_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Broker_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

