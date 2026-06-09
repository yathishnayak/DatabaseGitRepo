CREATE TABLE [dbo].[MelroseIntegrate_MappedCustomers] (
    [MapCustKey]  INT      IDENTITY (1, 1) NOT NULL,
    [CustKey]     INT      NULL,
    [IsDeleted]   BIT      NULL,
    [DeletedUser] INT      NULL,
    [CreatedDate] DATETIME NULL,
    [UpdatedDate] DATETIME NULL,
    [CreatedBy]   INT      NULL,
    [UpdatedBy]   INT      NULL,
    CONSTRAINT [PK_MelroseIntegrate_MappedCustomers] PRIMARY KEY CLUSTERED ([MapCustKey] ASC)
);

