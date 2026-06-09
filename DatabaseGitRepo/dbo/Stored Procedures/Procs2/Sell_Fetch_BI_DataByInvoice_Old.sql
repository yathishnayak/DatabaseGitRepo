
/* --19907, 25335 -- Acc Rate : SMB- 47507, ENT- 47502 -- 95737
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '99593',   @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(500) = '' ,
		@IsSpotOn bit = 0, @CustomerSegment varchar(5) = 'NAC', @Debug bit = 1
	EXEC [Sell_Fetch_BI_DataByInvoice] @InvoiceKey, @InvoiceNo, @IsSpotOn, @CustomerSegment, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @Debug
	SELECT @JsonOutput, @Status, @Reason
*/
Create PROC [dbo].[Sell_Fetch_BI_DataByInvoice_Old]
(
	@InvoiceKey			int	= 0,
	@InvoiceNo			varchar(50) = '',
	@IsSpotOn			bit  = 0, -- If 0 Then NAC else SPOT - when Spot, check from Customer Table to Get SMB / ENT Type. Else Provide the SMB/ENT Swtich
	@CustomerSegment	varchar(5) = '', -- Consider only when the IsSpotOn = 1
	@JsonOutput			nvarchar(max) ='' OUTPUT,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' output,
	@Debug				bit = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
	SET ARITHABORT ON
	SET Concat_null_Yields_null ON
	
/*

SELECT top 5 'SELL_InvoiceSummary', * FROM SELL_InvoiceSummary
SELECT top 5 'SELL_InvoiceItemSummary', * FROM SELL_InvoiceItemSummary 
SELECT top 5 'SELL_InvoiceDraybaseSummary', * FROM SELL_InvoiceDraybaseSummary
SELECT top 5 'SELL_InvoiceBobtailSummary', * FROM SELL_InvoiceBobtailSummary
SELECT top 5 'SELL_InvoiceProcessStatus', * FROM SELL_InvoiceProcessStatus

*/

Declare		@CustKey		int
Declare		@ConfigReason	varchar(100)

Set @Customersegment = ''
Set @CustKey = (select CustKey from invoiceheader where invoiceno = @invoiceno)

Select  @CustomerSegment = ISNULL(Cs.CustomerSegment, 'NAC'),
		@IsSpotOn = Case when isnull(CRT.RateType,'NAC') = 'NAC' then 0 else 1 end
		from Customer C
		inner join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
		LEft join CustomerRateType CRT on C.RateTypeKey = CRT.RateTypeKey
		where CustKey = @CustKey

--*****--TEMPTABLES CREATION--****************************************************************************--

Create table #InvoiceSummary (
	InvoiceSummaryKey	int,
	InvoiceKey			int,
	Market			varchar(50)	 ,
	MarketKey		int			 ,
	Terminal		varchar(50)	 ,
	TerminalKey		int			 ,
	ZoneKey			int			 ,
	ZoneName		varchar(50)	 ,
	city			varchar(50)	 ,
	[State]			varchar(20)	 ,
	CustKey			int			 ,
	CustName		varchar(100) ,
	IsDryRun		bit			 ,
	IsBobTail		bit			 ,
	Customersegment varchar(100)
)

Create table #Accessorials (
	InvoiceSummaryKey	int,
	ContainerNo			varchar(50)		,
	RecordSL			numeric(18,2)	,
	LineItem			varchar(100)	,
	MarketLocation		varchar(50)		,
	ItemKey				int				,
	Rate				numeric(18,2)	,
	BvsNB				varchar(5)		,
	FreeTime			int				,
	MinCnt				int				,  
	MaxCnt				int				,  
	CostGroup			varchar(50)		,
	EffectiveDate		varchar(50)		,
	EffectiveDateFrom	varchar(50)		,
	[FileName]			varchar(100)	,
	DateUploaded		Datetime		,
	UploadedBy			varchar(100)	,
	CustSegment			varchar(100)
)

