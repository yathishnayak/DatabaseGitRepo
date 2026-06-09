


CREATE proc [dbo].[Broker_InsertUpdate]
(
	@BrokerKey		int		output,
	@JSONData			nvarchar(max),
	@Output				bit = 0 output,
	@Reason				varchar(100) = '' outPut
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@JsonData,'') = '')
	BEGIN
		SET @Output = 0
		SET @Reason = 'Broker Data not received'
		set @BrokerKey = 0
		return;
	END

	declare @cnt int = 0
	if(@BrokerKey >0)
	begin
		select @cnt = COUNT(1) from Broker where BrokerKey = @BrokerKey
		if(isnull(@cnt,0) = 0)
		begin
			SET @Output = 0
			SET @Reason = 'Broker not exists'
			set @BrokerKey = 0
			return;
		end
	end

	create table #Broker
	(
		BrokerKey	int,				
		BrokerID	varchar(20),		
		BrokerName	varchar(255),	
		AddrKey		int	,			
		StatusKey	smallint,
		StatusDate	datetime,		
		CompanyKey	smallint,		
		IsActive	bit,				
		IsDelete	bit				
	)

	insert into #Broker (BrokerKey, BrokerID, BrokerName, AddrKey, CreateDate, StatusKey, StatusDate, CompanyKey, IsActive, IsDelete)
	select @BrokerKey, BrokerID, BrokerName, AddrKey, GETDATE(), StatusKey, StatusDate, CompanyKey, IsActive, IsDelete
	from OpenJson(@JSONData,'$')
	with (
		BrokerKey	int				'$.BrokerKey',
		BrokerID	varchar(20)		'$.BrokerID',
		BrokerName	varchar(255)	'$.BrokerName',
		AddrKey		int				'$.AddrKey',
		StatusKey	smallint		'$.StatusKey',
		StatusDate	datetime		'$.StatusDate',
		CompanyKey	smallint		'$.CompanyKey',
		IsActive	bit				'$.IsActive',
		IsDelete	bit				'$.IsDelete'
		)

	set @cnt=0
	select @cnt = COUNT(1) from #Broker
	if(ISNULL(@cnt,0) = 0)
	begin
		SET @Output = 0
		SET @Reason = 'Broker Data not exists'
		set @BrokerKey = 0
		return;
	end

	declare @addressData nvarchar(max), @BillToaddressData nvarchar(max)
	select @addressData = Address, @BillToaddressData = BillToaddress
	from OpenJson(@JsonData,'$')
	with (
		Address			nvarchar(max)	'$.Address' as JSON,
		BillToaddress	nvarchar(max)	'$.BillToAddress' as JSON
	)

	Create table #address
	(
		AddrKey		int,
		AddrName	varchar(255),
		Address1	varchar(255),
		Address2	varchar(255),
		City		varchar(255),
		State		varchar(255),
		ZipCode		varchar(50),
		Country		char(3),
		Website		varchar(255),
		Phone		varchar(20),
		Email		varchar(255),
		Fax			varchar(20),
		Phone2		varchar(20),
		Email2		varchar(50),
		CityKey		int
	)

	
	if(ISNULL(@addressData,'') = '')
	begin
		SET @Output = 0
		SET @Reason = 'Broker Address not exists'
		set @BrokerKey = 0
		return;
	end

	

	insert into #address(AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, 
		Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey)
	select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, 
		Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey
	from OpenJson(@addressData,'$')
	With(
		AddrKey		int				'$.AddrKey',
		AddrName	varchar(255)	'$.Name',
		Address1	varchar(255)	'$.Address1',
		Address2	varchar(255)	'$.Address2',
		City		varchar(255)	'$.City',
		State		varchar(255)	'$.State',
		ZipCode		varchar(50)		'$.Zip',
		Country		char(3)			'$.Country',
		Website		varchar(255)	'$.Website',
		Phone		varchar(20)		'$.Phone',
		Email		varchar(255)	'$.Email',
		Fax			varchar(20)		'$.Fax',
		Phone2		varchar(20)		'$.Phone2',
		Email2		varchar(50)		'$.Email2',
		CityKey		int				'$.CityKey'
	)
	

	set @cnt=0
	select @cnt = COUNT(1) from #address
	if(ISNULL(@cnt,0) = 0)
	begin
		SET @Output = 0
		SET @Reason = 'Broker Address Data not exists'
		set @BrokerKey = 0
		return;
	end


	DECLARE @AddrKey	int = 0
	select @AddrKey = AddrKey from #address

	BEGIN TRANSACTION
	BEGIN TRY
		if(ISNULL(@AddrKey,0) = 0)
		Begin
			INSERT INTO Address(AddrName, Address1, Address2, City, State, ZipCode, Country, 
				Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey)
			select AddrName, Address1, Address2, City, State, ZipCode, Country, 
				Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey
			from #address
			set @AddrKey = SCOPE_IDENTITY()
			update #Broker set AddrKey = @AddrKey
		end
		ELSE
		BEGIN	
			UPDATE A SET
				AddrName	=B.AddrName,
				Address1	=B.Address1,
				Address2	=B.Address2,
				City		=B.City	,
				State		=B.State	,
				ZipCode		=B.ZipCode,	
				Country		=B.Country,	
				Website		=B.Website,	
				Phone		=B.Phone	,
				Email		=B.Email	,
				Fax			=B.Fax	,	
				Phone2		=B.Phone2	,
				Email2		=B.Email2	,
				CityKey		=B.CityKey	
			FROM Address A
			INNER JOIN #address B ON A.AddrKey = B.AddrKey
		END


		IF(ISNULL(@BrokerKey,0) = 0)
		BEGIN
			INSERT INTO Broker(BrokerID, BrokerName, AddrKey, CreateDate, StatusKey, StatusDate, CompanyKey, IsActive, IsDelete)
			SELECT BrokerID, BrokerName, AddrKey, GETDATE(), StatusKey, GETDATE(), CompanyKey, IsActive, IsDelete
			FROM #Broker
			Set @BrokerKey = SCOPE_IDENTITY()
		END
		else
		BEGIN
			UPDATE C SET
				BrokerID	=	B.BrokerID,	
				BrokerName	=	B.BrokerName,	
				AddrKey		=	B.AddrKey,		
				StatusKey	=	B.StatusKey,	
				StatusDate	=	B.StatusDate,	
				CompanyKey	=	B.CompanyKey,	
				IsActive	=	B.IsActive	
			FROM Broker C
			INNER JOIN #Broker B ON C.BrokerKey = B.BrokerKey
		END
		COMMIT TRANSACTION
		SET @Output = 1
		SET @Reason = 'Broker Saved Successfully'
	END TRY
	BEGIN CATCH
		print error_Message()
		SET @Output = 0
		SET @Reason = 'Technical Error'
		Rollback Transaction
	END CATCH
END
