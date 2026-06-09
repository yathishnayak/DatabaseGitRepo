CREATE TABLE [dbo].[ContainerNum_AutoGen] (
    [AutoGenKey]     INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ContainerNo]    VARCHAR (50) NULL,
    [CustKey]        INT          NULL,
    [OrderTypeKey]   INT          NULL,
    [UserKey]        INT          NULL,
    [GenDateTime]    DATETIME     NULL,
    [OrderDetailKey] INT          NULL,
    CONSTRAINT [PK__Containe__71C5DD124D7F8AF0] PRIMARY KEY CLUSTERED ([AutoGenKey] ASC) WITH (FILLFACTOR = 90)
);

