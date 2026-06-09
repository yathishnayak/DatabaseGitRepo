CREATE TABLE [dbo].[SELL_NAC_Accessorial_FinalDataOutput] (
    [OutputDataKey]     BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [FileProcessKey]    INT             NULL,
    [RecordSL]          INT             NULL,
    [CustID]            VARCHAR (50)    NULL,
    [CustName]          VARCHAR (200)   NULL,
    [RateType]          VARCHAR (10)    NULL,
    [Segment]           VARCHAR (10)    NULL,
    [MarketLocation]    VARCHAR (50)    NULL,
    [Terminal]          VARCHAR (50)    NULL,
    [LineItem]          VARCHAR (100)   NULL,
    [City]              VARCHAR (100)   NULL,
    [State]             VARCHAR (20)    NULL,
    [Zip]               VARCHAR (20)    NULL,
    [LocationName]      VARCHAR (100)   NULL,
    [IsLocationExists]  VARCHAR (10)    NULL,
    [Rate]              NUMERIC (18, 2) NULL,
    [BvsNB]             VARCHAR (5)     NULL,
    [FreeTime]          INT             NULL,
    [MinCnt]            INT             NULL,
    [MaxCnt]            INT             NULL,
    [ContainerSize]     VARCHAR (50)    NULL,
    [EffectiveDate]     VARCHAR (50)    NULL,
    [EffectiveDateFrom] VARCHAR (50)    NULL,
    [MarketKey]         INT             NULL,
    [TerminalKey]       INT             NULL,
    [SegmentKey]        INT             NULL,
    [CustKey]           INT             NULL,
    [ContainerSizeKey]  INT             NULL,
    [ItemKey]           INT             NULL,
    [MasterLineItem]    VARCHAR (100)   NULL,
    [ExpiryDate]        NVARCHAR (50)   NULL,
    [OrderType]         NVARCHAR (100)  NULL,
    [Consignee]         NVARCHAR (100)  NULL,
    [TruckType]         NVARCHAR (100)  NULL,
    [IsArchived]        BIT             NULL,
    [Old_EffectiveDate] DATETIME        NULL,
    [ExpiryMonths]      INT             NULL,
    CONSTRAINT [PK_SELL_NAC_Accessorial_FinalDataOutput] PRIMARY KEY CLUSTERED ([OutputDataKey] ASC) WITH (FILLFACTOR = 90)
);


GO
CREATE NONCLUSTERED INDEX [IX_SELL_NAC_Accessorial_FinalDataOutput_MarketKey_CustKey_City_State_LocationName]
    ON [dbo].[SELL_NAC_Accessorial_FinalDataOutput]([MarketKey] ASC, [CustKey] ASC, [City] ASC, [State] ASC, [LocationName] ASC)
    INCLUDE([FileProcessKey], [RecordSL], [CustName], [Segment], [MarketLocation], [Terminal], [LineItem], [Zip], [IsLocationExists], [Rate], [BvsNB], [FreeTime], [MinCnt], [MaxCnt], [ContainerSize], [EffectiveDate], [EffectiveDateFrom], [TerminalKey], [SegmentKey], [ContainerSizeKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_SELL_NAC_Accessorial_FinalDataOutput_LineItem_MarketKey_City_State_LocationName_CustKey]
    ON [dbo].[SELL_NAC_Accessorial_FinalDataOutput]([LineItem] ASC, [MarketKey] ASC, [City] ASC, [State] ASC, [LocationName] ASC, [CustKey] ASC)
    INCLUDE([FileProcessKey], [RecordSL], [CustName], [Segment], [MarketLocation], [Terminal], [Zip], [IsLocationExists], [Rate], [BvsNB], [FreeTime], [MinCnt], [MaxCnt], [ContainerSize], [EffectiveDate], [EffectiveDateFrom], [TerminalKey], [SegmentKey], [ContainerSizeKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IDX_5441_5440_SELL_NAC_Accessorial_FinalDataOu]
    ON [dbo].[SELL_NAC_Accessorial_FinalDataOutput]([FileProcessKey] ASC, [MarketKey] ASC, [CustKey] ASC, [City] ASC, [State] ASC, [LocationName] ASC)
    INCLUDE([RecordSL], [CustName], [Segment], [MarketLocation], [Terminal], [LineItem], [Zip], [IsLocationExists], [Rate], [BvsNB], [FreeTime], [MinCnt], [MaxCnt], [ContainerSize], [EffectiveDate], [EffectiveDateFrom], [TerminalKey], [SegmentKey], [ContainerSizeKey]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_SELL_NAC_Accessorial_FinalDataOutput_MarketKey_MasterLineItem_CustName_City_State_LocationName]
    ON [dbo].[SELL_NAC_Accessorial_FinalDataOutput]([MarketKey] ASC, [MasterLineItem] ASC, [CustName] ASC, [City] ASC, [State] ASC, [LocationName] ASC)
    INCLUDE([FileProcessKey], [RecordSL], [Segment], [MarketLocation], [Terminal], [LineItem], [Zip], [IsLocationExists], [Rate], [BvsNB], [FreeTime], [MinCnt], [MaxCnt], [ContainerSize], [EffectiveDate], [EffectiveDateFrom], [TerminalKey], [SegmentKey], [CustKey], [ContainerSizeKey]);

