CREATE TABLE [dbo].[TMS_Integration_Header] (
    [SiteID]          VARCHAR (50) NOT NULL,
    [DataKey]         INT          NOT NULL,
    [WorkOrdernumber] VARCHAR (50) NULL,
    [WorKOrderDate]   DATETIME     NULL,
    [TMS_OrderKey]    INT          NULL,
    [DataType]        VARCHAR (10) NULL,
    CONSTRAINT [PK_TMS_Integration_Header] PRIMARY KEY CLUSTERED ([SiteID] ASC, [DataKey] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Header_SiteID_TMS_OrderKey]
    ON [dbo].[TMS_Integration_Header]([SiteID] ASC, [TMS_OrderKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Header_DataKey]
    ON [dbo].[TMS_Integration_Header]([DataKey] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_TMS_Integration_Header_TMS_OrderKey]
    ON [dbo].[TMS_Integration_Header]([TMS_OrderKey] ASC) WITH (FILLFACTOR = 90);

