--select * from Driver_MoveType
/*
declare  @JSONString	nvarchar(max) = '',@UserKey	int = 0, @Reason VARCHAR(50) = '', @Status bit = 0
set @JSONString   = '{"DriverKey":940,"DriverID":"VARGAS TRUCKING","FirstName":"GUSTAVO","LastName":"VARGAS","AddrKey":27441,"CreateDate":"2023-04-25T17:07:26.727","StatusKey":1,"StatusDate":"2023-04-25T17:07:26.727","CompanyKey":1,"OrgName":"VARGAS TRUCKING","PhysicalAddrKey":27442,"TelePhone":"714-290-6059","BusinessNumber":"714-290-6059","CellNumber":"714-290-6059","EmailAddress":"TRUCKINGVARGAS.INC@GMAIL.COM","DOTNumber":"3127210","MCNumber":"1520909","TaxIDNumber":"82-5286025","YearsUnderCurrentName":0,"FactoringCompany":"N/A","InsuranceCompany":"AGS MARINE","PolicyNumber":"IMGL20236280-756A","PolicyExpDate":"2024-03-01T08:00:00","insuranceAgentName":"M & O CALIFORNIA INSURANCE SERVICES","ExpiryDays":770,"InsuranceAgentNumber":"323-722-0812","PayTypeKey":5,"NoOfTrucks":1,"BillingAddress":{"AddrKey":27441,"AddrName":"GUSTAVO VARGAS","Address1":"16558 PAINE ST","Address2":"UNIT","City":"Fontana","State":"CA","Zip":"92336","Country":"USA"},"PhysicalAddress":{"AddrKey":27442,"AddrName":"GUSTAVO VARGAS","Address1":"16558 PAINE ST","City":"Fontana","State":"CA","Zip":"92336","Country":"USA"},"ContactNames":[{"DriverContactKey":23,"DriverKey":940,"ContactName":"poo","ContactNumber":"3245667767","ContactEmail":"p@s.com"},{"DriverContactKey":24,"DriverKey":940,"ContactName":"poo1","ContactNumber":"32543534","ContactEmail":"e@h.com"}],"MarketLocationKey":2,"TruckTypeKey":2,"ExpiryPeriod":"Expired","ExpiryCode":"rgb(139, 0, 0)","DriverMoveTypeList":[{"DriverKey":940,"MoveTypeKey":1,"MoveTypeName":"OTR","IsSelected":true},{"DriverKey":940,"MoveTypeKey":2,"MoveTypeName":"PORT","IsSelected":false}],"DriverFTCList":[{"DriverKey":940,"FTCKey":2,"FTCName":"C-corporation","IsSelected":false},{"DriverKey":940,"FTCKey":5,"FTCName":"Individual/Sole Proprietor or Single Member LLC","IsSelected":false},{"DriverKey":940,"FTCKey":3,"FTCName":"Partnership","IsSelected":false},{"DriverKey":940,"FTCKey":1,"FTCName":"S-corporation","IsSelected":true},{"DriverKey":940,"FTCKey":4,"FTCName":"Trust/Estate","IsSelected":false}],"DriverLLCList":[{"DriverKey":940,"LLCKey":2,"LLCName":"C-corporation","IsSelected":true},{"DriverKey":940,"LLCKey":3,"LLCName":"Partnership","IsSelected":false},{"DriverKey":940,"LLCKey":1,"LLCName":"S-corporation","IsSelected":false}],"Address":{"AddrKey":27441,"AddrName":"GUSTAVO VARGAS","Address1":"16558 PAINE ST","Address2":"UNIT","City":"Fontana","State":"CA","Zip":"92336","Country":"USA"},"PhyAddress":{"AddrKey":27442,"AddrName":"GUSTAVO VARGAS","Address1":"16558 PAINE ST","City":"Fontana","State":"CA","Zip":"92336","Country":"USA"}}'
set @UserKey = 488
exec DriverCarrier_InsertUpdate_V2 @JSONString, @UserKey, @Reason OUTPUT, @Status output
select @Reason AS Reason, @Status AS Status
*/

