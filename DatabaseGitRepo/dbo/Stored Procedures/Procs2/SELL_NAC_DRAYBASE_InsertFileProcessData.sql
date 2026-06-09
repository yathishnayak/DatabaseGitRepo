/*
truncate table SELL_NAC_Draybase_FileContent
TRUNCATE TABLE SELL_NAC_Draybase_FileUploadData
declare @FileProcessKey	int = 1,@JsonData nvarchar(max) = '', @status bit = 0 ,@Reason varchar(100)='' 
Set @JsonData = '[{"Customer ID":"1UP","Customer Name":"1UP Cargo (JCB-IPG)","Rate Type":"NAC","Market Location":"LONG BEACH","Terminal":"LA/LB"," Drayage Base ":500,"City":"RANCHO CUCAMONGA","State":"CA"," Effective Date ":44197,"Effective Date From":"Order Creation"},{"Customer ID":"1UP","Customer Name":"1UP Cargo (JCB-IPG)","Rate Type":"NAC","Market Location":"LONG BEACH","Terminal":"LA/LB"," Drayage Base ":600,"City":"COMMERCE","State":"CA"},{"Customer ID":"1UP","Customer Name":"1UP Cargo (JCB-IPG)","Rate Type":"NAC","Market Location":"LONG BEACH","Terminal":"LA/LB"," Drayage Base ":325,"City":"LONG BEACH ","State":"CA"},{"Customer ID":"AFI","Customer Name":"Accelerated Freight, Inc.(JCT)","Rate Type":"NAC","Market Location":"Long Beach","Terminal":"LA/LB"," Drayage Base ":625,"City":"Fontana","State":"CA"},{"Customer ID":"Access World USA LLC","Customer Name":"Access World USA LLC (IPG-JCB)","Rate Type":"NAC","Market Location":"Long Beach","Terminal":"LA/LB"," Drayage Base ":510,"City":"Carson","State":"CA"},{"Customer ID":"Access World USA LLC","Customer Name":"Access World USA LLC (IPG-JCB)","Rate Type":"NAC","Market Location":"Long Beach","Terminal":"LA/LB"," Drayage Base ":510,"City":"Chino","State":"CA"}]'
Exec SELL_NAC_DRAYBASE_InsertFileProcessData @FileProcessKey, @JsonData, @status output, @Reason output
Select @status, @Reason
*/
CREATE PRoc [dbo].[SELL_NAC_DRAYBASE_InsertFileProcessData]
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

	insert into SELL_NAC_Draybase_FileContent (FileProcessKey, JsonContent, DateUploaded )
	select @FileProcessKey, @JsonData, Getdate()

	SET @JsonData = REPLACE(@JsonData,'"Customer ID"','"CustID"')
	SET @JsonData = REPLACE(@JsonData,'"Cust ID"','"CustID"')
	SET @JsonData = REPLACE(@JsonData,'"Customer Name"','"CustName"')
	SET @JsonData = REPLACE(@JsonData,'"Cust Name"','"CustName"')
	SET @JsonData = REPLACE(@JsonData,'"Rate Type"','"RateType"')
	SET @JsonData = REPLACE(@JsonData,'"Market Location"','"Market"')
	SET @JsonData = REPLACE(@JsonData,'"MarketLocation"','"Market"')
	SET @JsonData = REPLACE(@JsonData,'"Drayage Base"','"Draybase"')
	SET @JsonData = REPLACE(@JsonData,'"Drayage Base "','"Draybase"')
	SET @JsonData = REPLACE(@JsonData,'" Drayage Base"','"Draybase"')
	SET @JsonData = REPLACE(@JsonData,'" Drayage Base "','"Draybase"')
	
	SET @JsonData = REPLACE(@JsonData,'" City "','"City"')
	SET @JsonData = REPLACE(@JsonData,'" State "','"State"')
	SET @JsonData = REPLACE(@JsonData,'" Segment "','"Segment"')
	SET @JsonData = REPLACE(@JsonData,'" FSF "','"FSF"')
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
		CustID			varchar(300),
		CustName		varchar(300),
		RateType		varchar(100),
		Segment			varchar(100),
		Market			varchar(300),
		Terminal		varchar(300),
		OrderType		varchar(100),
		City			varchar(200),
		State			varchar(100),
		Zip				varchar(100),
		LocationName	varchar(300),
		IsLocation		varchar(100),
		Consignee		varchar(300),
		TruckType		varchar(100),
		DraybaseCost	varchar(100),
		FSF				varchar(100),
		EffectiveDate	varchar(100),
		EffectiveFrom	varchar(100),
		Remarks			varchar(4000),
		ExpiryDate		varchar(100)
	)

	insert into #FileData (CustID, CustName, RateType, Segment, Market, Terminal, OrderType, City, State, Zip, LocationName, 
		IsLocation, Consignee, TruckType, DraybaseCost, FSF, EffectiveDate, EffectiveFrom,ExpiryDate)
	select CustID, CustName, RateType, Segment, Market, Terminal, OrderType, City, State, Zip, LocationName, 
		IsLocation, Consignee, TruckType, DraybaseCost, FSF, EffectiveDate, EffectiveFrom,ExpiryDate
	from Openjson(@jsondata,'$')
	WITH (
		CustID			varchar(300)	'$.CustID',
		CustName		varchar(300)	'$.CustomerName',
		RateType		varchar(100)	'$.RateType',
		Segment			varchar(100)	'$.Segment',
		Market			varchar(300)	'$.Market',
		Terminal		varchar(300)	'$.Terminal',
		OrderType		varchar(100)	'$.OrderType', --added column
		City			varchar(200)	'$.City',
		State			varchar(100)	'$.State',
		Zip				varchar(100)	'$.Zip',
		LocationName	varchar(300)	'$.LocationName',
		IsLocation		varchar(100)	'$.LocationNameinTheSystem',
		Consignee		varchar(300)	'$.Consignee', --added column
		TruckType		varchar(100)	'$.TruckType', --added column
		DraybaseCost	varchar(100)	'$.DrayageBase',
		FSF				varchar(100)	'$.FSF',
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
		DraybaseCost	= LTRIM(RTRIM(REPLACE(REPLACE(DraybaseCost,CHAR(10),''),CHAR(13),''))),
		FSF				= LTRIM(RTRIM(REPLACE(REPLACE(FSF,CHAR(10),''),CHAR(13),''))),
		EffectiveDate	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveDate,CHAR(10),''),CHAR(13),''))),
		EffectiveFrom	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveFrom,CHAR(10),''),CHAR(13),''))),
		ExpiryDate	= LTRIM(RTRIM(REPLACE(REPLACE(ExpiryDate,CHAR(10),''),CHAR(13),'')))
	

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

	update A Set Remarks = isnull(remarks,'')  + 'Terminal not found in TMS'+ ';'
	from #FileData A
	Left join PriceGrouping M on A.Terminal = LTRIM(RTRIM(M.PriceGrouping))
	where M.PriceGroupingKey is null

	update A Set Remarks = isnull(remarks,'') + 'Draybase cost should be a numeric value'+ ';' 
	from #FileData A
	where isnumeric(DraybaseCost) = 0

	update A Set Remarks = isnull(remarks,'')  + 'Draybase cost can''t be Zero'+ ';'
	from #FileData A
	where convert(numeric(18,2),isnull(DraybaseCost,0)) = 0
	
	--update A Set Remarks = isnull(remarks,'') + 'FSF should be a Percent value' + ';'
	--from #FileData A
	--where isnumeric(FSF) = 0

	update A Set Remarks = isnull(remarks,'')  + 'FSF % shouldn''t be  above 99'+ ';'
	from #FileData A
	where convert(numeric(18,8),isnull(FSF,0)) > 99
	
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

	insert into SELL_NAC_Draybase_FileUploadData (FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, 
			MarketLocation, Terminal, OrderType, City, State, Zip, LocationName, IsLocationExists, Consignee, TruckType, DraybaseCost, FSF,
			EffectiveDate, EffectiveDateFrom, Remarks,ExpiryDate)
	select @FileProcessKey, SLNO, CustID, CustName, RateType, Segment, 
			Market, Terminal, OrderType, City, State, Zip, LocationName, IsLocation, Consignee, TruckType, DraybaseCost, FSF,
			EffectiveDate, EffectiveFrom, Remarks,ExpiryDate
	From #FileData

	declare @ErrorCount int = 0
	select @ErrorCount = count(1) from #FileData where isnull(Remarks,'') <> ''
	set @status = case when @ErrorCount > 0 then 0 else 1 end
	Set @Reason = Case when @ErrorCount > 0 then 'Error in Data process. Refer Remarks column' else 'Saved Successfully' end

	update SELL_NAC_Draybase_FileProcessInfo set 
		FileUploadStatus = 1,
		FileProcessStatus = @status,
		IsEmailSent = 0, 
		IsFileDownloaded = 0,
		FileLink = Case when @ErrorCount > 0 then 'Error in file Creation' else '' end
	where FileProcessKey = @FileProcessKey

	--select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
	--		LocationName, IsLocationExists, DraybaseCost, FSF, EffectiveDate, EffectiveDateFrom, Remarks
	--from SELL_NAC_Draybase_FileUploadData A
	--where FileProcessKey = @FileProcessKey
	--ORDER BY RecordSL for json path, without_array_wrapper

	if(isnull(@status,0) = 1)
	Begin
		Exec SELL_NAC_Draybase_MoveFinalDataOutput @FileProcessKey, @status output, @Reason output
	End
END
