/*
truncate table SELL_NAC_Accessorial_FileContent
TRUNCATE TABLE SELL_NAC_Accessorial_FileUploadData
declare @FileProcessKey	int = 1,@JsonData nvarchar(max) = '', @status bit = 0 ,@Reason varchar(100)='' 
Set @JsonData = '[{"FileName":null,"UserKey":0,"FileProcessKey":519,"SlNo":0,"CustomerName":"Maple Lane Logistics (USA) (JCT)","RateType":"NAC","MarketLocation":"Chicago","LineItemName":"Hazmat Surcharge","Rate":"150","Terminal":null,"DrayageBase":null,"FSF":null,"City":"Alsip","State":"IL","Zip":"0","LocationName":"","LocationNameinTheSystem":"","EffectiveDate":"29-08-2025","EffectiveDateFrom":"Invoice Date","BvNB":"B","Freetime":"0","Min":"0","Max":"0","ContainerSize":"","Consignee":"","TruckType":"","OrderType":"","ExpiryDate":""}]'
Exec SELL_NAC_Accessorial_InsertFileProcessData @FileProcessKey, @JsonData, @status output, @Reason output
Select @status, @Reason
*/
CREATE PRoc [dbo].[SELL_NAC_Accessorial_InsertFileProcessData]
(
	@FileProcessKey		int = 0,
	@JsonData			nvarchar(max) = '',
	@status				bit = 0 output,
	@Reason				varchar(100)='' output
) 
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@FileProcessKey ,0) = 0)
	BEGIN
		SET @status = 0
		SET @Reason = 'No File PRocess Key'
		return;
	END
	IF(ISNULL(@JsonData,'') = '')
	BEGIN
		SET @status = 0
		SET @Reason = 'File Content not found'
		return;
	END

	insert into SELL_NAC_Accessorial_FileContent (FileProcessKey, JsonContent, DateUploaded )
	select @FileProcessKey, @JsonData, Getdate()

	SET @JsonData = REPLACE(@JsonData,'"Customer ID"','"CustID"')
	SET @JsonData = REPLACE(@JsonData,'"Cust ID"','"CustID"')
	SET @JsonData = REPLACE(@JsonData,'"Customer Name"','"CustName"')
	SET @JsonData = REPLACE(@JsonData,'"Cust Name"','"CustName"')
	SET @JsonData = REPLACE(@JsonData,'"Rate Type"','"RateType"')
	SET @JsonData = REPLACE(@JsonData,'"Market Location"','"Market"')
	SET @JsonData = REPLACE(@JsonData,'"MarketLocation"','"Market"')
	SET @JsonData = REPLACE(@JsonData,'" Rate "','"Rate"')
	SET @JsonData = REPLACE(@JsonData,'" Line Item Name "','"LineItem"')
	SET @JsonData = REPLACE(@JsonData,'" Line Item "','"LineItem"')
	SET @JsonData = REPLACE(@JsonData,'"Line Item"','"LineItem"')
	SET @JsonData = REPLACE(@JsonData,'"Line Item Name"','"LineItem"')
	SET @JsonData = REPLACE(@JsonData,'" City "','"City"')
	SET @JsonData = REPLACE(@JsonData,'" State "','"State"')
	SET @JsonData = REPLACE(@JsonData,'" Segment "','"Segment"')
	SET @JsonData = REPLACE(@JsonData,'" B v NB "','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'"B Vs NB"','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'" B Vs NB "','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'" B VsNB "','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'" BVs NB "','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'" BVsNB "','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'"BVsNB"','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'"B v NB"','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'"Bv NB"','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'"B vNB"','"BvNB"')
	SET @JsonData = REPLACE(@JsonData,'" Free Time "','"FreeTime"')
	SET @JsonData = REPLACE(@JsonData,'" Free time "','"FreeTime"')
	SET @JsonData = REPLACE(@JsonData,'"Free Time"','"FreeTime"')
	SET @JsonData = REPLACE(@JsonData,'"Free time"','"FreeTime"')
	SET @JsonData = REPLACE(@JsonData,'" Min "','"Min"')
	SET @JsonData = REPLACE(@JsonData,'" Max "','"Max"')
	SET @JsonData = REPLACE(@JsonData,'" Container Size "','"ContainerSize"')
	SET @JsonData = REPLACE(@JsonData,'"Container Size"','"ContainerSize"')
	SET @JsonData = REPLACE(@JsonData,'"Location Name"','"LocationName"')
	SET @JsonData = REPLACE(@JsonData,'" Location Name "','"LocationName"')
	SET @JsonData = REPLACE(@JsonData,'" Location In the System? "','"IsLocation"')
	SET @JsonData = REPLACE(@JsonData,'" Location In the System?"','"IsLocation"')
	SET @JsonData = REPLACE(@JsonData,'"Location In the System?"','"IsLocation"')
	SET @JsonData = REPLACE(@JsonData,'" Location In the System? "','"IsLocation"')
	SET @JsonData = REPLACE(@JsonData,'" Effective Date "','"EffectiveDate"')
	SET @JsonData = REPLACE(@JsonData,'"Effective Date"','"EffectiveDate"')
	SET @JsonData = REPLACE(@JsonData,'"Effective Date From"','"EffectiveFrom"')
	SET @JsonData = REPLACE(@JsonData,'" Effective Date From "','"EffectiveFrom"')

	Create table #FileData
	(
		SLNO			int identity(1,1),
		CustID			varchar(100),
		CustName		varchar(100),
		RateType		varchar(100),
		LineItem		varchar(100),
		Segment			varchar(100),
		Market			varchar(100),
		OrderType		varchar(100),
		Terminal		varchar(100),
		City			varchar(100),
		State			varchar(100),
		Zip				varchar(100),
		LocationName	varchar(100),
		IsLocation		varchar(100),
		Consignee		varchar(100),
		TruckType		varchar(100),
		Rate			varchar(100),
		BvNB			varchar(100),
		FreeTime		varchar(100),
		MinVal			varchar(100),
		MaxVal			varchar(100),
		ContainerSize	varchar(100),
		EffectiveDate	varchar(100),
		EffectiveFrom	varchar(100),
		Remarks			varchar(4000),
		ExpiryDate		varchar(100)
	)

	insert into #FileData (CustID, CustName, RateType, Segment, Market, OrderType, Terminal, LineItem, City, State, Zip, LocationName, 
		IsLocation, Consignee, TruckType, Rate, BvNB, FreeTime, MinVal, MaxVal, ContainerSize, EffectiveDate, EffectiveFrom,ExpiryDate)
	select CustID, CustName, RateType, Segment, Market, OrderType, Terminal, LineItem, City, State, Zip, LocationName, 
		IsLocation, Consignee, TruckType, Rate, BvNB, FreeTime, MinVal, MaxVal, ContainerSize, EffectiveDate, EffectiveFrom,ExpiryDate
	from Openjson(@jsondata,'$')
	WITH (
		CustID			varchar(100)	'$.CustID',
		CustName		varchar(100)	'$.CustomerName',
		RateType		varchar(100)	'$.RateType',
		Segment			varchar(100)	'$.Segment',
		Market			varchar(100)	'$.Market',
		OrderType		varchar(100)	'$.OrderType', --added column
		Terminal		varchar(100)	'$.Terminal',
		LineItem		varchar(100)	'$.LineItemName',
		City			varchar(100)	'$.City',
		State			varchar(100)	'$.State',
		Zip				varchar(100)	'$.Zip',
		LocationName	varchar(100)	'$.LocationName',
		IsLocation		varchar(100)	'$.LocationNameinTheSystem',
		Consignee		varchar(100)	'$.Consignee', --added column
		TruckType		varchar(100)	'$.TruckType', --added column
		Rate			varchar(100)	'$.Rate',
		BvNB			varchar(100)	'$.BvNB',
		FreeTime		varchar(100)	'$.FreeTime',
		MinVal			varchar(100)	'$.Min',
		MaxVal			varchar(100)	'$.Max',
		ContainerSize	varchar(100)	'$.ContainerSize',
		EffectiveDate	varchar(100)	'$.EffectiveDate',
		EffectiveFrom	varchar(100)	'$.EffectiveDateFrom',
		ExpiryDate	varchar(100)		'$.ExpiryDate'
	)

	update #FileData set
		CustID			= LTRIM(RTRIM(REPLACE(REPLACE(CustID,CHAR(10),''),CHAR(13),''))),
		CustName		= LTRIM(RTRIM(REPLACE(REPLACE(CustName,CHAR(10),''),CHAR(13),''))),
		RateType		= LTRIM(RTRIM(REPLACE(REPLACE(RateType,CHAR(10),''),CHAR(13),''))),
		Segment			= LTRIM(RTRIM(REPLACE(REPLACE(Segment,CHAR(10),''),CHAR(13),''))),
		Market			= LTRIM(RTRIM(REPLACE(REPLACE(Market,CHAR(10),''),CHAR(13),''))),
		OrderType		= LTRIM(RTRIM(REPLACE(REPLACE(OrderType,CHAR(10),''),CHAR(13),''))),
		Terminal		= LTRIM(RTRIM(REPLACE(REPLACE(Terminal,CHAR(10),''),CHAR(13),''))),
		LineItem		= LTRIM(RTRIM(REPLACE(REPLACE(LineItem,CHAR(10),''),CHAR(13),''))),
		City			= LTRIM(RTRIM(REPLACE(REPLACE(City,CHAR(10),''),CHAR(13),''))),
		State			= LTRIM(RTRIM(REPLACE(REPLACE(State,CHAR(10),''),CHAR(13),''))),
		Zip				= LTRIM(RTRIM(REPLACE(REPLACE(Zip,CHAR(10),''),CHAR(13),''))),
		LocationName	= LTRIM(RTRIM(REPLACE(REPLACE(LocationName,CHAR(10),''),CHAR(13),''))),
		IsLocation		= LTRIM(RTRIM(REPLACE(REPLACE(IsLocation,CHAR(10),''),CHAR(13),''))),
		Consignee		= LTRIM(RTRIM(REPLACE(REPLACE(Consignee,CHAR(10),''),CHAR(13),''))),
		TruckType		= LTRIM(RTRIM(REPLACE(REPLACE(TruckType,CHAR(10),''),CHAR(13),''))),
		Rate			= LTRIM(RTRIM(REPLACE(REPLACE(Rate,CHAR(10),''),CHAR(13),''))),
		BvNB			= LTRIM(RTRIM(REPLACE(REPLACE(BvNB,CHAR(10),''),CHAR(13),''))),
		FreeTime		= LTRIM(RTRIM(REPLACE(REPLACE(FreeTime,CHAR(10),''),CHAR(13),''))),
		MinVal			= LTRIM(RTRIM(REPLACE(REPLACE(MinVal,CHAR(10),''),CHAR(13),''))),
		MaxVal			= LTRIM(RTRIM(REPLACE(REPLACE(MaxVal,CHAR(10),''),CHAR(13),''))),
		ContainerSize	= LTRIM(RTRIM(REPLACE(REPLACE(ContainerSize,CHAR(10),''),CHAR(13),''))),
		--EffectiveDate	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveDate,CHAR(10),''),CHAR(13),''))),
		--EffectiveFrom	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveFrom,CHAR(10),''),CHAR(13),''))),
		ExpiryDate	= LTRIM(RTRIM(REPLACE(REPLACE(ExpiryDate,CHAR(10),''),CHAR(13),'')))

