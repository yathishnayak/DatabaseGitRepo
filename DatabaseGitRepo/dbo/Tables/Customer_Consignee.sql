CREATE TABLE [dbo].[Customer_Consignee] (
    [ConsigneeKey]  INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ConsigneeId]   NVARCHAR (100) NULL,
    [ConsigneeName] NVARCHAR (300) NULL,
    [CustKey]       INT            NULL,
    PRIMARY KEY CLUSTERED ([ConsigneeKey] ASC)
);

