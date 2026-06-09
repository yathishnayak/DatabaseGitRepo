CREATE TABLE [dbo].[Scheduler_GnosisContainerStatus] (
    [StatusKey]  INT            IDENTITY (1, 1) NOT NULL,
    [StatusName] NVARCHAR (100) NULL,
    [IsActive]   BIT            NULL,
    [IsDelete]   BIT            NULL,
    PRIMARY KEY CLUSTERED ([StatusKey] ASC)
);

