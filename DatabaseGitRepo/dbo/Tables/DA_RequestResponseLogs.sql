CREATE TABLE [dbo].[DA_RequestResponseLogs] (
    [LogKey]               INT            IDENTITY (1, 1) NOT NULL,
    [ProcedureName]        VARCHAR (200)  NULL,
    [UserKey]              INT            NULL,
    [RequestJSONString]    NVARCHAR (MAX) NULL,
    [FirebaseID]           VARCHAR (500)  NULL,
    [IsDebug]              BIT            NULL,
    [OutputStatus]         BIT            NULL,
    [OutputInternalError]  NVARCHAR (MAX) NULL,
    [OutputExternallError] VARCHAR (1000) NULL,
    [IsLogout]             BIT            NULL,
    [ReponseJSONString]    NVARCHAR (MAX) NULL,
    [CreatedDate]          DATETIME       NULL,
    [UpdatedDate]          DATETIME       NULL,
    CONSTRAINT [PK_DA_RequestResponseLogs] PRIMARY KEY CLUSTERED ([LogKey] ASC)
);

