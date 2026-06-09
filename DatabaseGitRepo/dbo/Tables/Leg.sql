CREATE TABLE [dbo].[Leg] (
    [LegKey]                SMALLINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LegTypeKey]            SMALLINT        NOT NULL,
    [LegID]                 VARCHAR (50)    NULL,
    [LegNo]                 SMALLINT        NOT NULL,
    [Action]                VARCHAR (50)    NULL,
    [Description]           VARCHAR (200)   NOT NULL,
    [PickupTypeKey]         SMALLINT        NULL,
    [CreateUserkey]         INT             NULL,
    [UpdateUserKey]         INT             NULL,
    [CreateDate]            DATETIME        NULL,
    [UpdateDate]            DATETIME        NULL,
    [FromLocation]          VARCHAR (50)    NULL,
    [ToLocation]            VARCHAR (50)    NULL,
    [DriverMessageTemplate] NVARCHAR (2000) NULL,
    [LegCostType]           VARCHAR (3)     NULL,
    [AccessorialCostItem]   VARCHAR (50)    NULL,
    [StatusKey]             INT             CONSTRAINT [DF_Leg_StatusKey] DEFAULT ((1)) NULL,
    [Remarks]               VARCHAR (100)   NULL,
    [LegType]               VARCHAR (50)    NULL,
    [PreviousLegId]         VARCHAR (200)   NULL,
    CONSTRAINT [PK_Leg] PRIMARY KEY CLUSTERED ([LegKey] ASC) WITH (FILLFACTOR = 90)
);

