CREATE TABLE [dbo].[StopsMaster] (
    [StopTypeKey]       SMALLINT     IDENTITY (1, 1) NOT NULL,
    [StopTypeName]      VARCHAR (50) NOT NULL,
    [StopTypeShortcode] VARCHAR (5)  NOT NULL,
    [IsFoundationStop]  BIT          CONSTRAINT [DF_Table_1_IsFoundation] DEFAULT ((0)) NULL,
    [OrderBy]           SMALLINT     NULL,
    [IsActive]          BIT          CONSTRAINT [DF_StopsMaster_IsActive] DEFAULT ((1)) NULL,
    [CreateDate]        DATETIME     CONSTRAINT [DF_StopsMaster_CreateDate] DEFAULT (getdate()) NULL,
    [CreateUserKey]     INT          NULL,
    [UpdateDate]        DATETIME     NULL,
    [UpdateUserKey]     INT          NULL,
    CONSTRAINT [PK_StopsMaster] PRIMARY KEY CLUSTERED ([StopTypeKey] ASC)
);

