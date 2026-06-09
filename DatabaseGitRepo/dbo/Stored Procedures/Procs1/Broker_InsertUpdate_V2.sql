/*
DECLARE @UserKey INT = 951, @JSONString NVARCHAR(MAX),@Status BIT = 0,@Reason VARCHAR(1000), @IsDebug BIT = 1 
SET @JSONString ='{ "IsActive": true, "IsDelete": false, "StatusKey": 1, "CompanyKey": 1, "Address": { "AddrName": "H2", "Address1": "LA", "Address2": "US", "Zip": "65301", "City": "Sedalia", "State": "MO", "Country": "USA", "Phone": "3232", "Fax": "22321", "Website": "www.com", "Email": "abc@gmail.com" }, "BrokerId": "999", "BrokerName": "D2", "MarketLocationKey": "23" }'
 
EXEC [Broker_InsertUpdate_V2] @UserKey, @JSONString, @Status OUTPUT, @Reason OUTPUT, @IsDebug
SELECT @Status Status, @Reason Reason 
*/

CREATE PROCEDURE [dbo].[Broker_InsertUpdate_V2]
(
	@UserKey	INT,
	@JSONString	NVARCHAR(MAX) = '',
	@Status		BIT OUTPUT,
	@Reason		NVARCHAR(MAX) OUTPUT,
	@IsDebug	BIT = 0
)
as
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF(ISNULL(@JSONString,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'JSONString cannot be empty'
		return;
	END

	DECLARE @BrokerKey INT = 0,
			@BrokerName varchar(20) = '';

	create table #Broker
	(
		BrokerKey			int,				
		BrokerID			varchar(20),		
		BrokerName			varchar(255),	
		AddrKey				int	,
		CreateDate			datetime,
		StatusKey			smallint,
		StatusDate			datetime,		
		CompanyKey			smallint,		
		IsActive			bit,				
		IsDelete			bit,
		MarketLocationKey   int
	)

	insert into #Broker (BrokerKey, BrokerID, BrokerName, AddrKey, CreateDate, StatusKey, StatusDate, CompanyKey, IsActive, IsDelete, MarketLocationKey)
	select BrokerKey, BrokerID, BrokerName, AddrKey, GETDATE(), StatusKey, GETDATE(), CompanyKey, IsActive, IsDelete, MarketLocationKey
	from OpenJson(@JSONString,'$')
	with (
		BrokerKey			int				'$.BrokerKey',
		BrokerID			varchar(20)		'$.BrokerId',
		BrokerName			varchar(255)	'$.BrokerName',
		AddrKey				int				'$.AddrKey',
		StatusKey			smallint		'$.StatusKey',
		--StatusDate			datetime		'$.StatusDate',
		CompanyKey			smallint		'$.CompanyKey',
		IsActive			bit				'$.IsActive',
		IsDelete			bit				'$.IsDelete',
		MarketLocationKey   INT				'$.MarketLocationKey'
	)

	SELECT @BrokerKey = BrokerKey, @BrokerName = BrokerName FROM #Broker;

	declare @cnt int = 0
	select @cnt = COUNT(1) from #Broker
	if(ISNULL(@cnt,0) = 0)
	begin
		SET @Status = 0
		SET @Reason = 'Broker data not exists'
		return;
	end

	declare @AddressData nvarchar(max)
	select @AddressData = Address
	from OpenJson(@JSONString,'$')
	with (
		Address		nvarchar(max)	'$.Address' as JSON
	)

	Create table #Address
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
		Email2		varchar(50)
	)

	if(ISNULL(@AddressData,'') = '')
	begin
		SET @Status = 0
		SET @Reason = 'Broker address not exists'
		return;
	end

	insert into #Address(AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2)
	select AddrKey, AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2
	from OpenJson(@AddressData,'$')
	With(
		AddrKey		int				'$.AddrKey',
		AddrName	varchar(255)	'$.AddrName',
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
		Email2		varchar(50)		'$.Email2'
	)
	
	set @cnt=0
	select @cnt = COUNT(1) from #Address
	if(ISNULL(@cnt,0) = 0)
	begin
		SET @Status = 0
		SET @Reason = 'Broker address data not exists'
		return;
	end

	DECLARE @AddrKey	int = 0
	select @AddrKey = AddrKey from #Address

	BEGIN TRANSACTION
	BEGIN TRY
		if(ISNULL(@AddrKey,0) = 0)
		Begin
			INSERT INTO Address(AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2)
			select AddrName, Address1, Address2, City, State, ZipCode, Country, Website, Phone, Email, Fax, Phone2 ,Email2
			from #Address
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
				State		=B.State,
				ZipCode		=B.ZipCode,	
				Country		=B.Country,	
				Website		=B.Website,	
				Phone		=B.Phone,
				Email		=B.Email,
				Fax			=B.Fax,	
				Phone2		=B.Phone2,
				Email2		=B.Email2	
			FROM Address A
			INNER JOIN #Address B ON A.AddrKey = B.AddrKey
		END

		IF(EXISTS (SELECT 1 FROM dbo.Broker WHERE BrokerName = @BrokerName AND BrokerKey <> ISNULL(@BrokerKey,0)))
		BEGIN
			SET @Status = 0;
			SET @Reason = 'Broker Name Already Exist';
			ROLLBACK;
			RETURN;
		END

		IF(ISNULL(@BrokerKey,0) = 0)
		BEGIN
			INSERT INTO Broker(BrokerID, BrokerName, AddrKey, CreateDate, StatusKey, StatusDate, CompanyKey, IsActive, IsDelete, MarketLocationKey)
			SELECT BrokerID, BrokerName, AddrKey, GETDATE(), StatusKey, GETDATE(), CompanyKey, IsActive, IsDelete, MarketLocationKey
			FROM #Broker
			Set @BrokerKey = SCOPE_IDENTITY()
		END
		else
		BEGIN
			UPDATE C SET
				BrokerID			=	B.BrokerID,	
				BrokerName			=	B.BrokerName,	
				AddrKey				=	B.AddrKey,		
				StatusKey			=	B.StatusKey,	
				--StatusDate			=	B.StatusDate,	
				CompanyKey			=	B.CompanyKey,	
				IsActive			=	ISNULL(B.IsActive, C.IsActive),
				IsDelete			=	ISNULL(B.IsDelete, C.IsDelete),
				MarketLocationKey   =   B.MarketLocationKey
			FROM Broker C
			INNER JOIN #Broker B ON C.BrokerKey = B.BrokerKey
		END
		COMMIT TRANSACTION
		SET @Status = 1
		SET @Reason = 'Broker Saved Successfully'
	END TRY
	BEGIN CATCH
		SET @Status = 0
		SET @Reason = ERROR_MESSAGE()
		Rollback Transaction
	END CATCH
END