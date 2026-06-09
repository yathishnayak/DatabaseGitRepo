CREATE TABLE [dbo].[Notifications] (
    [NotificationKey] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [UserKey]         INT           NOT NULL,
    [HeadText]        VARCHAR (100) NULL,
    [DetailText]      VARCHAR (500) NULL,
    [CreateDate]      DATETIME      NULL,
    [IsRead]          BIT           NULL,
    [ReadDateTime]    DATETIME      NULL,
    [isActive]        BIT           NULL,
    [SentUserKey]     INT           NULL,
    [RelatedTranType] VARCHAR (20)  NULL,
    [RelatedTranKey]  INT           NULL,
    CONSTRAINT [PK_Notifications] PRIMARY KEY CLUSTERED ([UserKey] ASC, [NotificationKey] ASC) WITH (FILLFACTOR = 90)
);