--- Date Validation Logic Begin (Sumanth Added this)
			--UPDATE #FileData
			--SET EffectiveDate = CASE 
			--WHEN ISNUMERIC(EffectiveDate) = 1 THEN FORMAT(DATEADD(DAY, CAST(EffectiveDate AS INT), '1899-12-30'), 'yyyy-MM-ddTHH:mm:ss')
			--WHEN TRY_CAST(EffectiveDate AS DATETIME) IS NOT NULL THEN FORMAT(CAST(EffectiveDate AS DATETIME), 'yyyy-MM-ddTHH:mm:ss')
			--ELSE NULL
			--END
--- Date Validation Logic End
	

	update A Set Remarks = isnull(remarks,'')  + 'Customer ID/Name not found in TMS'+ ';'
	from #FileData A
	left join Customer C on a.CustID = C.CustID OR a.CustName = LTRIM(RTRIM(C.CustName))
	where C.CustID is null and isnull(A.CustID,'') <> ''

	update A Set Remarks = isnull(remarks,'')  + 'Both Customer ID & Name Can''t be blank'+ ';'
	from #FileData A
	where isnull(A.CustID,'') = '' and isnull(A.CustName,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'Rate Type Should be NAC'+ ';'
	from #FileData A
	where isnull(A.RateType,'') <> 'NAC'

	update A Set Remarks = isnull(remarks,'') + 'Market Location not found in TMS' + ';'
	from #FileData A
	Left join MarketLocation M on A.Market = LTRIM(RTRIM(M.MarketLocation))
	where M.MarketLocationKey is null

	update A Set Remarks = isnull(remarks,'')  + 'Market Location can''t be blank'+ ';'
	from #FileData A
	where isnull(Market,'') = ''

	update A Set Remarks = isnull(A.remarks,'') + 'Line Item not found in TMS' + ';'
	from #FileData A
	Left join Item M on A.LineItem = LTRIM(RTRIM(M.Description))
	where M.ItemKey is null

	update A Set Remarks = isnull(remarks,'')  + 'Line Item can''t be blank'+ ';'
	from #FileData A
	where isnull(LineItem,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'Terminal not found in TMS'+ ';'
	from #FileData A
	Left join PriceGrouping M on A.Terminal = LTRIM(RTRIM(M.PriceGrouping))
	where isnull(A.Terminal,'') <> '' and  M.PriceGroupingKey is null

	update A Set Remarks = isnull(remarks,'') + 'Rate should be a numeric value'+ ';' 
	from #FileData A
	where isnumeric(Rate) = 0

	update A Set Remarks = isnull(remarks,'')  + 'Rate can''t be Zero'+ ';'
	from #FileData A
	where convert(numeric(18,2),isnull(Rate,0)) = 0
	
	update A Set Remarks = isnull(remarks,'') + 'B vs NB shouldn''t  be blank' + ';'
	from #FileData A
	where isnull(BvNB,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'B vs NB shoulbe B or NB'+ ';'
	from #FileData A
	where BvNB not in ('B','NB')

	update A Set Remarks = isnull(remarks,'') + 'Free Time should be a numeric value' + ';'
	from #FileData A
	where isnull(FreeTime,'') <> '' and  isnumeric(FreeTime) = 0

	update A Set Remarks = isnull(remarks,'') + 'Min should be a numeric value' + ';'
	from #FileData A
	where isnull(MinVal,'') <> '' and  isnumeric(MinVal) = 0

	update A Set Remarks = isnull(remarks,'') + 'Max should be a numeric value' + ';'
	from #FileData A
	where isnull(MaxVal,'') <> '' and  isnumeric(MaxVal) = 0

	update A Set Remarks = isnull(remarks,'')  + 'Container Size not found in TMS'+ ';'
	from #FileData A
	Left join ContainerSize M on A.ContainerSize = LTRIM(RTRIM(M.ContainerSizeKey))
	where isnull(A.ContainerSize,'') <> ''
	
	update A Set Remarks = isnull(remarks,'')  + 'City/State not found in TMS'+ ';'
	from #FileData A
	Left join LocationData M on A.City = LTRIM(RTRIM(M.City)) and A.State = LTRIM(RTRIM(M.State))
	where (M.City is null OR M.State IS NULL) AND ISNULL(A.City,'') <>'' AND ISNULL(A.State,'')<>''

	update A Set Remarks = isnull(remarks,'')  + 'Effective Date should not be blank'+ ';'
	from #FileData A
	where isnull(EffectiveDate,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'Effective From should not be 1/1/1 OR Blank'+ ';'
	from #FileData A
	where isnull(EffectiveDate,'') = '0001-01-01T00:00:00'

	update A Set Remarks = isnull(remarks,'')  + 'Effective From should not be blank'+ ';'
	from #FileData A
	where isnull(EffectiveFrom,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'Effective From not having proper data'+ ';'
	from #FileData A
	LEft join Cost_EffectiveFrom EF on a.EffectiveFrom = EF.EffectiveFrom
	where EF.EffectiveFrom  is null

	update A Set Remarks = isnull(remarks,'')  + 'Location Name with City/State combination not found in TMS'+ ';'
	from #FileData A
	Left join Address M on A.City = M.City and A.State = LTRIM(RTRIM(M.State))
	--LEft join LocationData LD on M.City = LTRIM(RTRIM(LD.city)) and M.State = LTRIM(RTRIM(LD.State))
	where isnull(A.LocationName,'') <> '' and ( ISNULL(M.City,'')='' OR ISNULL(M.State,'')='')

	--select * from #FileData

	insert into SELL_NAC_Accessorial_FileUploadData (FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, 
			MarketLocation, OrderType, Terminal, City, State, Zip, LocationName, IsLocationExists, Consignee, TruckType, Rate, BvsNB, LineItem, FreeTime,
			MinCnt, MaxCnt, ContainerSize, EffectiveDate, EffectiveDateFrom, Remarks,ExpiryDate)
	select @FileProcessKey, SLNO, CustID, CustName, RateType, Segment, 
			Market, OrderType, Terminal, City, State, Zip, LocationName, IsLocation, Consignee, TruckType, Rate, BvNB, LineItem, FreeTime,
			MinVal, MaxVal, ContainerSize, EffectiveDate, EffectiveFrom, Remarks,ExpiryDate
	From #FileData

	declare @ErrorCount int = 0
	select @ErrorCount = count(1) from #FileData where isnull(Remarks,'') <> ''
	set @status = case when @ErrorCount > 0 then 0 else 1 end
	Set @Reason = Case when @ErrorCount > 0 then 'Error in Data process. Refer Remarks column' else 'Saved Successfully' end

	update SELL_NAC_Accessorial_FileProcessInfo set 
		FileUploadStatus = 1,
		FileProcessStatus = @status,
		IsEmailSent = 0, 
		IsFileDownloaded = 0,
		FileLink = Case when @ErrorCount > 0 then 'Error in file Creation' else '' end
	where FileProcessKey = @FileProcessKey

	--select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, LineItem, City, State, Zip, 
	--		LocationName, IsLocationExists, Rate, BvsNB, FreeTime, MinCnt, MaxCnt, ContainerSize, EffectiveDate, EffectiveDateFrom, Remarks
	--from SELL_NAC_Accessorial_FileUploadData A
	--where FileProcessKey = @FileProcessKey
	--ORDER BY RecordSL for json path, without_array_wrapper

	IF(isnull(@status,0) = 1)
	BEGIN
		Exec SELL_NAC_Accessorial_MoveFinalDataOutput @FileProcessKey, @status OUTPUT, @Reason OUTPUT
	END
END
