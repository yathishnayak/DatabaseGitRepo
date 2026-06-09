
/*
--truncate table SELL_NAC_Draybase_FileContent
--TRUNCATE TABLE SELL_NAC_Draybase_FileUploadData
declare @UserKey	int = 29,@JsonData nvarchar(max) = '', @status bit = 0 ,@Reason varchar(100)=''
Set @JsonData = '{"FileName":"Flexport 2025 - Copy.xlsx","CustKey":1966,"SheetData":"{\"Sheet1\":[{\"Customer Name\":\"Flexport, LLC. - (IPG-JCB)\",\"Rate Type\":\"NAC\",\"Market Location\":\"Chicago\",\"Terminal\":\"Joliet\",\"Drayage Base\":320,\"FSF\":0.27,\"City\":\"Addison\",\"State\":\"IL\",\"Zip\":60101,\"Effective Date\":\"2025-03-01\",\"Effective Date From\":\"Invoice Date\"},{\"Customer Name\":\"Flexport, LLC. - (IPG-JCB)\",\"Rate Type\":\"NAC\",\"Market Location\":\"Chicago\",\"Terminal\":\"Joliet\",\"Drayage Base\":320,\"FSF\":0.27,\"City\":\"Alsip\",\"State\":\"IL\",\"Zip\":60803,\"Effective Date\":\"2025-03-01\",\"Effective Date From\":\"Invoice Date\"},{\"Customer Name\":\"Flexport, LLC. - (IPG-JCB)\",\"Rate Type\":\"NAC\",\"Market Location\":\"Chicago\",\"Terminal\":\"Joliet\",\"Drayage Base\":975,\"FSF\":0.27,\"City\":\"Appleton\",\"State\":\"WI\",\"Zip\":54914,\"Effective Date\":\"2025-03-01\",\"Effective Date From\":\"Invoice Date\"}]}"}'
Exec [SELL_NAC_DRAYBASE_UploadData] @UserKey,  @JsonData, @status output, @Reason output
Select @status, @Reason
*/

