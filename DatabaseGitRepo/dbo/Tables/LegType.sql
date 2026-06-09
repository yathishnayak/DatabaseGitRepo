CREATE TABLE [dbo].[LegType] (
    [LegtypeKey]    SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LegTypeID]     VARCHAR (50)  NULL,
    [OrderTypeKey]  SMALLINT      NOT NULL,
    [Instruction]   VARCHAR (500) NOT NULL,
    [StatusKey]     SMALLINT      CONSTRAINT [DF_DriverInstruction_Status] DEFAULT ('Active') NOT NULL,
    [CompanyKey]    SMALLINT      CONSTRAINT [DF_LegType_CompanyKey] DEFAULT ((1)) NOT NULL,
    [CreateUserKey] INT           NULL,
    [UpdateKey]     INT           NULL,
    CONSTRAINT [PK_DriverInstruction] PRIMARY KEY CLUSTERED ([LegtypeKey] ASC),
    CONSTRAINT [FK_DriverInstruction_DriverInstruction] FOREIGN KEY ([LegtypeKey]) REFERENCES [dbo].[LegType] ([LegtypeKey]),
    CONSTRAINT [FK_DriverInstruction_OrderType] FOREIGN KEY ([OrderTypeKey]) REFERENCES [dbo].[OrderType] ([OrderTypeKey]),
    CONSTRAINT [FK_DriverInstruction_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey]),
    CONSTRAINT [FK_LegType_CompanyKey] FOREIGN KEY ([CompanyKey]) REFERENCES [dbo].[Company] ([CompanyKey])
);