Create table #DrayBase (
	InvoiceSummaryKey	int,
	ContainerNo			varchar(50)		,
	DrayBase_Value		numeric(18,2)	,
	Margin_Percent		numeric(18,2)	,
	Margin_Value		numeric(18,3)	,
	DrayBase_Rate		numeric(18,3)	,
	FSF_Value			numeric(18,3)	,
	FSF_Percent			numeric(18,3)	,
	Draybase_Total		numeric(18,3)	,
	Total_value			numeric(18,3)	,
	NetRevenue			numeric(18,3)	,
	CreatedDate			DateTime		,
	EffectiveDate		DateTime		,
	EffectiveDateFrom	varchar(50)		,
	[FileName]			varchar(100)	,
	DateUploaded		Datetime		,
	UploadedBy			varchar(100)	,
	OutputDataKey		int				
)

Create table #Bobtail (
	InvoiceSummaryKey	int				,
	ContainerNo			varchar(50)		,
	BobtailFormat		varchar(50)		,
	BobtailRate			numeric(18,2)	,
	BobtailCalc			numeric(18,3)	,
	EffectiveDate		DateTime		,
	EffectiveDateFrom	varchar(50)		,
	[FileName]			varchar(100)	,
	DateUploaded		Datetime		,
	UploadedBy			varchar(100)	,
	OutputDataKey		int			
)

Create table #Error (
	InvoiceKey			INT,
	DrayReason			varchar(1000)	,
	AccessorialReason	varchar(1000)	,
	ConfigReason		varchar(1000)	,
	BobtailReason		varchar(1000)	
)

select @CustomerSegment = ISNULL(Cs.CustomerSegment, 'NAC'),
		@IsSpotOn = Case when isnull(CRT.RateType,'NAC') = 'NAC' then 0 else 1 end
		from Customer C
		inner join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
		LEft join CustomerRateType CRT on C.RateTypeKey = CRT.RateTypeKey
		where CustKey = @CustKey

INSERT INTO #InvoiceSummary
SELECT		S.InvoiceSummaryKey,	
			S.InvoiceKey,		
			S.Market AS Market, 
            S.MarketKey AS MarketKey,
            S.Terminal AS Terminal, 
            S.TerminalKey AS TerminalKey,
            S.ZoneKey AS ZoneKey, 
            S.ZoneName AS ZoneName,
            S.City AS City, 
            S.[State] AS State,
            S.CustKey AS CustKey, 
            S.CustName AS CustName,
            IsDryRun = COALESCE(CONVERT(BIT, s.IsDryRun), 0),
            IsBobTail = COALESCE(CONVERT(BIT, s.IsBobTail), 0),
            @Customersegment as CustomerSegment
FROM SELL_InvoiceSummary S

insert into #Accessorials
SELECT		 A.InvoiceSummaryKey,
			 A.ContainerNo, 
             A.RecordSL, 
             A.LineItem, 
             A.MarketLocation, 
             A.ItemKey, 
             A.Rate, 
             A.BvsNB, 
             B.FreeTime,
             B.MinCnt,  
             B.MaxCnt,  
             A.EffectiveDate, 
             A.EffectiveDateFrom, 
             A.CostGroup,  
             A.[FileName], 
             A.DateUploaded, 
             A.UploadedBy,
             @Customersegment AS CustSegment 
FROM (select top 10 * from SELL_InvoiceItemSummary) A
--FROM SELL_InvoiceItemSummary A
inner join item I on I.itemkey = A.itemkey
inner join item M on I.masteritemkey = M.itemkey
inner join SELL_NAC_Accessorial_FinalDataOutput B on M.Description = B.MasterLineItem

Insert into #DrayBase 
SELECT      D.InvoiceSummaryKey, 
			D.ContainerNo,  
            D.DrayBase_Value,  
            D.Margin_Percent,  
            D.Margin_Value,  
            D.DrayBase_Rate, 
            D.FSF_Value, 
            D.FSF_Percent,  
            D.Draybase_Total,  
            D.Total_value,
            D.NetRevenue, 
            D.CreatedDate, 
            D.EffectiveDate,  
            D.EffectiveDateFrom, 
   			D.[FileName], 
   			D.DateUploaded, 
			D.UploadedBy, 
			D.OutputDataKey            
FROM SELL_InvoiceDraybaseSummary D

insert into #Bobtail 
SELECT       B.InvoiceSummaryKey,
			 B.ContainerNo, 
             B.BobtailFormat, 
             B.BobtailRate, 
             B.BobtailCalc, 
             B.EffectiveDate, 
             B.EffectiveDateFrom, 
             B.[FileName], 
             B.DateUploaded, 
             B.UploadedBy, 
             B.OutputDataKey
