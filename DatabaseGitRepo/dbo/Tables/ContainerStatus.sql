CREATE TABLE [dbo].[ContainerStatus] (
    [ContainerStatusKey] INT            IDENTITY (1, 1) NOT NULL,
    [ContainerStatus]    NVARCHAR (200) NULL,
    [IsActive]           BIT            NULL,
    [IsDelete]           BIT            NULL,
    [OrderBy]            INT            NULL,
    CONSTRAINT [PK_ContainerStatus] PRIMARY KEY CLUSTERED ([ContainerStatusKey] ASC)
);

