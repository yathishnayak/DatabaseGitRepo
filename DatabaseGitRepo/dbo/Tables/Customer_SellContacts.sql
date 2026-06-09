CREATE TABLE [dbo].[Customer_SellContacts] (
    [ContactKey]   INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ContactName]  NVARCHAR (100) NULL,
    [ContactEmail] NVARCHAR (100) NULL,
    [CustomerKey]  INT            NULL,
    [IsActive]     BIT            NULL,
    [IsDeleted]    BIT            NULL,
    CONSTRAINT [PK_Customer_SellContacts] PRIMARY KEY CLUSTERED ([ContactKey] ASC)
);

