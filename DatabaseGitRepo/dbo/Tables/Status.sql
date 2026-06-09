CREATE TABLE [dbo].[Status] (
    [StatusKey]  SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [StatusName] VARCHAR (100) CONSTRAINT [DF_Status_StatusName] DEFAULT ((1)) NOT NULL,
    [CompanyKey] SMALLINT      CONSTRAINT [DF_Status_CompanyKey] DEFAULT ((1)) NOT NULL,
    [IsActive]   BIT           CONSTRAINT [DF_Status_IsActive] DEFAULT ((1)) NOT NULL,
    [CreateDate] DATETIME      CONSTRAINT [DF_Status_CreateDate] DEFAULT (getdate()) NOT NULL,
    [Type]       VARCHAR (20)  NOT NULL,
    CONSTRAINT [PK_Status] PRIMARY KEY CLUSTERED ([StatusKey] ASC),
    CONSTRAINT [FK_Status_Comp] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey])
);

