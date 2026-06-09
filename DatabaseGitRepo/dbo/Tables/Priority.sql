CREATE TABLE [dbo].[Priority] (
    [PriorityKey] SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description] VARCHAR (100) NULL,
    [ColorCode]   VARCHAR (50)  NULL,
    [StatusKey]   SMALLINT      CONSTRAINT [DF_Priority_StatusKey] DEFAULT ((1)) NULL,
    [CompanyKey]  SMALLINT      CONSTRAINT [DF_Priority_CompanyKey] DEFAULT ((1)) NULL,
    [IsWarehouse] BIT           NULL,
    CONSTRAINT [TMS_Priority_pkey] PRIMARY KEY CLUSTERED ([PriorityKey] ASC),
    CONSTRAINT [FK_Priority_company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Priority_status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

