

CREATE PROC [dbo].[SELL_NAC_Draybase_MoveFinalDataOutput]
(
	@FileProcessKey		int,
	@Status				bit = 0 output,
	@Reason				varchar(500) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	if(isnull(@FileProcessKey,0) = 0)
	Begin
		Set @Status = 0
		set @Reason = 'File Process Key not found'
		return
	END
	if((select count(1) from SELL_NAC_Draybase_FileUploadData where FileProcessKey = @FileProcessKey) = 0)
	Begin
		SEt @Status = 0
		SEt @Reason = 'Record not found in Upload Data'
		return
	end
	if((select count(1) from SELL_NAC_Draybase_FileUploadData where FileProcessKey = @FileProcessKey and isnull(Remarks,'') <> '') > 0)
	Begin
		SEt @Status = 0
		SEt @Reason = 'Upload Remarks found in Data'
		return
	end

	insert into SELL_NAC_Draybase_FinalDataOutput(FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, 
		OrderType, City, State, Zip, LocationName, IsLocationExists, Consignee, TruckType, DraybaseCost, FSF, 
		EffectiveDate, EffectiveDateFrom,ExpiryDate)
	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, 
		OrderType, City, State, Zip, LocationName, IsLocationExists, Consignee, TruckType, DraybaseCost, FSF, 
		EffectiveDate, EffectiveDateFrom,ExpiryDate
	from SELL_NAC_Draybase_FileUploadData 
	where FileProcessKey = @FileProcessKey and isnull(Remarks,'') = ''

	update A Set MarketKey = M.MarketLocationKey
	from SELL_NAC_Draybase_FinalDataOutput A
	inner join MarketLocation M on A.MarketLocation = M.MarketLocation
	where FileProcessKey = @FileProcessKey

	update A Set TerminalKey = M.PriceGroupingKey
	from SELL_NAC_Draybase_FinalDataOutput A
	inner join PriceGrouping M on A.Terminal = M.PriceGrouping
	where FileProcessKey = @FileProcessKey

	update A Set SegmentKey = M.CustomerSegmentKey
	from SELL_NAC_Draybase_FinalDataOutput A
	inner join CustomerSegments M on A.Segment = M.CustomerSegment
	where FileProcessKey = @FileProcessKey

	update A Set CustKey = M.CustKey, ExpiryMonths =  M.ExpiryMonths
	from SELL_NAC_Draybase_FinalDataOutput A
	inner join Customer M on A.CustID = M.CustID OR A.CustName = M.CustName
	where FileProcessKey = @FileProcessKey

	Update A SET EffectiveDate =DateUploaded
	from SELL_NAC_Draybase_FinalDataOutput A
	inner join SELL_NAC_Draybase_FileProcessInfo F on A.FileProcessKey = F.FileProcessKey
	where (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) END) < convert(date,'2020-01-01')

	UPDATE A SET ExpiryMonths=CASE WHEN C.IsKeyAccount=1 THEN 12 ELSE 3 END
	FROM SELL_NAC_Draybase_FinalDataOutput A
	INNER JOIN Customer C WITH (NOLOCK) ON TRIM(C.CustName)=TRIM(A.CustName)
	where FileProcessKey = @FileProcessKey

	Update A set 
		IsArchived = 0, ExpiryDate = convert(Date, DateAdd(MM,ExpiryMonths,EffectiveDate))
	from SELL_NAC_Draybase_FinalDataOutput A
	inner join SELL_NAC_Draybase_FileProcessInfo F on A.FileProcessKey = F.FileProcessKey
	where A.FileProcessKey = @FileProcessKey

	set @Status = 1
	set @Reason = 'Saved Successfully'
END
