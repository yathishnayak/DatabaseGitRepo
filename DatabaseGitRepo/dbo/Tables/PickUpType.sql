CREATE TABLE [dbo].[PickUpType] (
    [PickupTypeKey] INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [PickUpType]    VARCHAR (50) NULL,
    [IsActive]      BIT          CONSTRAINT [DF_PickUpType_IsActive] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_PickUpType] PRIMARY KEY CLUSTERED ([PickupTypeKey] ASC)
);

