CREATE TABLE [dbo].[CustomerItem] (
    [CutomerItemKey]       INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [MasterCustomerKey]    INT           NULL,
    [MasterItemKey]        INT           NULL,
    [ChargeCode]           VARCHAR (10)  NULL,
    [ChargeDescription]    VARCHAR (500) NULL,
    [IsActive]             BIT           NULL,
    [IsDeleted]            BIT           NULL,
    [CreatedBy]            INT           NULL,
    [CreatedDate]          DATETIME      NULL,
    [UpdatedBy]            INT           NULL,
    [UpdatedDate]          DATETIME      NULL,
    [ShowCustomerItemDesc] BIT           NULL,
    [ShowChargeCode]       BIT           NULL,
    PRIMARY KEY CLUSTERED ([CutomerItemKey] ASC)
);

