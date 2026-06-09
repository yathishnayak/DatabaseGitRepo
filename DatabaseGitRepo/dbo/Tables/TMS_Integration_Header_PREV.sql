CREATE TABLE [dbo].[TMS_Integration_Header_PREV] (
    [SiteID]          VARCHAR (50) NOT NULL,
    [DataKey]         INT          NOT NULL,
    [WorkOrdernumber] VARCHAR (50) NULL,
    [WorKOrderDate]   DATETIME     NULL,
    [TMS_OrderKey]    INT          NULL,
    [DataType]        VARCHAR (10) NULL
);

