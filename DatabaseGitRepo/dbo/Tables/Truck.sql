CREATE TABLE [dbo].[Truck] (
    [TruckKey]      INT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TruckNo]       VARCHAR (50) NOT NULL,
    [StatusKey]     SMALLINT     CONSTRAINT [DF_Truck_StatusKey] DEFAULT ((1)) NOT NULL,
    [StatusDate]    DATETIME     CONSTRAINT [DF_Truck_StatusDate] DEFAULT (getdate()) NOT NULL,
    [CreateUserKey] INT          NOT NULL,
    [CreateDate]    DATETIME     CONSTRAINT [DF_Truck_CreateDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Truck] PRIMARY KEY CLUSTERED ([TruckKey] ASC),
    CONSTRAINT [FK_Truck_Status] FOREIGN KEY ([StatusKey]) REFERENCES [dbo].[Status] ([StatusKey])
);

