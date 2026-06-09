CREATE TABLE [dbo].[CustomerContacts] (
    [CustKey]    INT NOT NULL,
    [ContactKey] INT NOT NULL,
    CONSTRAINT [CustomerContacts_PKey] PRIMARY KEY CLUSTERED ([CustKey] ASC, [ContactKey] ASC),
    CONSTRAINT [FK_CustomerContacts_Contacts] FOREIGN KEY ([ContactKey]) REFERENCES [dbo].[Contacts] ([ContactKey]),
    CONSTRAINT [FK_CustomerContacts_Customer] FOREIGN KEY ([CustKey]) REFERENCES [dbo].[Customer] ([CustKey])
);

