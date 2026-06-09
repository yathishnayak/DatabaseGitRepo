CREATE TABLE [dbo].[TMS_Contacts] (
    [ContactKey]    INT           NOT NULL,
    [ContactID]     VARCHAR (20)  NULL,
    [FirstName]     VARCHAR (100) NOT NULL,
    [LastName]      VARCHAR (100) NULL,
    [ContactNumber] VARCHAR (30)  NULL,
    [ContactType]   SMALLINT      NULL,
    [AddrKey]       INT           NULL,
    [StatusKey]     SMALLINT      NOT NULL
);

