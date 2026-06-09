CREATE TABLE [dbo].[SELL_NAC_Bobtail_FinalDataOutput] (
    [OutputDataKey]     BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileProcessKey]    INT             NULL,
    [RecordSL]          INT             NULL,
    [CustID]            VARCHAR (50)    NULL,
    [CustName]          VARCHAR (200)   NULL,
    [RateType]          VARCHAR (10)    NULL,
    [Segment]           VARCHAR (10)    NULL,
    [MarketLocation]    VARCHAR (50)    NULL,
    [Terminal]          VARCHAR (50)    NULL,
    [City]              VARCHAR (100)   NULL,
    [State]             VARCHAR (20)    NULL,
    [Zip]               VARCHAR (20)    NULL,
    [LocationName]      VARCHAR (100)   NULL,
    [IsLocationExists]  VARCHAR (10)    NULL,
    [BobtailFormat]     VARCHAR (50)    NULL,
    [BobtailRate]       NUMERIC (18, 2) NULL,
    [EffectiveDate]     VARCHAR (50)    NULL,
    [EffectiveDateFrom] VARCHAR (50)    NULL,
    [MarketKey]         INT             NULL,
    [TerminalKey]       INT             NULL,
    [CustKey]           INT             NULL,
    [SegmentKey]        INT             NULL,
    [ExpiryDate]        NVARCHAR (50)   NULL,
    [OrderType]         NVARCHAR (100)  NULL,
    [Consignee]         NVARCHAR (100)  NULL,
    [TruckType]         NVARCHAR (100)  NULL,
    [IsArchived]        BIT             NULL,
    [Old_EffectiveDate] DATETIME        NULL,
    [ExpiryMonths]      INT             NULL,
    CONSTRAINT [PK_SELL_NAC_Bobtail_FinalDataOutput] PRIMARY KEY CLUSTERED ([OutputDataKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_SELL_NAC_Bobtail_FinalDataOutput_MarketKey_CustKey_City_State_LocationName_TerminalKey]
    ON [dbo].[SELL_NAC_Bobtail_FinalDataOutput]([MarketKey] ASC, [CustKey] ASC, [City] ASC, [State] ASC, [LocationName] ASC, [TerminalKey] ASC)
    INCLUDE([FileProcessKey], [BobtailFormat], [BobtailRate], [EffectiveDate], [EffectiveDateFrom]) WITH (FILLFACTOR = 90);

