CREATE TABLE [dbo].[UserInfo] (
    [UserKey]            INT           NOT NULL,
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
    [Createdate]         DATETIME      NOT NULL,
    [LastloginDate]      DATETIME      NULL,
    [LoginAttempts]      SMALLINT      NULL,
    [PasswordTemp]       VARCHAR (50)  NULL,
    [CompanyKey]         SMALLINT      NOT NULL
);

