--select * from Driver_MoveType
/*
declare @DriverKey	int = 0, @JSONText	nvarchar(max) = '',@UserKey	int = 0,@Output	Bit = 0, @Reason VARCHAR(50) = ''
set @DriverKey = 6
set @JSONText = '{"DriverKey":6,"DriverId":"06-RM","FirstName":"Rigoberto","LastName":"Moreno","Address":{"Address1":"7777 Valley View Ave. APT B207","Address2":null,"AddrName":"7777 Valley View Ave. APT B207","City":"La Palma","State":"CA","Zip":"90623","Phone":"7142700574","Phone2":null,"Fax":null,"Email":null,"Email2":null,"Country":"USA","Website":null,"AddrKey":1345,"Name":null,"AddressType":null,"CustomerKey":0,"OrderTypeKey":0,"LegKey":0,"LoationType":null},"PhyAddress":{"Address1":"sdgsgd","Address2":null,"AddrName":null,"City":"Adah","State":"PA","Zip":"15410","Phone":null,"Phone2":null,"Fax":null,"Email":null,"Email2":null,"Country":"USA","Website":null,"AddrKey":0,"Name":null,"AddressType":null,"CustomerKey":0,"OrderTypeKey":0,"LegKey":0,"LoationType":null},"CarrierKey":null,"DriversLicenseNo":null,"LicenseExpiryDate":null,"CreateDate":"2020-10-15T14:05:32.33","Status":null,"StatusKey":1,"StatusDate":"2021-06-28T13:09:21.943","VendorKey":null,"CompanyKey":1,"HireDate":"2016-09-09T05:30:00","Plate":"9E36964","YearMake":"2009/FRHT","VINId":"1FUJA6CK99DAH5813","RFID":"34698608","ContactNo":"(714)270-0574","OrgName":null,"OrgZipCode":null,"OrgCity":null,"FuelCardNo":null,"OrgState":null,"OrgCountry":null,"LastUpdateDate":"2021-06-28T13:09:21.943","CreateUserKey":512,"LastUpdateUserKey":512,"driverFiles":[],"UploadedDocumentKeyList":null,"AllowdLicenses":null,"TractorLicenseNo":null,"AppKey":"A176049F-C210-46DA-961C-07D1BC36E5D5","AppKeyInt":0,"Token":"MfCyhnPjS-E2k4jnWKx4Ov2bIbkHdF5jEtQKCh5i8yP1eLAk8Upl_ZrjAppsLlNsNqmaILFng2uC91FW9Nq4dIVw4y0a1ngDKxC6gA5ymsDmFij9pgVRhvLmF8q8ucELDW6YXNG-KKur7xwBfVqW-Hg21DvvR9KX_8n-h9vH2KzzJlXc34zOek_fYMIX5fiTEErbvXkF7Su4tJ2RNaaCiNjTASYAamRQCmdnIRBGMk3OJ3vNuYYMlbsrmvCPIxPORzKSVhs9K-qbN2_HEb48Fr856pEeZbRtMLUS946-rtlQhrxSALfDOqeAlMVS_v0gQ-dqhUCNdB4x8wjFrBVDaGb7H2f6eQ-IntbiPTdQDrdSbW8JtVahNHAoMAOJqaWlvp85iLcJReDHVBG1UZgwpVu4hc-lSEMU7euQAKSYpnbUZR73Q2FAxp3hDmdoizTkq4Ax7NbyUUDE1fNVPldxR29Ta1K8G0_f9UKHtds3ZY0mJZNqavJyxBVqiz8MTwslGSTEEIXCpzwSFqptU31fNBdIO7_MNzCtZD1inteNgusvuqVXtQTJKzEmlT2M3y-0-7BjORKMjFvP5jxRGk1gd7XPEnAEHKVd67ttySmFAZTTfwPaVC6nlVcFt-nGklYu_s-rqknEY4ab7eFE1v0XO1Z7VYWc9afbfgeIW3u7OG98Ak834t1RyptNPhHi7tXuR5QxnY-j30mvjKojOY7pX_at0SI5NSJgocUk3HTW2W-iqjNg9L68K-4Y1_I3dsyhMUWlTiZcj9FIkydiMe2OqEzv830WlWs0IHySqIZxLV_fJ7MeoNSgmev_u-WSIpjWUgJrc0hyQiQZ_u5h7q4ZuhmnIZDY1IXj73cJ_3iigNeVN2v_L4ib3RPLcrxXqGXaoEsTPCUbeQ5CzrvM437xldDdrbDxYik3WMz8PCR22T2mGYmgkWqbOHBMTU9S0e_P9-zzcFsImHkvWfoQw2I4iVOECkfYriZFkwbhPA6_HOZckPxAqJbJYQL_YOW0BJDqBTS2ElghTV6l7vr9uhjxlP3mGtjxCV3AbEuRaGfinREPtAEMORk9vf72HW7XiI5xO2jc8CuT_jeWxICCHAZSEyQOEM3gr4qkESSqnQ7rKHXk5s7Is7cuagCPVzOZ6uI0SFFnEiU5HdmLR75w-1BHGxOgxf50SQfQEqdwC5pBZACxVeOQlXDx8juY9q90uCUWlZO1V7A1-WhBdx1Ef3KWGaUk3m1MiWxgXB3aLR_UxWsHMM2zmr514FmR8nM8NiEJ","PhysicalAddrKey":0,"TelePhone":null,"BusinessNumber":null,"CellNumber":null,"FaxNumber":null,"EmailAddress":null,"DOTNumber":null,"MCNumber":null,"TaxIDNumber":null,"YearsUnderCurrentName":0,"FactoringCompany":null,"InsuranceCompany":null,"PolicyNumber":null,"PolicyExpDate":"0001-01-01T00:00:00","insuranceAgentName":null,"InsuranceAgentNumber":null,"UserKey":512,"ContactNames":[],"BillingAddress":null,"PhysicalAddress":null,"PayTypeKey":1,"PayTypeName":null,"StatusName":null,"NoOfTrucks":0,"ExpiryPeriod":"Expired","ExpiryDays":365,"ExpiryCode":"rgb(139, 0, 0)","DriverMoveTypeList":[{"DriverKey":6,"MoveTypeKey":1,"MoveTypeName":"OTR","IsSelected":true,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0},{"DriverKey":6,"MoveTypeKey":2,"MoveTypeName":"PORT","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0}],"DriverFTCList":[{"DriverKey":6,"FTCKey":2,"FTCName":"C-corporation","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0},{"DriverKey":6,"FTCKey":5,"FTCName":"Individual/Sole Proprietor or Single Member LLC","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0},{"DriverKey":6,"FTCKey":3,"FTCName":"Partnership","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0},{"DriverKey":6,"FTCKey":1,"FTCName":"S-corporation","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0},{"DriverKey":6,"FTCKey":4,"FTCName":"Trust/Estate","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0}],"DriverLLCList":[{"DriverKey":6,"LLCKey":2,"LLCName":"C-corporation","IsSelected":true,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0},{"DriverKey":6,"LLCKey":3,"LLCName":"Partnership","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0},{"DriverKey":6,"LLCKey":1,"LLCName":"S-corporation","IsSelected":false,"CreateDate":"0001-01-01T00:00:00","CreateUser":0,"UpdateDate":"0001-01-01T00:00:00","UpdateUser":0}],"OutputType":null}'
set @UserKey = 512
exec DriverCarrier_InsertUpdate @DriverKey output, @JSONText, @UserKey, @Output output, @Reason OUTPUT
select @DriverKey, @Output, @Reason
*/
CREATE Proc [dbo].[DriverCarrier_InsertUpdate]
(
	@DriverKey		int = 0 output,
	@JSONText		nvarchar(max) = '',
	@UserKey		int = 0,
	@Output			Bit = 0 OUTPUT,
	@Reason			VARCHAR(50) = ''OUTPUT
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF
    
 
	IF(   @UserKey = 0 OR @JSONText = '')
	BEGIN
		SET @Output = 0
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
		DrivingLicenseNo			varchar	(50),
		DrivingLicenseExpiryDate	datetime,
		CreateDate					datetime,	
		StatusKey					smallint,
		StatusDate					datetime,
		VendKey						int,
		CompanyKey					smallint,
		HireDate					datetime,
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
	from OpenJson(@JsonText,'$')
	With
	(
		DriverKey					int				'$.DriverKey',
		DriverID					varchar(20)		'$.DriverId',
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
		PayTypeKey					varchar	(100)	'$.PayTypeKey',
		NoOfTrucks					INT				'$.NoOfTrucks',
		IsActive					BIT				'$.IsActive',
		IsDelete					BIT				'$.IsDelete',
		MarketLocationKey			INT				'$.MarketLocationKey',
		TruckTypeKey				INT				'$.TruckTypeKey'

	)
 
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
	from OpenJson(@JsonText, '$')
	with
	(
		BillingAddress	nvarchar(max)	'$.Address' as Json,
		PhysicalAddress nvarchar(max)	'$.PhyAddress' as Json,
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
			where A.DriverKey = @DriverKey
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

		set @Output = 1
		SET @Reason = 'Record Created Successfully'
		Commit Transaction
	End Try
	Begin Catch
		Rollback Transaction
		Print Error_Message()
		SET @Output = 0
		SET @Reason = 'Record Updated Successfully'
	End Catch
END
