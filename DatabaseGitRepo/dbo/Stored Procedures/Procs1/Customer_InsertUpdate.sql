
CREATE proc [dbo].[Customer_InsertUpdate]
(
	@CustomerKey		int		output,
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
		SET @Reason = 'Customer Data not received'
		set @CustomerKey = 0
		return;
	END

	declare @cnt int = 0
	if(@CustomerKey >0)
	begin
		select @cnt = COUNT(1) from Customer where CustKey = @CustomerKey
		if(isnull(@cnt,0) = 0)
		begin
			SET @Output = 0
			SET @Reason = 'Customer not exists'
			set @CustomerKey = 0
			return;
		end
	end

	create table #Customer
	(
		CustKey			int,
		CustID			varchar(100),
		CustName		varchar(100),
		AddrKey			int,
		CustomerGroup	smallint,
		StatusKey		smallint,
		CreditCheck		bit,
		CreditLimit		decimal(18,2),
		CreditStatus	smallint,
		Ach_Required	bit,
		PaymentTermsKey	smallint,
		CompanyKey		smallint,
		BillToAddrKey	int,
		IsFactored		bit,
		Notes			varchar(1000),
		SalesPersonKey	int,
		CSRKey			int,
		CSRManagerKey	int
	)

	insert into #Customer (CustKey, CustID, CustName, AddrKey, CustomerGroup, StatusKey,CreditCheck, CreditLimit,
			CreditStatus, Ach_Required, PaymentTermsKey, CompanyKey,BillToAddrKey, IsFactored, Notes,
			SalesPersonKey,CSRKey, CSRManagerKey)
	select @CustomerKey, CustID, CustName, AddrKey, CustomerGroup, StatusKey,CreditCheck, CreditLimit,
			CreditStatus, Ach_Required, PaymentTermsKey, CompanyKey,BillToAddrKey, IsFactored, Notes,
			SalesPersonKey, CSRKey, CSRManagerKey
	from OpenJson(@JSONData,'$')
	with (
		CustKey			int				'$.CustKey',
		CustID			varchar(100)	'$.CustId',
		CustName		varchar(100)	'$.CustName',
		AddrKey			int				'$.AddrKey',
		CustomerGroup	smallint		'$.CustomerGroup',
		StatusKey		smallint		'$.StatusKey',
		CreditCheck		bit				'$.CreditCheck',
		CreditLimit		decimal(18,2)	'$.CreditLimit',
		CreditStatus	smallint		'$.CreditStatus',
		Ach_Required	bit				'$.achrequired',
		PaymentTermsKey	smallint		'$.paymentterms',
		CompanyKey		smallint		'$.CompanyKey',
		BillToAddrKey	int				'$.BillToAddrKey',
		IsFactored		bit				'$.IsFactored',
		Notes			varchar(1000)	'$.Notes',
		SalesPersonKey	int				'$.SalesPersonKey',
		CSRKey			int				'$.CSRKey',
		CSRManagerKey	int				'$.CSRManagerKey'
	)

	set @cnt=0
	select @cnt = COUNT(1) from #Customer
	if(ISNULL(@cnt,0) = 0)
	begin
		SET @Output = 0
		SET @Reason = 'Customer Data not exists'
		set @CustomerKey = 0
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

	Create table #billtoaddress
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
		SET @Reason = 'Customer Address not exists'
		set @CustomerKey = 0
		return;
	end

	if(ISNULL(@BillToaddressData,'') = '')
	begin
		SET @Output = 0
		SET @Reason = 'Customer Bill To Address not exists'
		set @CustomerKey = 0
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
	insert into #billtoaddress(AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, 
		Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey)
	select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, 
		Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey
	from OpenJson(@billtoaddressData,'$')
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
		SET @Reason = 'Customer Address Data not exists'
		set @CustomerKey = 0
		return;
	end

	set @cnt=0
	select @cnt = COUNT(1) from #billtoaddress
	if(ISNULL(@cnt,0) = 0)
	begin
		SET @Output = 0
		SET @Reason = 'Customer Bill to Address Data not exists'
		set @CustomerKey = 0
		return;
	end

	DECLARE @AddrKey	int = 0,
			@BillToAddrKey int = 0
	select @AddrKey = AddrKey from #address
	select @BillToAddrKey = AddrKey from #billtoaddress
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
			update #Customer set AddrKey = @AddrKey
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


		if(ISNULL(@BillToAddrKey,0) = 0)
		Begin
			INSERT INTO Address(AddrName, Address1, Address2, City, State, ZipCode, Country, 
				Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey)
			select AddrName, Address1, Address2, City, State, ZipCode, Country, 
				Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey
			from #billtoaddress
			set @AddrKey = SCOPE_IDENTITY()
			update #Customer set AddrKey = @AddrKey
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
			INNER JOIN #billtoaddress B ON A.AddrKey = B.AddrKey
		END


		IF(ISNULL(@CustomerKey,0) = 0)
		BEGIN
			INSERT INTO Customer(CustID, CustName, AddrKey, CustomerGroup, StatusKey, StatusDate,CreditCheck, CreditLimit,
			CreditStatus, Ach_Required, PaymentTermsKey, CompanyKey,BillToAddrKey, IsFactored, Notes,
			CSRKey, CSRManagerKey, SalesPersonKey)
			SELECT CustID, CustName, AddrKey, CustomerGroup, StatusKey, GetDate(),CreditCheck, CreditLimit,
			CreditStatus, Ach_Required, PaymentTermsKey, CompanyKey,BillToAddrKey, IsFactored, Notes,
			CSRKey, CSRManagerKey, SalesPersonKey
			FROM #Customer
			Set @CustomerKey = SCOPE_IDENTITY()
		END
		else
		BEGIN
			UPDATE C SET
				CustKey			=	B.CustKey,
				CustID			=	B.CustID,
				CustName		=	B.CustName,
				AddrKey			=	B.AddrKey,
				CustomerGroup	=	B.CustomerGroup,
				StatusKey		=	B.StatusKey,
				StatusDate		=	GETDATE(),
				CreditCheck		=	B.CreditCheck,
				CreditLimit		=	B.CreditLimit,
				CreditStatus	=	B.CreditStatus,
				Ach_Required	=	B.Ach_Required,
				PaymentTermsKey	=	B.PaymentTermsKey,
				CompanyKey		=	B.CompanyKey,
				BillToAddrKey	=	B.BillToAddrKey,
				IsFactored		=	B.IsFactored,
				Notes			=	B.Notes,
				CSRKey			=   B.CSRKey,
				CSRManagerKey	=	B.CSRManagerKey,
				SalesPersonKey	=	B.SalesPersonKey
				
			FROM Customer C
			INNER JOIN #Customer B ON C.CustKey = B.CustKey
		END
		COMMIT TRANSACTION
		SET @Output = 1
		SET @Reason = 'Customer Saved Successfully'
	END TRY
	BEGIN CATCH
		print error_Message()
		SET @Output = 0
		SET @Reason = 'Technical Error'
		Rollback Transaction
	END CATCH
END
