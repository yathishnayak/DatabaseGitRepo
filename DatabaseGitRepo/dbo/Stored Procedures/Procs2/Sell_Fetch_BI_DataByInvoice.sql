
/* --19907, 25335 -- Acc Rate : SMB- 47507, ENT- 47502 -- 95737
	DECLARE @InvoiceKey int =0, @InvoiceNo Varchar(50) = '99523',   @JsonOutput nvarchar(max) ='',@Status	bit = 0 , @Reason	varchar(500) = '' ,
		@IsSpotOn bit = 0, @CustomerSegment varchar(5) = 'NAC', @Debug bit = 0
	EXEC [Sell_Fetch_BI_DataByInvoice] @InvoiceKey, @InvoiceNo, @IsSpotOn, @CustomerSegment, @JsonOutput OUTPUT, @Status OUTPUT, @Reason OUTPUT, @Debug
	SELECT @JsonOutput, @Status, @Reason
*/
CREATE PROC [dbo].[Sell_Fetch_BI_DataByInvoice]
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

Declare		@CustKey			 INT,			
			@CustName			 VARCHAR(100),
			@Marketkey			 INT, 
			@State				 VARCHAR(50), 
			@City				 VARCHAR(50),
			@Market				 VARCHAR(50),
			@Terminal			 VARCHAR(50),
			@ContainerNo		 VARCHAR(20),
			@DrayReason			 VARCHAR(500),
			@AccessorialReason	 VARCHAR(500),
			@ConfigReason 		 VARCHAR(500),
			@BobtailReason		 VARCHAR(500)

Set @Customersegment = ''
Set @CustKey = (select CustKey from invoiceheader where invoiceno = @invoiceno)

if(isnull(@InvoiceKey,0) = 0 AND ISNULL(@InvoiceNo,'') = '')
	BEGIN
		set @Status = 0
		set @Reason = 'Invoice Parameters not received'
		return
	END
	if(isnull(@InvoiceKey,0) = 0)
	Begin
		select @InvoiceKey = InvoiceKey From InvoiceHeader where InvoiceNo = @InvoiceNo
	End
	print '@InvoiceKey'
	print @InvoiceKey
	SET @Status = 1

Select  @CustomerSegment = ISNULL(Cs.CustomerSegment, 'NAC'),
		@IsSpotOn = Case when isnull(CRT.RateType,'NAC') = 'NAC' then 0 else 1 end
		from Customer C
		inner join CustomerSegments CS on C.CustomerSegmentKey = CS.CustomerSegmentKey
		LEft join CustomerRateType CRT on C.RateTypeKey = CRT.RateTypeKey
		where CustKey = @CustKey

select @CustName     = 	CustName 	  From SELL_InvoiceSummary where InvoiceKey = @InvoiceKey
Select @Marketkey    =	Marketkey 	  From SELL_InvoiceSummary where InvoiceKey = @InvoiceKey
Select @Market	     =	Market 		  From SELL_InvoiceSummary where InvoiceKey = @InvoiceKey
Select @State        = 	[State]	  	  From SELL_InvoiceSummary where InvoiceKey = @InvoiceKey
Select @City         = 	City  		  From SELL_InvoiceSummary where InvoiceKey = @InvoiceKey
Select @Terminal     =	Terminal 	  From SELL_InvoiceSummary where InvoiceKey = @InvoiceKey
Select @ContainerNo  =	(select top 1 ContainerNo
						 From SELL_InvoiceItemSummary SITS
						 inner join SELL_InvoiceSummary SIS on SITS.InvoiceSummaryKey = SIS.InvoiceSummaryKey
						 where InvoiceKey = @InvoiceKey)

--*****--TEMPTABLES CREATION and INSERTION--****************************************************************************--

	create table #Items
	(
		ItemKey				int,
		IDescription		varchar(100),
		MItemKey			int,
		MDescription		varchar(100),
		CostGroup			varchar(50)
	)

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
INTO		#InvoiceSummary
FROM		SELL_InvoiceSummary S WITH(NOLOCK)
WHERE		InvoiceKey = @InvoiceKey

Print '#InvoiceSummary' ----------------------------------------------

