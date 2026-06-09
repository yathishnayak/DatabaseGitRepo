CREATE TABLE [dbo].[ScreenTypes] (
    [ScreenTypeKey]  SMALLINT     NOT NULL,
    [ScreenTypeName] VARCHAR (50) NOT NULL,
    [IsActive]       BIT          NULL,
    [DateCreated]    DATETIME     NULL,
    [DateUpdated]    DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([ScreenTypeKey] ASC)
);

