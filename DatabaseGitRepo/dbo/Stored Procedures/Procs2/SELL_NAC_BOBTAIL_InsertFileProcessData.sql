CREATE PRoc [dbo].[SELL_NAC_BOBTAIL_InsertFileProcessData]
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
		select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
				LocationName, IsLocationExists, BobtailRate, BobtailFormat, EffectiveDate, EffectiveDateFrom, Remarks
		from SELL_NAC_BOBTAIL_FileUploadData A
		where FileProcessKey = @FileProcessKey
		ORDER BY RecordSL
		SET @status = 0
		SET @Reason = 'No File Process Key'
		return;
	END
	IF(ISNULL(@JsonData,'') = '')
	BEGIN
		select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
				LocationName, IsLocationExists, BobtailRate, BobtailFormat, EffectiveDate, EffectiveDateFrom, Remarks
		from SELL_NAC_BOBTAIL_FileUploadData A
		where FileProcessKey = @FileProcessKey
		ORDER BY RecordSL
		SET @status = 0
		SET @Reason = 'File Content not found'
		return;
	END

	insert into SELL_NAC_BOBTAIL_FileContent (FileProcessKey, JsonContent, DateUploaded )
	select @FileProcessKey, @JsonData, Getdate()

	SET @JsonData = REPLACE(@JsonData,'"Customer ID"','"CustID"')
	SET @JsonData = REPLACE(@JsonData,'"Cust ID"','"CustID"')
	SET @JsonData = REPLACE(@JsonData,'"Customer Name"','"CustName"')
	SET @JsonData = REPLACE(@JsonData,'"Cust Name"','"CustName"')
	SET @JsonData = REPLACE(@JsonData,'"Rate Type"','"RateType"')
	SET @JsonData = REPLACE(@JsonData,'"Market Location"','"Market"')
	SET @JsonData = REPLACE(@JsonData,'"MarketLocation"','"Market"')

	SET @JsonData = REPLACE(@JsonData,'"Bobtail Rate"','"BobtailRate"')
	SET @JsonData = REPLACE(@JsonData,'" Bobtail Rate "','"BobtailRate"')
	SET @JsonData = REPLACE(@JsonData,'" Bobtail Rate"','"BobtailRate"')
	SET @JsonData = REPLACE(@JsonData,'"Bobtail Rate "','"BobtailRate"')

	SET @JsonData = REPLACE(@JsonData,'"Bobtail Format"','"BobtailFormat"')
	SET @JsonData = REPLACE(@JsonData,'" Bobtail Format"','"BobtailFormat"')
	SET @JsonData = REPLACE(@JsonData,'"Bobtail Format "','"BobtailFormat"')
	SET @JsonData = REPLACE(@JsonData,'"Bobtail Format"','"BobtailFormat"')


	SET @JsonData = REPLACE(@JsonData,'" City "','"City"')
	SET @JsonData = REPLACE(@JsonData,'" State "','"State"')
	SET @JsonData = REPLACE(@JsonData,'" Segment "','"Segment"')
	
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
		Segment			varchar(100),
		Market			varchar(100),
		Terminal		varchar(100),
		OrderType		varchar(100),
		City			varchar(100),
		State			varchar(100),
		Zip				varchar(100),
		LocationName	varchar(100),
		IsLocation		varchar(100),
		Consignee		varchar(100),
		TruckType		varchar(100),
		BobtailFormat	varchar(50),
		BobtailRate		varchar(100),
		EffectiveDate	varchar(100),
		EffectiveFrom	varchar(100),
		Remarks			varchar(4000),
		ExpiryDate		varchar(100)
	)

	insert into #FileData (CustID, CustName, RateType, Segment, Market, Terminal, OrderType, City, State, Zip, LocationName, 
		IsLocation, Consignee, TruckType, BobtailFormat, BobtailRate,  EffectiveDate, EffectiveFrom,ExpiryDate)
	select CustID, CustName, RateType, Segment, Market, Terminal, OrderType, City, State, Zip, LocationName, 
		IsLocation, Consignee, TruckType, BobtailFormat, Case when isnull(BobtailRate,'') = '' then '0' else BobtailRate end, 
		EffectiveDate, EffectiveFrom,ExpiryDate
	from Openjson(@jsondata,'$')
	WITH (
		CustID			varchar(100)	'$.CustID',
		CustName		varchar(100)	'$.CustomerName',
		RateType		varchar(100)	'$.RateType',
		Segment			varchar(100)	'$.Segment',
		Market			varchar(100)	'$.Market',
		Terminal		varchar(100)	'$.Terminal',
		OrderType		varchar(100)	'$.OrderType', --added column
		City			varchar(100)	'$.City',
		State			varchar(100)	'$.State',
		Zip				varchar(100)	'$.Zip',
		LocationName	varchar(100)	'$.LocationName',
		IsLocation		varchar(100)	'$.IsLocation',
		Consignee		varchar(100)	'$.Consignee', --added column
		TruckType		varchar(100)	'$.TruckType', --added column
		BobtailRate		varchar(100)	'$.BobtailRate',
		BobtailFormat	varchar(100)	'$.BobtailFormat',
		EffectiveDate	varchar(100)	'$.EffectiveDate',
		EffectiveFrom	varchar(100)	'$.EffectiveDateFrom',
		ExpiryDate	varchar(100)		'$.ExpiryDate'
	)

	--select * from #FileData

	update #FileData set
		CustID			= LTRIM(RTRIM(REPLACE(REPLACE(CustID,CHAR(10),''),CHAR(13),''))),
		CustName		= LTRIM(RTRIM(REPLACE(REPLACE(CustName,CHAR(10),''),CHAR(13),''))),
		RateType		= LTRIM(RTRIM(REPLACE(REPLACE(RateType,CHAR(10),''),CHAR(13),''))),
		Segment			= LTRIM(RTRIM(REPLACE(REPLACE(Segment,CHAR(10),''),CHAR(13),''))),
		Market			= LTRIM(RTRIM(REPLACE(REPLACE(Market,CHAR(10),''),CHAR(13),''))),
		Terminal		= LTRIM(RTRIM(REPLACE(REPLACE(Terminal,CHAR(10),''),CHAR(13),''))),
		OrderType		= LTRIM(RTRIM(REPLACE(REPLACE(OrderType,CHAR(10),''),CHAR(13),''))),
		City			= LTRIM(RTRIM(REPLACE(REPLACE(City,CHAR(10),''),CHAR(13),''))),
		State			= LTRIM(RTRIM(REPLACE(REPLACE(State,CHAR(10),''),CHAR(13),''))),
		Zip				= LTRIM(RTRIM(REPLACE(REPLACE(Zip,CHAR(10),''),CHAR(13),''))),
		LocationName	= LTRIM(RTRIM(REPLACE(REPLACE(LocationName,CHAR(10),''),CHAR(13),''))),
		IsLocation		= LTRIM(RTRIM(REPLACE(REPLACE(IsLocation,CHAR(10),''),CHAR(13),''))),
		Consignee		= LTRIM(RTRIM(REPLACE(REPLACE(Consignee,CHAR(10),''),CHAR(13),''))),
		TruckType		= LTRIM(RTRIM(REPLACE(REPLACE(TruckType,CHAR(10),''),CHAR(13),''))),
		BobtailRate		= LTRIM(RTRIM(REPLACE(REPLACE(BobtailRate,CHAR(10),''),CHAR(13),''))),
		BobtailFormat	= LTRIM(RTRIM(REPLACE(REPLACE(BobtailFormat,CHAR(10),''),CHAR(13),''))),
		EffectiveDate	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveDate,CHAR(10),''),CHAR(13),''))),
		EffectiveFrom	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveFrom,CHAR(10),''),CHAR(13),''))),
		ExpiryDate	= LTRIM(RTRIM(REPLACE(REPLACE(ExpiryDate,CHAR(10),''),CHAR(13),'')))
	

	update A Set Remarks = isnull(remarks,'')  + 'Customer ID/Name not found in TMS'+ ';'
	from #FileData A
	left join Customer C on --a.CustID = C.CustID OR 
	a.CustName = LTRIM(RTRIM(C.CustName))
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

	update A Set Remarks = isnull(remarks,'')  + 'Terminal not found in TMS'+ ';'
	from #FileData A
	Left join PriceGrouping M on A.Terminal = LTRIM(RTRIM(M.PriceGrouping))
	where M.PriceGroupingKey is null and isnull(A.Terminal ,'') <> ''

	
	
	--update A Set Remarks = isnull(remarks,'') + 'FSF should be a Percent value' + ';'
	--from #FileData A
	--where isnumeric(FSF) = 0

	update A Set Remarks = isnull(remarks,'')  + 'Bobtail Format shouldn''t be  blank'+ ';'
	from #FileData A
	where isnull(BobtailFormat,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'Bobtail Format not matching with set formats'+ ';'
	from #FileData A
	where isnull(BobtailFormat,'') = '' and BobtailFormat not in ( 'Roundtrip', 'Free', 'Percentage','Flat Fee')

	update A Set Remarks = isnull(remarks,'') + 'Bobtail Rate should be a numeric value'+ ';' 
	from #FileData A
	where isnumeric(BobtailRate) = 0 and BobtailFormat not in ( 'Roundtrip', 'Free')

	update A Set Remarks = isnull(remarks,'')  + 'Bobtail Rate can''t be Zero'+ ';'
	from #FileData A
	where convert(numeric(18,2),isnull(BobtailRate,0)) = 0 and BobtailFormat not in ( 'Roundtrip', 'Free')

	update A Set Remarks = isnull(remarks,'')  + 'Bobtail Rate should be less than or equal to 100'+ ';'
	from #FileData A
	where convert(numeric(18,2),isnull(BobtailRate,0)) > 100 and BobtailFormat  in ( 'Percentage')
	
	update A Set Remarks = isnull(remarks,'')  + 'City/State not found in TMS'+ ';'
	from #FileData A
	Left join LocationData M on A.City = LTRIM(RTRIM(M.City)) and A.State = LTRIM(RTRIM(M.State))
	where M.City is null OR M.State IS NULL

	update A Set Remarks = isnull(remarks,'')  + 'Effective Date should not be blank'+ ';'
	from #FileData A
	where isnull(EffectiveDate,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'Effective From should not be blank'+ ';'
	from #FileData A
	where isnull(EffectiveFrom,'') = ''

	update A Set Remarks = isnull(remarks,'')  + 'Location Name with City/State combination not found in TMS'+ ';'
	from #FileData A
	Left join Address M on A.City = M.City and A.State = LTRIM(RTRIM(M.State))
	--LEft join LocationData LD on M.City = LTRIM(RTRIM(LD.city)) and M.State = LTRIM(RTRIM(LD.State))
	where isnull(A.LocationName,'') <> '' and ( M.City is null OR M.State is null)

	--select * from #FileData

	insert into SELL_NAC_BOBTAIL_FileUploadData (FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, 
			MarketLocation, Terminal, OrderType, City, State, Zip, LocationName, IsLocationExists, Consignee, TruckType, BobtailRate, BobtailFormat,
			EffectiveDate, EffectiveDateFrom, Remarks,ExpiryDate)
	select @FileProcessKey, SLNO, CustID, CustName, RateType, Segment, 
			Market, Terminal, OrderType, City, State, Zip, LocationName, IsLocation, Consignee, TruckType, BobtailRate, BobtailFormat,
			EffectiveDate, EffectiveFrom, Remarks,ExpiryDate
	From #FileData

	declare @ErrorCount int = 0
	select @ErrorCount = count(1) from #FileData where isnull(Remarks,'') <> ''
	set @status = case when @ErrorCount > 0 then 0 else 1 end
	Set @Reason = Case when @ErrorCount > 0 then 'Error in Data process. Refer Remarks column' else 'Saved Successfully' end

	update SELL_NAC_BOBTAIL_FileProcessInfo set 
		FileUploadStatus = 1,
		FileProcessStatus = @status,
		IsEmailSent = 0, 
		IsFileDownloaded = 0,
		FileLink = Case when @ErrorCount > 0 then 'Error in file Creation' else '' end
	where FileProcessKey = @FileProcessKey

	--select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
	--		LocationName, IsLocationExists, BobtailRate, BobtailFormat, EffectiveDate, EffectiveDateFrom, Remarks
	--from SELL_NAC_BOBTAIL_FileUploadData A
	--where FileProcessKey = @FileProcessKey
	--ORDER BY RecordSL for json path, without_array_wrapper

	if(isnull(@status,0) = 1)
	Begin
		Exec SELL_NAC_BOBTAIL_MoveFinalDataOutput @FileProcessKey, @status output, @Reason output
	End
END
