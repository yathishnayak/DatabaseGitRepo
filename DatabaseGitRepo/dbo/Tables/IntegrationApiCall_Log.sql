CREATE TABLE [dbo].[IntegrationApiCall_Log] (
    [LogKey]             INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustKey]            INT           NULL,
    [AddressKey]         INT           NULL,
    [RequestString]      VARCHAR (MAX) NULL,
    [RepsonseString]     VARCHAR (MAX) NULL,
    [ExceptionString]    VARCHAR (MAX) NULL,
    [RequestSentAt]      DATETIME      NULL,
    [ResponseReceivedAt] DATETIME      NULL,
    [ExceptionOccuredAt] DATETIME      NULL,
    [SiteID]             VARCHAR (20)  NULL,
    [IsAddrUpdate]       BIT           NULL,
    [IsCustomer]         BIT           NULL,
    [UserKey]            INT           NULL,
    PRIMARY KEY CLUSTERED ([LogKey] ASC) WITH (FILLFACTOR = 90)
);

