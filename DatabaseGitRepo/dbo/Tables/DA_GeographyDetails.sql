CREATE TABLE [dbo].[DA_GeographyDetails] (
    [Reckey]      INT        IDENTITY (1, 1) NOT NULL,
    [Routekey]    INT        NULL,
    [Latitude]    FLOAT (53) NULL,
    [Longitude]   FLOAT (53) NULL,
    [CreatedDate] DATETIME   NULL,
    CONSTRAINT [PK_DA_GeographyDetails] PRIMARY KEY CLUSTERED ([Reckey] ASC)
);

