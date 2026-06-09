CREATE TABLE [dbo].[Client] (
    [ClientKey]         INT           NOT NULL,
    [ClientID]          VARCHAR (50)  NULL,
    [ClientName]        VARCHAR (200) NULL,
    [AddrKey]           INT           NULL,
    [StatusKey]         SMALLINT      NULL,
    [CreateDate]        DATETIME      NULL,
    [CreateUserKey]     INT           NULL,
    [LastUpdateDate]    DATETIME      NULL,
    [LastUpdateUserKey] INT           NULL,
    CONSTRAINT [PK_BaseRateNew] PRIMARY KEY CLUSTERED ([ClientKey] ASC),
    CONSTRAINT [FK_BaseRateNew_Address] FOREIGN KEY ([AddrKey]) REFERENCES [dbo].[Address] ([AddrKey]),
    CONSTRAINT [FK_BaseRateNew_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

