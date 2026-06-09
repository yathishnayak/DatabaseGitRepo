CREATE TABLE [dbo].[TMS_Integration_Customers] (
    [CustKey]     INT          NULL,
    [SiteID]      VARCHAR (50) NULL,
    [CustGroupID] INT          NULL
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-CustKey]
    ON [dbo].[TMS_Integration_Customers]([CustKey] ASC);

