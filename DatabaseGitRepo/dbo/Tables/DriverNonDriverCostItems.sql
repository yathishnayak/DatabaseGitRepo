CREATE TABLE [dbo].[DriverNonDriverCostItems] (
    [DriverNonDriverCostKey]  INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DriverNonDriverCostId]   VARCHAR (100)  NOT NULL,
    [DriverNonDriverCostDesc] NVARCHAR (300) NOT NULL,
    [IsActive]                BIT            NULL,
    [IsDeleted]               BIT            NULL,
    [CreateDate]              DATETIME       NULL,
    [CreatedBy]               INT            NULL,
    [UpdateDate]              DATETIME       NULL,
    [UpdatedBy]               INT            NULL,
    CONSTRAINT [PK_DriverNonDriverCostItems] PRIMARY KEY CLUSTERED ([DriverNonDriverCostKey] ASC)
);

