

CREATE PROC [dbo].[SELL_NAC_Accessorial_MoveFinalDataOutput]
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
	if((select count(1) from SELL_NAC_Accessorial_FileUploadData where FileProcessKey = @FileProcessKey) = 0)
	Begin
		SEt @Status = 0
		SEt @Reason = 'Record not found in Upload Data'
		return
	end
	if((select count(1) from SELL_NAC_Accessorial_FileUploadData where FileProcessKey = @FileProcessKey and isnull(Remarks,'') <> '') > 0)
	Begin
		SEt @Status = 0
		SEt @Reason = 'Upload Remarks found in Data'
		return
	end

	insert into SELL_NAC_Accessorial_FinalDataOutput(FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, 
		MarketLocation, OrderType, Terminal, LineItem, City, State, Zip, LocationName, IsLocationExists, Consignee, TruckType, Rate, BvsNB, 
		FreeTime, MinCnt, MaxCnt, ContainerSize, EffectiveDate, EffectiveDateFrom,ExpiryDate)
	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, 
		MarketLocation, OrderType, Terminal, LineItem, City, State, Zip, LocationName, IsLocationExists, Consignee, TruckType, Rate, BvsNB, 
		FreeTime, MinCnt, MaxCnt, ContainerSize, EffectiveDate, EffectiveDateFrom,ExpiryDate
	from SELL_NAC_Accessorial_FileUploadData 
	where FileProcessKey = @FileProcessKey and isnull(Remarks,'') = ''

	update A Set MarketKey = M.MarketLocationKey
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join MarketLocation M on A.MarketLocation = M.MarketLocation
	where FileProcessKey = @FileProcessKey

	update A Set TerminalKey = M.PriceGroupingKey
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join PriceGrouping M on A.Terminal = M.PriceGrouping
	where FileProcessKey = @FileProcessKey

	update A Set SegmentKey = M.CustomerSegmentKey
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join CustomerSegments M on A.Segment = M.CustomerSegment
	where FileProcessKey = @FileProcessKey

	update A Set CustKey = M.CustKey, ExpiryMonths = M.ExpiryMonths
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join Customer M on A.CustID = M.CustID OR A.CustName = M.CustName
	where FileProcessKey = @FileProcessKey

	--// removed as multiple item exists with same name
	--update A Set ItemKey = M.ItemKey
	--from SELL_NAC_Accessorial_FinalDataOutput A
	--inner join Item M on A.LineItem = M.Description
	--where FileProcessKey = @FileProcessKey

	update A Set ContainerSizeKey = M.ContainerSizeKey
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join ContainerSize M on A.ContainerSize = M.Description
	where FileProcessKey = @FileProcessKey

	/* TO UPDATE THE MASTER LINE ITEM (STANDARDISE ITEM NAMES) */
	update A set MasterLineItem = I.Description
	--select *
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join Item I on A.LineItem = I.Description
	where I.itemkey = I.MasterItemKey and A.MasterLineItem is null


	update A set MasterLineItem = M.Description
	--select M.Description, *
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join Item I on A.LineItem = I.Description
	inner join Item M on I.MasterItemKey = M.itemkey
	where M.itemkey = M.MasterItemKey and A.MasterLineItem is null


	update A set MasterLineItem = M.Description
	--select M.Description, *
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join Item I on A.LineItem = I.Itemid 
	inner join Item M on I.MasterItemKey = M.itemkey
	where M.itemkey = M.MasterItemKey and A.MasterLineItem is null

	update A set EffectiveDate = F.DateUploaded
	from SELL_NAC_Accessorial_FinalDataOutput A
	inner join SELL_NAC_Accessorial_FileProcessInfo F on A.FileProcessKey = F.FileProcessKey
	where A.FileProcessKey = @FileProcessKey and (CASE 
        WHEN ISDATE(EffectiveDate) = 1 
            THEN CONVERT(varchar(10), CAST(EffectiveDate AS datetime), 101)
        WHEN TRY_CONVERT(datetime, EffectiveDate, 103) IS NOT NULL 
            THEN CONVERT(varchar(10), TRY_CONVERT(datetime, EffectiveDate, 103), 101) END)  < convert(Date, '2020-01-01')

	update SELL_NAC_Accessorial_FinalDataOutput set 
		IsArchived = 0
	where FileProcessKey = @FileProcessKey

	UPDATE A SET ExpiryMonths=CASE WHEN C.IsKeyAccount=1 THEN 12 ELSE 3 END
	FROM SELL_NAC_Accessorial_FinalDataOutput A
	INNER JOIN Customer C WITH (NOLOCK) ON TRIM(C.CustName)=TRIM(A.CustName)
	where FileProcessKey = @FileProcessKey

	update SELL_NAC_Accessorial_FinalDataOutput set 
	ExpiryDate = convert(Date, DateAdd(MM,ExpiryMonths,EffectiveDate))
	where FileProcessKey = @FileProcessKey and  isnumeric(ExpiryMonths) = 1

	set @Status = 1
	set @Reason = 'Saved Successfully'
END
