
CREATE Proc [dbo].[SELL_NAC_Draybase_FileDownload] -- SELL_NAC_Draybase_FileDownload 1
(
	@FileProcessKey		int = 0
)
as
BEGIN
	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, 
			City, State, Zip, LocationName, IsLocationExists, DraybaseCost, FSF, EffectiveDate, EffectiveDateFrom
	from SELL_NAC_Draybase_FinalDataOutput
	where FileProcessKey = @FileProcessKey
	ORDER BY RecordSL
END
