CREATE TABLE [dbo].[TMS_Integration_SiteLinking] (
    [SiteID]    VARCHAR (20)  NOT NULL,
    [CustKey]   INT           NULL,
    [StartDate] DATETIME      NULL,
    [EmailTo]   VARCHAR (200) NULL,
    [EmailCC]   VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([SiteID] ASC)
);

