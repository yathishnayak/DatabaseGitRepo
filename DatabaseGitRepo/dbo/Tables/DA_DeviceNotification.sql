CREATE TABLE [dbo].[DA_DeviceNotification] (
    [NotificationKey] INT            IDENTITY (1, 1) NOT NULL,
    [UserKey]         INT            NOT NULL,
    [DriverKey]       INT            NULL,
    [DeviceKey]       INT            NOT NULL,
    [FireBaseID]      VARCHAR (200)  NULL,
    [MessageHeader]   VARCHAR (500)  NOT NULL,
    [MessageDetail]   VARCHAR (1000) NOT NULL,
    [MessageType]     VARCHAR (50)   NULL,
    [CreatedDate]     DATETIME       CONSTRAINT [DF__DA_Notifi__Creat__49E588F6] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]       INT            NULL,
    [IsSent]          BIT            NULL,
    [SentDate]        DATETIME       NULL,
    [ReadDate]        DATETIME       CONSTRAINT [DF__DA_Device__ReadO__63A55AF9] DEFAULT (NULL) NULL,
    CONSTRAINT [PK__DA_Notif__BEEDDC57C5EAAAEC] PRIMARY KEY CLUSTERED ([NotificationKey] ASC)
);

