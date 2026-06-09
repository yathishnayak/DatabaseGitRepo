

create proc [dbo].[InsertUpdate_CustomerAddress]
(
	@CustomerKey	int = 0,
	@JsonData		nvarchar(max) = '',
	@Output			bit = 0 OUTPUT,
	@Reason			varchar(100) = '' OUTPUT
)
as
Begin
	set nocount on
	set fmtonly off

	Declare @AddrKey	int = 0

	IF(ISNULL(@JsonData,'') = '')
	BEGIN
		SET @Output = 0
		SET @Reason = 'Customer Address Data not received'
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

	insert into #address(AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, 
		Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey)
	select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, 
		Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey
	from OpenJson(@JsonData,'$')
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
		CityKey		int				'$.CityKey',
		AddressType	varchar(50)		'$.AddressType',
		CustomerKey		int			'$.CustomerKey',
		MarketLocationKey	int		'$.MarketLocationKey'
	)

	begin try 
		INSERT INTO Address(AddrName, Address1, Address2, City, State, ZipCode, Country, 
			Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey)
		select AddrName, Address1, Address2, City, State, ZipCode, Country, 
			Website, Phone, Email, Fax,Phone2 ,Email2 ,CityKey
		from #address
		set @AddrKey = SCOPE_IDENTITY()

		insert into CustomerAddress(CustKey, AddrKey, AddrType, MarketLocationKey)
		select @CustomerKey, @AddrKey, AddressType, MarketLocationKey from #address
		set @Output = 1
		set @Reason = 'Saved Successfully'
	end try
	begin catch
		set @Output = 0
		set @Reason = ERROR_MESSAGE();
	end catch
End
