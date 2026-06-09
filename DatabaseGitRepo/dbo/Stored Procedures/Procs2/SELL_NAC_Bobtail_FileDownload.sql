
CREATE Proc [dbo].[SELL_NAC_Bobtail_FileDownload] -- SELL_NAC_Bobtail_FileDownload 1
(
	@FileProcessKey		int = 0
)
as
BEGIN
	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, 
			City, State, Zip, LocationName, IsLocationExists, BobtailFormat, BobtailRate, EffectiveDate, EffectiveDateFrom
	from SELL_NAC_Bobtail_FinalDataOutput
	where FileProcessKey = @FileProcessKey
	ORDER BY RecordSL
END
