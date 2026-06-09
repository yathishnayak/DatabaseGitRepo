CREATE TABLE [dbo].[TrackingData_Delete] (
    [OrderNo]        VARCHAR (20)  NOT NULL,
    [CustName]       VARCHAR (100) NOT NULL,
    [MBL]            VARCHAR (50)  NULL,
    [ContainerNo]    VARCHAR (50)  NULL,
    [OrderDetailKey] INT           NULL,
    [TrackingStatus] VARCHAR (20)  NULL,
    [CreatedDate]    DATETIME      NULL,
    [Remarks]        VARCHAR (20)  NOT NULL
);

