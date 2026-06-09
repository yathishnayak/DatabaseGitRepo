CREATE TABLE [dbo].[Container_HazardClasses] (
    [ClassKey]    INT           IDENTITY (1, 1) NOT NULL,
    [Description] NVARCHAR (50) NULL,
    [IsActive]    BIT           NULL,
    [IsDeleted]   BIT           NULL,
    [OrderBy]     INT           NULL,
    PRIMARY KEY CLUSTERED ([ClassKey] ASC)
);

