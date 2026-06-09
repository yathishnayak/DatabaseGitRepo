CREATE TABLE [dbo].[EDRAY_Header] (
    [DataKey]                 INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileProcessKey]          INT           NOT NULL,
    [originatorCode]          VARCHAR (100) NULL,
    [receiverCode]            VARCHAR (100) NULL,
    [workOrderNumber]         VARCHAR (100) NULL,
    [category]                VARCHAR (100) NULL,
    [createdBy]               VARCHAR (50)  NULL,
    [workOrderDate]           VARCHAR (100) NULL,
    [houseAirWayBillNumber]   VARCHAR (100) NULL,
    [shipmentReferenceNumber] VARCHAR (100) NULL,
    [billOfLadingNumber]      VARCHAR (100) NULL,
    [vessel]                  VARCHAR (100) NULL,
    [voyage]                  VARCHAR (100) NULL,
    [portOfLoading]           VARCHAR (100) NULL,
    [portOfDischarge]         VARCHAR (100) NULL,
    [eta]                     VARCHAR (100) NULL,
    [shipper]                 VARCHAR (100) NULL,
    [broker]                  VARCHAR (100) NULL,
    [carrierCode]             VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([DataKey] ASC)
);