FROM SELL_InvoiceBobtailSummary B

Insert into #Error
SELECT       P.InvoiceKey,
			 P.DrayReason AS DrayReason, 
             P.AccessorialReason AS AccessorialReason, 
             @ConfigReason AS ConfigReason,
             P.BobtailReason AS BobtailReason
FROM SELL_InvoiceProcessStatus P
/**/
--*********************************************************************************************************************--

SELECT @JsonOutput = (
        SELECT 
            -- Top-level keys with explicit assignment
            S.Market AS Market, 
            S.MarketKey AS MarketKey,
            S.Terminal AS Terminal, 
            S.TerminalKey AS TerminalKey,
            S.ZoneKey AS ZoneKey, 
            S.ZoneName AS ZoneName,
            S.City AS City, 
            S.[State] AS State,
            S.CustKey AS CustKey, 
            S.CustName AS CustName,
            IsDryRun = COALESCE(CONVERT(BIT, s.IsDryRun), 0),
            IsBobTail = COALESCE(CONVERT(BIT, s.IsBobTail), 0),
            @CustomerSegment AS CustomerSegment, -- No column found in the provided tables
            
            -- Accessorials (SELL_InvoiceItemSummary)
            Accessorials = (
                SELECT 
                    A.ContainerNo, 
                    A.RecordSL, 
                    A.LineItem, 
                    A.MarketLocation, 
                    A.ItemKey, 
                    A.Rate, 
                    A.BvsNB, 
                    A.FreeTime, 
                    A.MinCnt,   
                    A.MaxCnt,   
                    A.EffectiveDate, 
                    A.EffectiveDateFrom, 
                    A.CostGroup,  
                    A.[FileName], 
                    A.DateUploaded, 
                    A.UploadedBy,
                    A.CustSegment 
                FROM #Accessorials A
                WHERE A.InvoiceSummaryKey = S.InvoiceSummaryKey
                FOR JSON PATH
            ),

            -- DrayBase (SELL_InvoiceDraybaseSummary)
            DrayBase = (
                SELECT 
                    D.ContainerNo, 
                    D.DrayBase_Value, 
                    D.Margin_Percent, 
                    D.Margin_Value, 
                    D.DrayBase_Rate, 
                    D.FSF_Percent, 
                    D.FSF_Value, 
                    D.Draybase_Total, 
                    D.NetRevenue,
                    D.EffectiveDate, 
                    D.EffectiveDateFrom, 
                    D.[FileName], 
                    D.DateUploaded, 
                    D.UploadedBy, 
                    D.OutputDataKey
                FROM SELL_InvoiceDraybaseSummary D
                WHERE D.InvoiceSummaryKey = S.InvoiceSummaryKey
                FOR JSON PATH
            ),

            -- Bobtail (SELL_InvoiceBobtailSummary)
            Bobtail = (
                SELECT 
                    B.ContainerNo, 
                    B.BobtailFormat, 
                    B.BobtailRate, 
                    B.BobtailCalc, 
                    B.EffectiveDate, 
                    B.EffectiveDateFrom, 
                    B.[FileName], 
                    B.DateUploaded, 
                    B.UploadedBy, 
                    B.OutputDataKey
                FROM SELL_InvoiceBobtailSummary B
                WHERE B.InvoiceSummaryKey = S.InvoiceSummaryKey
                FOR JSON PATH
            ),

            -- Error section (SELL_InvoiceProcessStatus)
            Error = (
                SELECT 
                    E.DrayReason AS DrayReason, 
                    E.AccessorialReason AS AccessorialReason, 
                    @ConfigReason AS ConfigReason,
                    E.BobtailReason AS BobtailReason
                FROM SELL_InvoiceProcessStatus E
                WHERE E.InvoiceKey = S.InvoiceKey
                FOR JSON PATH
            )
        FROM SELL_InvoiceSummary S
        FOR JSON PATH
    );

    SELECT @JsonOutput AS JsonResult;
	
	drop table #InvoiceSummary
	drop table #Accessorials
	drop table #Bobtail
	drop table #DrayBase
	drop table #Error

END