/*
declare  @JSONString	nvarchar(max) = '',@UserKey	int = 0, @Reason VARCHAR(50) = '', @Status bit = 0
set @JSONString   = '{"ContactNames":[{"ContactName":"contact25","ContactNumber":13,"ContactDesignation":"sehj","ContactEmail":"t@n5.com","DriverContactKey":9}],"BillingAddress":{"Address1":"34 street ","Zip":"90003","City":"Los Angeles","State":"CA","Country":"USA"},"PhysicalAddress":{"Address1":"500 street","Zip":"90005","City":"Los Angeles","State":"CA","Country":"USA"},"DriverMoveTypeList":[{"DriverKey":0,"MoveTypeKey":1,"MoveTypeName":"OTR","IsSelected":false},{"DriverKey":0,"MoveTypeKey":2,"MoveTypeName":"PORT","IsSelected":true}],"DriverFTCList":[{"DriverKey":0,"FTCKey":2,"FTCName":"C-corporation","IsSelected":true},{"DriverKey":0,"FTCKey":5,"FTCName":"Individual/Sole Proprietor or Single Member LLC","IsSelected":false},{"DriverKey":0,"FTCKey":3,"FTCName":"Partnership","IsSelected":false},{"DriverKey":0,"FTCKey":1,"FTCName":"S-corporation","IsSelected":false},{"DriverKey":0,"FTCKey":4,"FTCName":"Trust/Estate","IsSelected":false}],"DriverLLCList":[{"DriverKey":0,"LLCKey":2,"LLCName":"C-corporation","IsSelected":true},{"DriverKey":0,"LLCKey":3,"LLCName":"Partnership","IsSelected":false},{"DriverKey":0,"LLCKey":1,"LLCName":"S-corporation","IsSelected":false}],"OrgName":"carrier 1","DriverID":"carrier901","FirstName":"carrier ","StatusKey":"1","MarketLocationKey":"12","TruckTypeKey":3,"PayTypeKey":"5","EmailAddress":"i@h.com","TelePhone":"16545645645","CellNumber":"6","FaxNumber":"454","DOTNumber":"3454","MCNumber":"5433","TaxIDNumber":"34533","PolicyNumber":"567","PolicyExpDate":"2023-12-20T18:30:00.000Z","insuranceAgentName":"abc","InsuranceAgentNumber":"6867","NoOfTrucks":90,"FactoringCompany":"fghfg","InsuranceCompany":"fghfg","YearsUnderCurrentName":2,"Address":{"Address1":"34 street ","Zip":"90003","City":"Los Angeles","State":"CA","Country":"USA"},"PhyAddress":{"Address1":"500 street","Zip":"90005","City":"Los Angeles","State":"CA","Country":"USA"}}'
set @UserKey = 488
exec DriverCarrier_InsertUpdate_V2 @JSONString, @UserKey, @Reason OUTPUT, @Status output
select @Reason AS Reason, @Status AS Status
*/
CREATE procedure [dbo].[DriverCarrier_InsertUpdate_V2] 
(
	--@DriverKey		int = 0 output,
	--@JSONText		nvarchar(max) = '',
	@JSONString nvarchar(max) = '',
	@UserKey		int = 0,
	-- @Output			Bit = 0 OUTPUT,
	@Reason			VARCHAR(1000) = ''OUTPUT,
	@Status         Bit = 0 OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
    
 
	--IF(   @UserKey = 0 OR @JSONText = '')
	IF(   @UserKey = 0 OR @JSONString = '')
	BEGIN
		--SET @Output = 0
		SET @Status = 0
		SET @Reason = 'UserKey and JSONString cannot be empty'
		RETURN
	END

	CREATE TABLE #Driver
	(
		DriverKey					int	,
		DriverID					varchar(20),
		FirstName					varchar	(100),
		LastName					varchar	(100),
		AddrKey						int,
		CarrierKey					int,
		--DrivingLicenseNo			varchar	(50),
		--DrivingLicenseExpiryDate	datetime,
		--CreateDate					datetime,	
		StatusKey					int,
		--StatusDate					datetime,
		--VendKey						int,
		CompanyKey					smallint,
		--HireDate					datetime,
		Plate						varchar(20),
		YearMake					varchar(20),
		VINId						varchar(50),
		RFID						varchar(20),
		ContactNo					varchar(30),
		OrgName						varchar(100),
		OrgZipCode					varchar(20),
		FuelCardNo					varchar(50),
		OrgCity						varchar(100),
		OrgState					varchar(100),
		OrgCountry					varchar(100),
		LastUpdateDate				datetime,
		CreateUserKey				int,
		LastUpdateUserKey			int,
		TractorLicenseNo			varchar(50),
		DriverHubKey				int,
		PhysicalAddrKey				int,
		TelePhone					varchar(50),
		BusinessNumber				varchar(50 ),
		CellNumber					varchar(50 ),
		FaxNumber					varchar(50 ),
		EmailAddress				varchar(200),
		DOTNumber					varchar(100),
		MCNumber					varchar(100),
		TaxIDNumber					varchar(100),
		YearsUnderCurrentName		int	,
		FactoringCompany			varchar	(100),
		InsuranceCompany			varchar	(100),
		PolicyNumber				varchar	(100),
		PolicyExpDate				datetime,
		insuranceAgentName			varchar	(100),
		InsuranceAgentNumber		varchar	(100),
		PayTypeKey					smallint,
		NoOfTrucks					INT,
		IsActive                    BIT,
		IsDelete					BIT,
		MarketLocationKey			INT,
		TruckTypeKey				INT
	)

	Create table #BillingAddress
	(
		AddrKey		int	,
		AddrName	varchar	(255),
		Address1	varchar	(255),
		Address2	varchar	(255),
		City		varchar	(255),
		State		varchar	(255),
		ZipCode		varchar	(50	),
		Country		char	(3),
		Website		varchar	(255),
		Phone		varchar	(20	),
		Email		varchar	(255),
		Fax			varchar	(20	),
		Phone2		varchar	(20	),
		Email2		varchar	(50	),
		CityKey		int	
	)

	Create table #PhysicalAddress
	(
		AddrKey		int	,
		AddrName	varchar	(255),
		Address1	varchar	(255),
		Address2	varchar	(255),
		City		varchar	(255),
		State		varchar	(255),
		ZipCode		varchar	(50	),
		Country		char	(3),
		Website		varchar	(255),
		Phone		varchar	(20	),
		Email		varchar	(255),
		Fax			varchar	(20	),
		Phone2		varchar	(20	),
		Email2		varchar	(50	),
		CityKey		int	
	)

	create table #DriverContacts
	(
		DriverContactKey	int,
		DriverKey			int,
		ContactKey			int,
		ContactName			varchar(100),
		ContactDesignation	varchar(100),
		ContactNumber		varchar(100),
		ContactEmail		varchar(100)
	)

	create table #DriverMoveType
	(
		DriverKey	int,
		MoveTypeKey	smallint,
		IsSelected	bit	default 0
	)

	create table #DriverFTC
	(
		DriverKey	int,
		FTCKey		smallint,
		IsSelected	bit	default 0
	)

	create table #DriverLLC
	(
		DriverKey	int,
		LLCKey		smallint,
		IsSelected	bit	default 0
	)
	DECLARE @DriverKey		int = 0

	insert into #Driver (DriverKey, DriverID, FirstName, LastName, AddrKey,CarrierKey, 
		StatusKey, ContactNo, OrgName, OrgZipCode, OrgCity, OrgState, 
		OrgCountry, 
		PhysicalAddrKey, TelePhone, BusinessNumber, CellNumber, FaxNumber, 
		EmailAddress, DOTNumber, MCNumber, TaxIDNumber, YearsUnderCurrentName, 
		FactoringCompany, InsuranceCompany, PolicyNumber, 
		PolicyExpDate, 	insuranceAgentName, InsuranceAgentNumber, PayTypeKey, NoOfTrucks,IsActive,IsDelete, MarketLocationKey, TruckTypeKey)
	select DriverKey, DriverID, FirstName, LastName, AddrKey,CarrierKey, 
		StatusKey, ContactNo, OrgName, OrgZipCode, OrgCity, OrgState, 
		OrgCountry, 
		PhysicalAddrKey, TelePhone, BusinessNumber, CellNumber, FaxNumber, 
		EmailAddress, DOTNumber, MCNumber, TaxIDNumber, YearsUnderCurrentName, 
		FactoringCompany, InsuranceCompany, PolicyNumber, 
		case when ISDATE(PolicyExpDate) = 1 then CAST(PolicyExpDate as datetime) else null end, 
		insuranceAgentName, InsuranceAgentNumber, PayTypeKey, NoOfTrucks,IsActive,IsDelete, MarketLocationKey,TruckTypeKey
	--from OpenJson(@JsonText,'$')
	from OpenJson(@JSONString,'$')
	With
	(
		DriverKey					int				'$.DriverKey',
		DriverID					varchar(20)		'$.DriverID',
		FirstName					varchar	(100)	'$.FirstName',
		LastName					varchar	(100)	'$.LastName',
		AddrKey						int				'$.AddrKey',
		CarrierKey					int				'$.CarrierKey',
		StatusKey					smallint		'$.StatusKey',
		ContactNo					varchar(30)		'$.ContactNo',
		OrgName						varchar(100)	'$.OrgName',
		OrgZipCode					varchar(20)		'$.OrgZipCode',
		OrgCity						varchar(100)	'$.OrgCity',
		OrgState					varchar(100)	'$.OrgState',
		OrgCountry					varchar(100)	'$.OrgCountry',

		PhysicalAddrKey				int				'$.PhysicalAddrKey',
		TelePhone					varchar(50)		'$.TelePhone',
		BusinessNumber				varchar(50 )	'$.BusinessNumber',
		CellNumber					varchar(50 )	'$.CellNumber',
		FaxNumber					varchar(50 )	'$.FaxNumber',
		EmailAddress				varchar(200)	'$.EmailAddress',
		DOTNumber					varchar(100)	'$.DOTNumber',
		MCNumber					varchar(100)	'$.MCNumber',
		TaxIDNumber					varchar(100)	'$.TaxIDNumber',
		YearsUnderCurrentName		int				'$.YearsUnderCurrentName',
		FactoringCompany			varchar	(100)	'$.FactoringCompany',
		InsuranceCompany			varchar	(100)	'$.InsuranceCompany',
		PolicyNumber				varchar	(100)	'$.PolicyNumber',
		PolicyExpDate				varchar (50)	'$.PolicyExpDate',
		insuranceAgentName			varchar	(100)	'$.insuranceAgentName',
		InsuranceAgentNumber		varchar	(100)	'$.InsuranceAgentNumber',
		PayTypeKey				smallint       	'$.PayTypeKey',
		NoOfTrucks					INT				'$.NoOfTrucks',
		IsActive					BIT				'$.IsActive',
		IsDelete					BIT				'$.IsDelete',
		MarketLocationKey			INT				'$.MarketLocationKey',
		TruckTypeKey				INT				'$.TruckTypeKey'

	)
 
 SET @DriverKey=(SELECT DriverKey FROM #Driver)
	declare @BillAddress nvarchar(max),
			@PhyAddress  nvarchar(max),
			@ContactNames  nvarchar(max),
			@addrName		varchar(100) = '',
			@MoveTypes		varchar(1000) = '',
			@FTC			VARCHAR(1000)='',
			@LLC			VARCHAR(1000)=''

	select @BillAddress = BillingAddress, @PhyAddress = PhysicalAddress,
			@ContactNames = ContactNames, @MoveTypes = DriverMoveTypeList,
			@FTC = DriverFTCList, @LLC = DriverLLCList
	--from OpenJson(@JsonText, '$')
	from OpenJson(@JSONString, '$')
	with
	(
		BillingAddress	nvarchar(max)	'$.BillingAddress' as Json,
		PhysicalAddress nvarchar(max)	'$.PhysicalAddress' as Json,
		ContactNames	nvarchar(max)	'$.ContactNames' as Json,
		DriverMoveTypeList nvarchar(max) '$.DriverMoveTypeList' as Json,
		DriverFTCList nvarchar(max)		'$.DriverFTCList' as Json,
		DriverLLCList nvarchar(max)		'$.DriverLLCList' as Json
	)

	select @addrName = isnull(FirstName,'') + ' ' + isnull(LastName,'') from #Driver
	--select @BillAddress , @PhyAddress, 	@ContactNames

	if(ISNULL(@BillAddress,'')<> '')
	Begin
		insert into #BillingAddress (AddrKey, AddrName, Address1, Address2,City, 
				State, ZipCode, Country, 
				Website, Phone, Email, Fax, Phone2, Email2, CityKey)
		select AddrKey, AddrName, Address1, Address2,City, State, ZipCode, Country, 
				Website, Phone, Email, Fax, Phone2, Email2, CityKey
		from OpenJson(@BillAddress,'$')
		with 
		(
			AddrKey		int				'$.AddrKey',
			AddrName	varchar	(255)	'$.AddrName',
			Address1	varchar	(255)	'$.Address1',
			Address2	varchar	(255)	'$.Address2',
			City		varchar	(255)	'$.City',
			State		varchar	(255)	'$.State',
			ZipCode		varchar	(50	)	'$.Zip',
			Country		char	(3)		'$.Country',
			Website		varchar	(255)	'$.Website',
			Phone		varchar	(20	)	'$.Phone',
			Email		varchar	(255)	'$.Email',
			Fax			varchar	(20	)	'$.Fax',
			Phone2		varchar	(20	)	'$.Phone2',
			Email2		varchar	(50	)	'$.Email2',
			CityKey		int				'$.CityKey'
		)
	End

	if(ISNULL(@PhyAddress,'')<> '')
	Begin
		insert into #PhysicalAddress (AddrKey, AddrName, Address1, Address2,City, 
				State, ZipCode, Country, 
				Website, Phone, Email, Fax, Phone2, Email2, CityKey)
		select AddrKey, AddrName, Address1, Address2,City, State, ZipCode, Country, 
				Website, Phone, Email, Fax, Phone2, Email2, CityKey
		from OpenJson(@PhyAddress,'$')
		with 
		(
			AddrKey		int				'$.AddrKey',
			AddrName	varchar	(255)	'$.Name',
			Address1	varchar	(255)	'$.Address1',
			Address2	varchar	(255)	'$.Address2',
			City		varchar	(255)	'$.City',
			State		varchar	(255)	'$.State',
			ZipCode		varchar	(50	)	'$.Zip',
			Country		char	(3)		'$.Country',
			Website		varchar	(255)	'$.Website',
			Phone		varchar	(20	)	'$.Phone',
			Email		varchar	(255)	'$.Email',
			Fax			varchar	(20	)	'$.Fax',
			Phone2		varchar	(20	)	'$.Phone2',
			Email2		varchar	(50	)	'$.Email2',
			CityKey		int				'$.CityKey'
		)
	End

	if(ISNULL(@ContactNames,'')<> '')
	Begin
		insert into #DriverContacts (DriverContactKey, DriverKey, ContactKey, ContactName, 
			ContactDesignation, ContactNumber, ContactEmail)
		select DriverContactKey, DriverKey, ContactKey, ContactName, 
			ContactDesignation, ContactNumber, ContactEmail
		from OpenJson(@ContactNames,'$')
		with 
		(
			DriverContactKey	int				'$.DriverContactKey',
			DriverKey			int				'$.DriverKey',
			ContactKey			int				'$.ContactKey',
			ContactName			varchar(100)	'$.ContactName',
			ContactDesignation	varchar(100)	'$.ContactDesignation',
			ContactNumber		varchar(100)	'$.ContactNumber',
			ContactEmail		varchar(100)	'$.ContactEmail'
		)
	End

	if(isnull(@MoveTypes,'') <> '')
	Begin
		insert into #DriverMoveType (DriverKey, MoveTypeKey, IsSelected )
		select * from OpenJSON(@MoveTypes, '$')
		with (
			DriverKey	int			'$.DriverKey',
			MoveTypeKey	smallint	'$.MoveTypeKey',
			IsSelected	bit			'$.IsSelected'
		)
	end

	if(isnull(@FTC,'') <> '')
	Begin
		insert into #DriverFTC (DriverKey, FTCKey, IsSelected )
		select * from OpenJSON(@FTC, '$')
		with (
			DriverKey	int			'$.DriverKey',
			FTCKey	smallint		'$.FTCKey',
			IsSelected	bit			'$.IsSelected'
		)
	end

	if(isnull(@LLC,'') <> '')
	Begin
		insert into #DriverLLC (DriverKey, LLCKey, IsSelected )
		select * from OpenJSON(@LLC, '$')
		with (
			DriverKey	int			'$.DriverKey',
			LLCKey	smallint		'$.LLCKey',
			IsSelected	bit			'$.IsSelected'
		)
	end

	--select * from #Driver
	--Select * from #BillingAddress
	--select * from #PhysicalAddress
	--Select * from #DriverContacts
	--Select * from #DriverMoveType
	--Select * from #DriverFTC
	--Select * from #DriverLLC

	declare @AddKey int = 0, @PhyAddrKey	int = 0
	select @AddKey = AddrKey from #BillingAddress
	select @PhyAddrKey = AddrKey from #PhysicalAddress

	begin transaction
	begin try

		if(ISNULL(@AddKey,0) = 0)
		Begin
			insert into Address(AddrName, Address1, Address2,City, State, ZipCode, Country, 
					Website, Phone, Email, Fax, Phone2, Email2, CityKey)
			select @addrName, Address1, Address2,City, State, ZipCode, Country, 
					Website, Phone, Email, Fax, Phone2, Email2, CityKey 
			from #BillingAddress
			select @AddKey = SCOPE_IDENTITY()
			update #Driver set AddrKey = @AddKey
		end
		else
		begin
			update #Driver set AddrKey = (select AddrKey from #BillingAddress)
			update #Driver set PhysicalAddrKey = (select AddrKey from #PhysicalAddress)

			update A set
			AddrName	=	@addrName,
			Address1	=	B.Address1,
			Address2	=	B.Address2,
			City		=	B.City	,
			State		=	B.State	,
			ZipCode		=	B.ZipCode,	
			Country		=	B.Country,	
			Website		=	B.Website,	
			Phone		=	B.Phone	,
			Email		=	B.Email	,
			Fax			=	B.Fax	,	
			Phone2		=	B.Phone2	,
			Email2		=	B.Email2	,
			CityKey		=	B.CityKey	
			From Address A
			inner join #BillingAddress B on A.AddrKey = B.AddrKey

			
		end	

		if(ISNULL(@PhyAddrKey,0) = 0)
		Begin
			insert into Address(AddrName, Address1, Address2,City, State, ZipCode, Country, 
					Website, Phone, Email, Fax, Phone2, Email2, CityKey)
			select @addrName, Address1, Address2,City, State, ZipCode, Country, 
					Website, Phone, Email, Fax, Phone2, Email2, CityKey 
			from #PhysicalAddress
			select @PhyAddrKey = SCOPE_IDENTITY()
			update #Driver set PhysicalAddrKey = @PhyAddrKey
		end
		else
		begin
			update A set
			AddrName	=	@addrName,
			Address1	=	B.Address1,
			Address2	=	B.Address2,
			City		=	B.City	,
			State		=	B.State	,
			ZipCode		=	B.ZipCode,	
			Country		=	B.Country,	
			Website		=	B.Website,	
			Phone		=	B.Phone	,
			Email		=	B.Email	,
			Fax			=	B.Fax	,	
			Phone2		=	B.Phone2	,
			Email2		=	B.Email2	,
			CityKey		=	B.CityKey	
			From Address A
			inner join #PhysicalAddress B on A.AddrKey = B.AddrKey
		end	

		if(ISNULL(@DriverKey,0) = 0)
		Begin
			insert into Driver( DriverID, FirstName, LastName, AddrKey,CarrierKey, 
			StatusKey, ContactNo, OrgName, OrgZipCode, OrgCity, OrgState, 
			OrgCountry, 
			PhysicalAddrKey, TelePhone, BusinessNumber, CellNumber, FaxNumber, 
			EmailAddress, DOTNumber, MCNumber, TaxIDNumber, YearsUnderCurrentName, 
			FactoringCompany, InsuranceCompany, PolicyNumber, 
			PolicyExpDate, 	insuranceAgentName, InsuranceAgentNumber, StatusDate, PayTypeKey,NoOfTrucks,IsActive,IsDelete, MarketLocationKey, TruckTypeKey
			)
			select  DriverID, FirstName, LastName, AddrKey,CarrierKey, 
			StatusKey, ContactNo, OrgName, OrgZipCode, OrgCity, OrgState, 
			OrgCountry, 
			PhysicalAddrKey, TelePhone, BusinessNumber, CellNumber, FaxNumber, 
			EmailAddress, DOTNumber, MCNumber, TaxIDNumber, YearsUnderCurrentName, 
			FactoringCompany, InsuranceCompany, PolicyNumber, 
			PolicyExpDate, 	insuranceAgentName, InsuranceAgentNumber, GetDate(), PayTypeKey,NoOfTrucks,1,0, MarketLocationKey,TruckTypeKey
			from #Driver

			set @DriverKey = SCOPE_IDENTITY();
			update #Driver set DriverKey = @DriverKey
			update #DriverContacts set DriverKey = @DriverKey
			update #DriverMoveType set DriverKey = @DriverKey
			update #DriverFTC set DriverKey = @DriverKey
			update #DriverLLC set DriverKey = @DriverKey

			set @Status = 1
			-- set @Output = 1
			SET @Reason = 'Record Created Successfully'
		end
		else
		begin
			update A set
			DriverID				=	D.DriverID, 
			FirstName				=	D.FirstName, 
			LastName				=	D.LastName, 
			AddrKey					=	D.AddrKey,
			CarrierKey				=	D.CarrierKey, 
			StatusKey				=	D.StatusKey, 
			ContactNo				=	D.ContactNo, 
			OrgName					=	D.OrgName, 
			OrgZipCode				=	D.OrgZipCode, 
			OrgCity					=	D.OrgCity, 
			OrgState				=	D.OrgState, 
			OrgCountry				=	D.OrgCountry, 
			PhysicalAddrKey			=	D.PhysicalAddrKey, 
			TelePhone				=	D.TelePhone, 
			BusinessNumber			=	D.BusinessNumber, 
			CellNumber				=	D.CellNumber, 
			FaxNumber				=	D.FaxNumber, 
			EmailAddress			=	D.EmailAddress, 
			DOTNumber				=	D.DOTNumber, 
			MCNumber				=	D.MCNumber, 
			TaxIDNumber				=	D.TaxIDNumber, 
			YearsUnderCurrentName	=	D.YearsUnderCurrentName, 
			FactoringCompany		=	D.FactoringCompany, 
			InsuranceCompany		=	D.InsuranceCompany, 
			PolicyNumber			=	D.PolicyNumber, 
			PolicyExpDate			=	D.PolicyExpDate, 	
			insuranceAgentName		=	D.insuranceAgentName, 
			InsuranceAgentNumber	=	D.InsuranceAgentNumber,
			PayTypeKey				=	D.PayTypeKey,
			NoOfTrucks				=   D.NoOfTrucks,
		--	IsActive                =   D.IsActive
			--IsDelete				=   D.IsDelete	
			MarketLocationKey		=	D.MarketLocationKey ,
			TruckTypeKey			=	D.TruckTypeKey
			From Driver A
			inner join #Driver D on A.DriverKey = D.DriverKey
			--where A.DriverKey = @DriverKey
			 
			set @Status = 1
			-- set @Output = 1
			SET @Reason = 'Record Updated Successfully'
		end

		insert into DriverContacts(DriverKey, ContactName, ContactDesignation, ContactNumber, ContactEmail)
		select @DriverKey, ContactName, ContactDesignation, ContactNumber, ContactEmail
		from #DriverContacts
		where isnull(DriverKey,0) = 0

		update A set
			 ContactName		=	B.ContactName, 
			 ContactDesignation	=	B.ContactDesignation, 
			 ContactNumber		=	B.ContactNumber, 
			 ContactEmail		=	B.ContactEmail
		from DriverContacts A
		Inner join #DriverContacts B on A.DriverContactKey = B.DriverContactKey

		update A set
			IsSelected = B.IsSelected,
			UpdateDate = GETDATE(),
			UpdateUser = @UserKey
		from Driver_MoveType A 
		inner join #DriverMoveType B on A.DriverKey = B.DriverKey and A.MoveTypeKey = B.MoveTypeKey
		where A.IsSelected <> B.IsSelected

		insert into driver_MoveType(DriverKey, MoveTypeKey, IsSelected,CreateDate, CreateUser)
		select a.DriverKey, a.MoveTypeKey, a.IsSelected, GetDate(), @UserKey 
			from #DriverMoveType A
		left join Driver_MoveType b on A.DriverKey = b.DriverKey and A.MoveTypeKey = b.MoveTypeKey
		where ISNULL(b.MoveTypeKey,0) = 0

		update A set
			IsSelected = B.IsSelected,
			UpdateDate = GETDATE(),
			UpdateUser = @UserKey
		from Driver_FTC A 
		inner join #DriverFTC B on A.DriverKey = B.DriverKey and A.FTCKey = B.FTCKey
		where A.IsSelected <> B.IsSelected

		insert into driver_FTC(DriverKey, FTCKey, IsSelected,CreateDate, CreateUser)
		select a.DriverKey, a.FTCKey, a.IsSelected, GetDate(), @UserKey 
			from #DriverFTC A
		left join Driver_FTC b on A.DriverKey = b.DriverKey and A.FTCKey = b.FTCKey
		where ISNULL(b.FTCKey,0) = 0

		update A set
			IsSelected = B.IsSelected,
			UpdateDate = GETDATE(),
			UpdateUser = @UserKey
		from Driver_LLC A 
		inner join #DriverLLC B on A.DriverKey = B.DriverKey and A.LLCKey = B.LLCKey
		where A.IsSelected <> B.IsSelected

		insert into driver_LLC(DriverKey, LLCKey, IsSelected,CreateDate, CreateUser)
		select a.DriverKey, a.LLCKey, a.IsSelected, GetDate(), @UserKey 
			from #DriverLLC A
		left join Driver_LLC b on A.DriverKey = b.DriverKey and A.LLCKey = b.LLCKey
		where ISNULL(b.LLCKey,0) = 0

		
		Commit Transaction
	End Try
	Begin Catch
	Rollback Transaction
    SET @Status = 0
    -- SET @Output = 0
    SET @Reason = 'Error: ' + ERROR_MESSAGE() 
	End Catch
END


---SELECT * FROM DRIVER WHERE DRIVERKEY=725