SELECT		 A.InvoiceSummaryKey,
			 A.ContainerNo, 
             A.RecordSL, 
             A.LineItem, 
             A.MarketLocation, 
             A.ItemKey, 
             A.Rate, 
             A.BvsNB, 
             null as FreeTime,
             null as MinCnt,  
             null as MaxCnt,  
             A.EffectiveDate, 
             A.EffectiveDateFrom, 
             A.CostGroup,  
             A.[FileName], 
             A.DateUploaded, 
             A.UploadedBy,
             @Customersegment AS CustSegment 
into       #Accessorials
--FROM (select top 10 * from SELL_InvoiceItemSummary) A
FROM	   SELL_InvoiceItemSummary A WITH(NOLOCK)
inner join #InvoiceSummary S on A.InvoiceSummaryKey = S.InvoiceSummaryKey
inner join item I on I.itemkey = A.itemkey
inner join item M on I.masteritemkey = M.itemkey

--select * from #Accessorials

print '#Accessorials' ------------------------------------------------
 
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
into		#DrayBase
FROM		SELL_InvoiceDraybaseSummary D WITH(NOLOCK)
inner join #InvoiceSummary S on D.InvoiceSummaryKey = S.InvoiceSummaryKey

Print '#DrayBase' ----------------------------------------------------
 
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
into		 #Bobtail
FROM		 SELL_InvoiceBobtailSummary B WITH(NOLOCK)
inner join #InvoiceSummary S on B.InvoiceSummaryKey = S.InvoiceSummaryKey

Print '#Bobtail' -----------------------------------------------------

if((select count(1) from #DrayBase) = 0)
begin
			set @DrayReason = 'Records not found in Sell Database for the combination of Customer Segment: ' + @CustomerSegment 
				+ ', City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
				+ ', Market:' + isnull(@Market,'')
				+ ', Terminal:' + isnull(@Terminal,'') 
end

--if((select count(1) from #Accessorials) = 0)
--			set @AccessorialReason = 'Record not found in ' + 
--				Case when @CustomerSegment = 'NAC' then ' NAC Accessorial ' else 'Accessorial Tariff' end + 
--				' for the Container: ' + @ContainerNo 
--				+ ', Cust Name: ' + @CustName
--				+ ', Market: ' + @Market 
--				+ ', City : ' + @city
--				+ ', State : ' + @State 

if((select count(1) from #Bobtail) = 0)
			set @BobtailReason = 'Records not found in Sell - Bobtail Database for the combination of Customer Segment: ' + @CustomerSegment 
			+ ', City:' + isnull(@City,'') + ', State:' + isnull(@State,'') 
			+ ', Market:' + isnull(@Market,'')
			+ ', Terminal:' + isnull(@Terminal,'')

SELECT		S.InvoiceKey,
			ISNULL(P.DrayReason, @DrayReason) AS DrayReason,
			ISNULL(P.AccessorialReason, @AccessorialReason) AS AccessorialReason,
			ISNULL(P.BobtailReason, @BobtailReason) AS BobtailReason
INTO		#Error
FROM		#InvoiceSummary S
LEFT JOIN	SELL_InvoiceProcessStatus P WITH (NOLOCK) ON P.InvoiceKey = S.InvoiceKey

Print '#Error' -------------------------------------------------------

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
                --WHERE A.InvoiceSummaryKey = S.InvoiceSummaryKey
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
                FROM #DrayBase D
                --WHERE D.InvoiceSummaryKey = S.InvoiceSummaryKey
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
                FROM #Bobtail B
                --WHERE B.InvoiceSummaryKey = S.InvoiceSummaryKey
                FOR JSON PATH
            ),

            -- Error section (SELL_InvoiceProcessStatus)
            Error = (
                SELECT 
                    E.DrayReason AS DrayReason, 
                    E.AccessorialReason AS AccessorialReason, 
                    @ConfigReason AS ConfigReason,
                    E.BobtailReason AS BobtailReason
                FROM #Error E
                --WHERE E.InvoiceKey = S.InvoiceKey
                FOR JSON PATH
            )
        FROM #InvoiceSummary S
        FOR JSON PATH
    );
	If @Status = 1
	Begin
		Set @Reason = 'SUCCESS'
	End

    --SELECT @JsonOutput AS JsonResult;
	
	drop table #InvoiceSummary
	drop table #Accessorials
	drop table #Bobtail
	drop table #DrayBase
	drop table #Error

END


--Fav One--