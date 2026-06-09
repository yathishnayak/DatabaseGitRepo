CREATE TABLE [dbo].[RouteStatus] (
    [Status]      SMALLINT      IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Description] VARCHAR (200) NOT NULL,
    [OrderBy]     SMALLINT      CONSTRAINT [DF_RouteStatus_OrderBy] DEFAULT ((0)) NULL,
    [IsActive]    BIT           CONSTRAINT [DF_RouteStatus_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [TMS_Routestatus_pkey] PRIMARY KEY CLUSTERED ([Status] ASC)
);