CREATE PRoc [dbo].[SELL_NAC_DRAYBASE_UploadData]
(
	@UserKey			int = 0,
	@JSONString			nvarchar(max) = '',
	@status				bit = 0 output,
	@Reason				varchar(100)='' output
) 
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE		@ISSuccess			BIT = 1, 
				@FileName			VARCHAR(100),
				@CustKey			VARCHAR(50),
				@SheetData			nvarchar(max),

				@Remarks VARCHAR(100) = 'Record Saved Successfully', 
				@ErrorMessage VARCHAR(100) = 'Something went wrong, Contact System Administrator. Error Code : '

	DECLARE		@FileProcessKey INT = 0

	select 
		@FileName	= FName,
		@CustKey	= CustKey,
		@SheetData	= SheetData
	from Openjson(@JSONString,'$')
	WITH (
		FName			varchar(100)	'$.FileName',
		CustKey			varchar(100)	'$.CustKey',
		SheetData		nvarchar(max)	'$.SheetData' 
	)

	--select @SheetData as SheetData 

	If(ISNULL(@FileName,'') = '')
	BEGIN
		SET @ISSuccess = 0
		SET @Remarks = @ErrorMessage + '101'
	END
	ELSE IF (@UserKey = 0)
	BEGIN
		SET @ISSuccess = 0
		SET @Remarks = @ErrorMessage + '103'
	END

	if(@ISSuccess= 0)
	Begin
		SET @status = 0

		Return 
	End
	IF(@ISSuccess = 1)
	BEGIN
		INSERT INTO		SELL_NAC_Draybase_FileProcessInfo
						(FileName,DateUploaded,CustKey, FileUploadStatus,FileProcessStatus,IsEmailSent,UserKey)
		SELECT			@FileName,GETDATE(),@CustKey,0,0,0,@UserKey

		SET				@FileProcessKey = @@IDENTITY
	END

	IF(ISNULL(@FileProcessKey ,0) = 0)
	BEGIN
		SET @status = 0
		SET @Reason = 'No File PRocess Key'
		return;
	END
	IF(ISNULL(@SheetData,'') = '')
	BEGIN
		SET @status = 0
		SET @Reason = 'File Content not found'
		return;
	END

	insert into SELL_NAC_Draybase_FileContent (FileProcessKey, JsonContent, DateUploaded )
	select @FileProcessKey, @SheetData, Getdate()

	SET @SheetData = REPLACE(@SheetData,'"Customer ID"','"CustID"')
	SET @SheetData = REPLACE(@SheetData,'"Cust ID"','"CustID"')
	SET @SheetData = REPLACE(@SheetData,'"Customer Name"','"CustName"')
	SET @SheetData = REPLACE(@SheetData,'"Cust Name"','"CustName"')
	SET @SheetData = REPLACE(@SheetData,'"Rate Type"','"RateType"')
	SET @SheetData = REPLACE(@SheetData,'"Market Location"','"Market"')
	SET @SheetData = REPLACE(@SheetData,'"MarketLocation"','"Market"')
	SET @SheetData = REPLACE(@SheetData,'"Drayage Base"','"Draybase"')
	SET @SheetData = REPLACE(@SheetData,'"Drayage Base "','"Draybase"')
	SET @SheetData = REPLACE(@SheetData,'" Drayage Base"','"Draybase"')
	SET @SheetData = REPLACE(@SheetData,'" Drayage Base "','"Draybase"')
	
	SET @SheetData = REPLACE(@SheetData,'" City "','"City"')
	SET @SheetData = REPLACE(@SheetData,'" State "','"State"')
	SET @SheetData = REPLACE(@SheetData,'" Segment "','"Segment"')
	SET @SheetData = REPLACE(@SheetData,'" FSF "','"FSF"')
	SET @SheetData = REPLACE(@SheetData,'"Location Name"','"LocationName"')
	SET @SheetData = REPLACE(@SheetData,'" Location Name "','"LocationName"')
	SET @SheetData = REPLACE(@SheetData,'" Location In the System? "','"IsLocation"')
	SET @SheetData = REPLACE(@SheetData,'" Location In the System?"','"IsLocation"')
	SET @SheetData = REPLACE(@SheetData,'"Location In the System?"','"IsLocation"')
	SET @SheetData = REPLACE(@SheetData,'" Location In the System? "','"IsLocation"')
	SET @SheetData = REPLACE(@SheetData,'" Effective Date "','"EffectiveDate"')
	SET @SheetData = REPLACE(@SheetData,'"Effective Date"','"EffectiveDate"')
	SET @SheetData = REPLACE(@SheetData,'"Effective Date From"','"EffectiveFrom"')
	SET @SheetData = REPLACE(@SheetData,'" Effective Date From "','"EffectiveFrom"')

	Create table #FileData
	(
		SLNO			int identity(1,1),
		CustID			varchar(100),
		CustName		varchar(100),
		RateType		varchar(100),
		Segment			varchar(100),
		Market			varchar(100),
		Terminal		varchar(100),
		City			varchar(100),
		State			varchar(100),
		Zip				varchar(100),
		LocationName	varchar(100),
		IsLocation		varchar(100),
		DraybaseCost	varchar(100),
		FSF				varchar(100),
		EffectiveDate	varchar(100),
		EffectiveFrom	varchar(100),
		Remarks			varchar(4000)
	)

	insert into #FileData (CustID, CustName, RateType, Segment, Market, Terminal, City, State, Zip, LocationName, 
		IsLocation, DraybaseCost, FSF, EffectiveDate, EffectiveFrom)
	select CustID, CustName, RateType, Segment, Market, Terminal, City, State, Zip, LocationName, 
		IsLocation, DraybaseCost, FSF, EffectiveDate, EffectiveFrom
	from Openjson(@SheetData,'$.Sheet1')
	WITH (
		CustID			varchar(100)	'$.CustID',
		CustName		varchar(100)	'$.CustName',
		RateType		varchar(100)	'$.RateType',
		Segment			varchar(100)	'$.Segment',
		Market			varchar(100)	'$.Market',
		Terminal		varchar(100)	'$.Terminal',
		City			varchar(100)	'$.City',
		State			varchar(100)	'$.State',
		Zip				varchar(100)	'$.Zip',
		LocationName	varchar(100)	'$.LocationName',
		IsLocation		varchar(100)	'$.IsLocation',
		DraybaseCost	varchar(100)	'$.Draybase',
		FSF				varchar(100)	'$.FSF',
		EffectiveDate	varchar(100)	'$.EffectiveDate',
		EffectiveFrom	varchar(100)	'$.EffectiveFrom'
	)

	--select * from #FileData

	update #FileData set
		CustID			= LTRIM(RTRIM(REPLACE(REPLACE(CustID,CHAR(10),''),CHAR(13),''))),
		CustName		= LTRIM(RTRIM(REPLACE(REPLACE(CustName,CHAR(10),''),CHAR(13),''))),
		RateType		= LTRIM(RTRIM(REPLACE(REPLACE(RateType,CHAR(10),''),CHAR(13),''))),
		Segment			= LTRIM(RTRIM(REPLACE(REPLACE(Segment,CHAR(10),''),CHAR(13),''))),
		Market			= LTRIM(RTRIM(REPLACE(REPLACE(Market,CHAR(10),''),CHAR(13),''))),
		Terminal		= LTRIM(RTRIM(REPLACE(REPLACE(Terminal,CHAR(10),''),CHAR(13),''))),
		City			= LTRIM(RTRIM(REPLACE(REPLACE(City,CHAR(10),''),CHAR(13),''))),
		State			= LTRIM(RTRIM(REPLACE(REPLACE(State,CHAR(10),''),CHAR(13),''))),
		Zip				= LTRIM(RTRIM(REPLACE(REPLACE(Zip,CHAR(10),''),CHAR(13),''))),
		LocationName	= LTRIM(RTRIM(REPLACE(REPLACE(LocationName,CHAR(10),''),CHAR(13),''))),
		IsLocation		= LTRIM(RTRIM(REPLACE(REPLACE(IsLocation,CHAR(10),''),CHAR(13),''))),
		DraybaseCost	= LTRIM(RTRIM(REPLACE(REPLACE(DraybaseCost,CHAR(10),''),CHAR(13),''))),
		FSF				= LTRIM(RTRIM(REPLACE(REPLACE(FSF,CHAR(10),''),CHAR(13),''))),
		EffectiveDate	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveDate,CHAR(10),''),CHAR(13),''))),
		EffectiveFrom	= LTRIM(RTRIM(REPLACE(REPLACE(EffectiveFrom,CHAR(10),''),CHAR(13),'')))
	

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
	where convert(numeric(18,2),isnull(FSF,0)) > 99
	
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
			MarketLocation, Terminal, City, State, Zip, LocationName, IsLocationExists, DraybaseCost, FSF,
			EffectiveDate, EffectiveDateFrom, Remarks)
	select @FileProcessKey, SLNO, CustID, CustName, RateType, Segment, 
			Market, Terminal, City, State, Zip, LocationName, IsLocation, DraybaseCost, FSF,
			EffectiveDate, EffectiveFrom, Remarks
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

	select FileProcessKey, RecordSL, CustID, CustName, RateType, Segment, MarketLocation, Terminal, City, State, Zip, 
			LocationName, IsLocationExists, DraybaseCost, FSF, EffectiveDate, EffectiveDateFrom, Remarks
	from SELL_NAC_Draybase_FileUploadData A
	where FileProcessKey = @FileProcessKey
	ORDER BY RecordSL
	FOR JSON PATH

	if(isnull(@status,0) = 1)
	Begin
		Exec SELL_NAC_Draybase_MoveFinalDataOutput @FileProcessKey, @status output, @Reason output
	End
END
