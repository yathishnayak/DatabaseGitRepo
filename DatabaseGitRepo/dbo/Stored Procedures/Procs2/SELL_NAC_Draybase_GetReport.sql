

CREATE PROC [dbo].[SELL_NAC_Draybase_GetReport]
(
	@CustomerKey		int = 0,
	@MarketKey			int = 0,
	@Consignee			varchar(50) = '',
	@SalesPersonKey		int = 0,
	--@ItemKeyStr			varchar(100) = '', -- Comma seperated
	--@BvsNB				smallint = 0, -- 0 : all, 1: B, 2 NB
	@IsQuote			Bit	= 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	--if(len(isnull(@ItemKeyStr,'')) > 0 )
	--Begin
	--	select * into #ItemKeys from dbo.Fn_SplitParam(@ItemKeyStr)
	--End

	SELECT FileProcessKey, RecordSL, isnull(A.CustID, C.CustID) as CustID,isnull(a.CustName,C.CustName) as CustName, 
		RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
		LocationName, IsLocationExists, DraybaseCost, FSF, EffectiveDate, EffectiveDateFrom, 
		MarketKey, TerminalKey, A.CustKey, SegmentKey
	FROM SELL_NAC_Draybase_FinalDataOutput A
	--LEFT JOIN MarketLocation ML ON A.MarketKey = ML.MarketLocationKey
	--LEFT JOIN PriceGrouping T ON A.TerminalKey = T.PriceGroupingKey
	LEFT JOIN Customer C ON A.CustKey = C.CustKey
	LEFT JOIN SalesPerson SP ON C.SalesPersonKey = SP.SalesPersonKey
	--LEFT JOIN CustomerSegments CS ON A.SegmentKey = CS.CustomerSegmentKey
	Where (isnull(@CustomerKey,0) = 0 OR A.CustKey = @CustomerKey) AND
		  (isnull(@MarketKey,0) = 0 OR A.MarketKey = @MarketKey ) AND
		  --(isnull(@Consi) AND
		  (isnull(@SalesPersonKey,0) = 0 OR C.SalesPersonKey = @SalesPersonKey) 
		  

END
