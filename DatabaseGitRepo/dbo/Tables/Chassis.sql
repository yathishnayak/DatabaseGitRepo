CREATE TABLE [dbo].[Chassis] (
    [chassisKey]        INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [chassisNo]         VARCHAR (50) NOT NULL,
    [CreateDate]        DATETIME     CONSTRAINT [DF_Chassis_CreateDate] DEFAULT (getdate()) NOT NULL,
    [ChassisType]       VARCHAR (50) NULL,
    [StatusKey]         SMALLINT     CONSTRAINT [DF_Chassis_StatusKey] DEFAULT ((1)) NOT NULL,
    [CompanyKey]        SMALLINT     CONSTRAINT [DF_Chassis_CompanyKey] DEFAULT ((1)) NULL,
    [IsEditable]        BIT          NULL,
    [CreateUser]        INT          NULL,
    [UpdateDate]        DATETIME     NULL,
    [UpdateUser]        INT          NULL,
    [IsActive]          BIT          NULL,
    [IsDelete]          BIT          NULL,
    [MarketLocationKey] INT          NULL,
    CONSTRAINT [Chassis_PKey] PRIMARY KEY CLUSTERED ([chassisKey] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_Chassis_Company] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey]),
    CONSTRAINT [FK_Chassis_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

