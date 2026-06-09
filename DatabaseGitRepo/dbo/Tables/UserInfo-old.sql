CREATE TABLE [dbo].[UserInfo-old] (
    [UserKey]            INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UserID]             VARCHAR (255) NULL,
    [Password]           VARCHAR (500) NULL,
    [PasswordExpiryDate] DATETIME2 (7) NULL,
    [Firstname]          VARCHAR (255) NOT NULL,
    [Lastname]           VARCHAR (255) NOT NULL,
    [Addrkey]            INT           NOT NULL,
    [Statuskey]          SMALLINT      NOT NULL,
    [StatusDate]         DATETIME      NULL,
    [Approvedby]         INT           NOT NULL,
    [ApproveDtimeStamp]  DATETIME      NOT NULL,
    [Createdate]         DATETIME      CONSTRAINT [DF_UserInfo_Createdate] DEFAULT (getdate()) NOT NULL,
    [LastloginDate]      DATETIME      NULL,
    [LoginAttempts]      SMALLINT      NULL,
    [PasswordTemp]       VARCHAR (50)  NULL,
    [CompanyKey]         SMALLINT      CONSTRAINT [DF_UserInfo_CompanyKey] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [UserInfo_Pkey] PRIMARY KEY CLUSTERED ([UserKey] ASC) WITH (FILLFACTOR = 90)
);

