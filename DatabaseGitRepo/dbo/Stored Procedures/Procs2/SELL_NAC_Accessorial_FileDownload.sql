
CREATE Proc [dbo].[SELL_NAC_Accessorial_FileDownload]
(
	@FileProcessKey		int = 0
)
as
BEGIN
	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, LineItem, 
			City, State, Zip, LocationName, IsLocationExists, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, ContainerSize, 
			EffectiveDate, EffectiveDateFrom
	from SELL_NAC_Accessorial_FinalDataOutput
	where FileProcessKey = @FileProcessKey
	ORDER BY RecordSL
END
