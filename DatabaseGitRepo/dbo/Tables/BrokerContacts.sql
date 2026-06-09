CREATE TABLE [dbo].[BrokerContacts] (
    [BrokerKey]  INT NOT NULL,
    [ContactKey] INT NOT NULL,
    CONSTRAINT [BrokerContacts_PKey] PRIMARY KEY CLUSTERED ([BrokerKey] ASC, [ContactKey] ASC),
    CONSTRAINT [FK_BrokerContacts_Broker] FOREIGN KEY ([BrokerKey]) REFERENCES [dbo].[Broker] ([BrokerKey]),
    CONSTRAINT [FK_BrokerContacts_Contacts] FOREIGN KEY ([ContactKey]) REFERENCES [dbo].[Contacts] ([ContactKey])
);

