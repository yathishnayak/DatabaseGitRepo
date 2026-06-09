CREATE TABLE [dbo].[UserFirebase] (
    [UserKey]       INT           NOT NULL,
    [AppID]         VARCHAR (200) NOT NULL,
    [DeviceID]      VARCHAR (200) NOT NULL,
    [FirebaseToken] VARCHAR (500) NOT NULL,
    [CreatedDate]   DATETIME      NULL,
    CONSTRAINT [userfirebase_pkey] PRIMARY KEY CLUSTERED ([UserKey] ASC, [AppID] ASC, [DeviceID] ASC)
);

