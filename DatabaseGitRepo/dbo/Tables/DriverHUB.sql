CREATE TABLE [dbo].[DriverHUB] (
    [DriverHubKey]  INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DriverHubName] NVARCHAR (200) NOT NULL,
    [CreatedBy]     INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [UpdatedBy]     INT            NULL,
    [UpdatedDate]   DATETIME       NULL,
    CONSTRAINT [PK_DriverHUB] PRIMARY KEY CLUSTERED ([DriverHubKey] ASC)
);

