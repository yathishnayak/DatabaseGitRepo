CREATE TABLE [dbo].[WarehouseStatus] (
    [StatusKey]   INT          NOT NULL,
    [Description] VARCHAR (50) NULL,
    [isActive]    BIT          DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([StatusKey] ASC)
);

