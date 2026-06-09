CREATE TABLE [dbo].[Contacts] (
    [ContactKey]    INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ContactID]     VARCHAR (20)  NULL,
    [FirstName]     VARCHAR (100) NOT NULL,
    [LastName]      VARCHAR (100) NULL,
    [ContactNumber] VARCHAR (30)  NULL,
    [ContactType]   SMALLINT      NULL,
    [AddrKey]       INT           NULL,
    [StatusKey]     SMALLINT      CONSTRAINT [DF_contacts_Status] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [Contacts_PKey] PRIMARY KEY CLUSTERED ([ContactKey] ASC),
    CONSTRAINT [FK_Contacts_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_Contacts_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

