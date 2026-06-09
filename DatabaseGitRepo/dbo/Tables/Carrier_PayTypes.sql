CREATE TABLE [dbo].[Carrier_PayTypes] (
    [PayTypeKey]  SMALLINT     IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PayTypeName] VARCHAR (50) NULL,
    [createDate]  DATETIME     DEFAULT (getdate()) NULL,
    [IsActive]    BIT          DEFAULT ((1)) NULL,
    PRIMARY KEY CLUSTERED ([PayTypeKey] ASC)
);

