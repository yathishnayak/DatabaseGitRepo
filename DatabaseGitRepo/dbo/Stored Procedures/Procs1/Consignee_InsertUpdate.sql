
CREATE proc [dbo].[Consignee_InsertUpdate]
(
	@ConsigneeKey	int		output,
	@JsonData		varchar(max),
	@UserKey		int,
	@Output			bit = 0 output,
	@Reason			varchar(100) = '' output
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@JsonData,'') = '')
	BEGIN
		SET @Output = 0
		SET @Reason = 'Consignee Data not received'
		set @ConsigneeKey = 0
		return;
	END

	declare @cnt int = 0
	if(@ConsigneeKey >0)
	begin
		select @cnt = COUNT(1) from Consignee where consigneekey = @ConsigneeKey
		if(isnull(@cnt,0) = 0)
		begin
			SET @Output = 0
			SET @Reason = 'Consignee not exists'
			set @ConsigneeKey = 0
			return;
		end
	end

	create table #Consignee
	(
		ConsigneeID		varchar(50),
		Name			varchar(500),
		AddrKey			int,
		CustKey			int,
		StatusKey		smallint,
		CompanyKey		smallint,
		CSRKey			int,
		CSRManagerKey	int
	)



	insert into #Consignee ( ConsigneeID, Name, AddrKey, CustKey, StatusKey, CompanyKey, CSRKey, CSRManagerKey)
	select ConsigneeID, Name, AddrKey, CustKey, StatusKey, CompanyKey, CSRKey, CSRManagerKey
	from OpenJson(@JsonData,'$')
	with (
		ConsigneeID		varchar(50)		'$.ConsigneeID',
		Name			varchar(500)	'$.Name',
		AddrKey			int				'$.AddrKey',
		CustKey			int				'$.CustKey',
		StatusKey		smallint		'$.StatusKey',
		CompanyKey		smallint		'$.CompanyKey',
		CSRKey			int				'$.CSRKey',
		CSRManagerKey	int				'$.CSRManagerKey'
	)
	
	declare @addressData nvarchar(max)
	select @addressData = Address
	from OpenJson(@JsonData,'$')
	with (
		Address			nvarchar(max)	'$.Address' as JSON
	)

	set @cnt=0
	select @cnt = COUNT(1) from #Consignee
	if(ISNULL(@cnt,0) = 0)
	begin
		SET @Output = 0
		SET @Reason = 'Consignee Data not exists'
		set @ConsigneeKey = 0
		return;
	end

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
		SET @Reason = 'Consignee Address not exists'
		set @ConsigneeKey = 0
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
		SET @Reason = 'Consignee Address Data not exists'
		set @ConsigneeKey = 0
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
			update #Consignee set AddrKey = @AddrKey
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

		IF(ISNULL(@ConsigneeKey,0) = 0)
		BEGIN
			INSERT INTO Consignee (ConsigneeID, Name, AddrKey, CustKey, StatusKey, CompanyKey, CreateUserKey, CreateDate,
			CSRKey, CSRManagerKey)
			SELECT ConsigneeID, Name, AddrKey, CustKey, StatusKey, CompanyKey, @UserKey, GETDATE(), CSRKey, CSRManagerKey 
			FROM #Consignee
			Set @ConsigneeKey = SCOPE_IDENTITY()
		END
		else
		BEGIN
			UPDATE C SET
				ConsigneeID 	=B.ConsigneeID ,
				Name			=B.Name		,
				AddrKey			=B.AddrKey	,	
				CustKey			=B.CustKey	,	
				StatusKey		=B.StatusKey	,
				CompanyKey		=B.CompanyKey	,
				UpdateUserKey	= @UserKey,
				UpdateDate		= GETDATE(),
				CSRKey			= B.CSRKey,
				CSRManagerKey	= B.CSRManagerKey
			FROM CONSIGNEE C
			INNER JOIN #Consignee B ON C.ConsigneeKey = B.CompanyKey
		END
		COMMIT TRANSACTION
		SET @Output = 1
		SET @Reason = 'Consignee Saved Successfully'
	END TRY
	BEGIN CATCH
		print error_Message()
		SET @Output = 0
		SET @Reason = 'Technical Error'
		Rollback Transaction
	END CATCH
END
