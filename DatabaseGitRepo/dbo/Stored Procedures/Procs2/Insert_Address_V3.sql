/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"AddrName":"A","Address1":"B","Address2":"C","Zip":"12302","City":"Schenectady","State":"NY","Country":"USA","Website":"www","Phone":1,"Phone2":2,"Fax":12,"Email":"aaa","Email2":"qww","OrderTypeKey":1,"AddressType":"Bill To","CustKey":3057}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [Insert_Address_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/

CREATE PROCEDURE [dbo].[Insert_Address_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END

	DECLARE
	@AddrName	VARCHAR(255),
	@Address1	VARCHAR(255),
	@Address2	VARCHAR(255),
	@City		VARCHAR(50),
	@State		VARCHAR(50),
	@Zipcode	VARCHAR(50),
	@Country	CHAR(3),
	@Website	VARCHAR(100),
	@Phone		VARCHAR(20),
	@Email		VARCHAR(50),
	@Fax		VARCHAR(20),
	@Phone2		VARCHAR(20),
	@Email2		VARCHAR(255),
	@CustomerKey	INT,
	@OrderTypeKey	SMALLINT,
	@AddressType	VARCHAR(50),
	@AddrKey		INT 

	SELECT 
	@AddrName			=		AddrName		,	
	@Address1			=		Address1		,
	@Address2			=		Address2		,
	@City				=		City			,
	@State				=		State			,
	@Zipcode			=		Zipcode			,
	@Country			=		Country			,
	@Website			=		Website			,
	@Phone				=		Phone			,
	@Email				=		Email			,
	@Fax				=		Fax				,
	@Phone2				=		Phone2			,
	@Email2				=		Email2			,
	@CustomerKey		=		CustomerKey		,
	@OrderTypeKey		=		OrderTypeKey	,
	@AddressType		=		AddressType
	FROM OPENJSON(@JSONString)
	WITH
	(
	Addrname			VARCHAR(255)		'$.AddrName'		,
	Address1			VARCHAR(255)		'$.Address1'		,
	Address2			VARCHAR(255)		'$.Address2'		,
	City				VARCHAR(50)			'$.City'			,
	State				VARCHAR(50)			'$.State'			,
	Zipcode				VARCHAR(50)			'$.Zipcode'		,
	Country				CHAR(3)				'$.Country'		,
	Website				VARCHAR(100)		'$.Website'		,
	Phone				VARCHAR(20)			'$.Phone'			,
	Email				VARCHAR(50)			'$.Email'			,
	Fax					VARCHAR(20)			'$.Fax'			,
	Phone2				VARCHAR(20)			'$.Phone2'			,
	Email2				VARCHAR(255)		'$.Email2'			,
	CustomerKey			INT					'$.CustKey'	,
	OrderTypeKey		SMALLINT			'$.OrderTypeKey'	,
	AddressType			VARCHAR(50)			'$.AddressType'
	)

	DECLARE @PortKey INT
	DECLARE @CityKey INT

	SET @CityKey= ( SELECT top 1 CityKey FROM LocationData WHERE City=@City AND STate = @State AND ZipCode=@Zipcode)

	SET @AddrKey=0
	SET @PortKey=0
	--*******************************Import**************************
	IF @OrderTypeKey= 1 AND ( @AddressType='Pickup' OR @AddressType='Return' )
	BEGIN
		IF ( SELECT COUNT(1) 
			 FROM dbo.[Address] A WITH(NOLOCK) 
				INNER JOIN [ShippingPort] SP WITH(NOLOCK) ON SP.AddrKey=A.AddrKey
			 WHERE AddrName= @Addrname AND City=@City AND [State]=@State AND ZipCode=@Zipcode) >0
		BEGIN
			SET @AddrKey=-1
			RETURN
		END

		INSERT INTO dbo.[Address](AddrName,Address1, Address2, City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
		VALUES (@Addrname,@Address1, @Address2, @City,@State,@Zipcode,@Country,@Website,@Phone,@Email,@Fax,@Phone2,@Email2,@CityKey) ;

		SET @AddrKey = ( SELECT SCOPE_IDENTITY());

		INSERT INTO [dbo].[ShippingPort]
           (
			[ShippingPortID]
           ,[AddrKey]
           ,[StatusKey]         
		   )
		   VALUES( @Addrname,@AddrKey,1)

		SET @PortKey = ( SELECT SCOPE_IDENTITY());
		   
		INSERT INTO [dbo].[ShippingPortTerminals]
           ([TerminaID]
           ,[PortKey]
           ,[AddrKey]
           ,[StatusKey])
		VALUES (@Addrname,@PortKey,@AddrKey,1)
		RETURN
	END

	IF @OrderTypeKey= 1 AND @AddressType='Delivery'
	BEGIN
		IF ( SELECT COUNT(1) 
			 FROM dbo.[Address] A WITH(NOLOCK) 
				INNER JOIN CustomerAddress CA WITH(NOLOCK) ON CA.AddrKey=A.AddrKey
			 WHERE AddrName= @Addrname AND City=@City AND [State]=@State AND ZipCode=@Zipcode) >0
		BEGIN
			SET @AddrKey=-1
			RETURN
		END

		INSERT INTO dbo.[Address](AddrName,Address1, Address2, City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
		VALUES (@Addrname,@Address1, @Address2, @City,@State,@Zipcode,@Country,@Website,@Phone,@Email,@Fax,@Phone2,@Email2,@CityKey) ;

		SET @AddrKey = ( SELECT SCOPE_IDENTITY());

		INSERT INTO dbo.CustomerAddress(CustKey,AddrKey,AddrType)
		VALUES( @CustomerKey,@AddrKey,@AddressType)
		RETURN
	END
	--*********************Export**********************************
	IF @OrderTypeKey= 2 AND (@AddressType='Pickup' OR @AddressType='Return')
	BEGIN
		IF ( SELECT COUNT(1) 
			 FROM dbo.[Address] A WITH(NOLOCK) 
				INNER JOIN CustomerAddress CA WITH(NOLOCK) ON CA.AddrKey=A.AddrKey
			 WHERE AddrName= @Addrname AND City=@City AND [State]=@State AND ZipCode=@Zipcode) >0
		BEGIN
			SET @AddrKey=-1
			RETURN
		END

		INSERT INTO dbo.[Address](AddrName,Address1, Address2, City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
		VALUES (@Addrname,@Address1, @Address2, @City,@State,@Zipcode,@Country,@Website,@Phone,@Email,@Fax,@Phone2,@Email2,@CityKey) ;

		SET @AddrKey = ( SELECT SCOPE_IDENTITY());

		INSERT INTO dbo.CustomerAddress(CustKey,AddrKey,AddrType)
		VALUES( @CustomerKey,@AddrKey,@AddressType)
		RETURN
	END
	IF @OrderTypeKey= 2 AND @AddressType='Delivery'
	BEGIN
		IF ( SELECT COUNT(1) 
			 FROM dbo.[Address] A WITH(NOLOCK) 
				INNER JOIN [ShippingPort] SP WITH(NOLOCK) ON SP.AddrKey=A.AddrKey
			 WHERE AddrName= @Addrname AND City=@City AND [State]=@State AND ZipCode=@Zipcode) >0
		BEGIN
			SET @AddrKey=-1
			RETURN
		END

		INSERT INTO dbo.[Address](AddrName,Address1, Address2, City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
		VALUES (@Addrname,@Address1, @Address2, @City,@State,@Zipcode,@Country,@Website,@Phone,@Email,@Fax,@Phone2,@Email2,@CityKey) ;

		SET @AddrKey = ( SELECT SCOPE_IDENTITY());

		INSERT INTO [dbo].[ShippingPort]
           (
			[ShippingPortID]
           ,[AddrKey]
           ,[StatusKey]
           ,[CompanyKey]
		   )
		   VALUES( @Addrname,@AddrKey,1,NULL)

		SET @PortKey = ( SELECT SCOPE_IDENTITY());
		   
		INSERT INTO [dbo].[ShippingPortTerminals]
           ([TerminaID]
           ,[PortKey]
           ,[AddrKey]
           ,[StatusKey])
		VALUES (@Addrname,@PortKey,@AddrKey,1)
		RETURN
	END
	--****************************OneWay*********************************		
	IF @OrderTypeKey= 3
	BEGIN
		IF ( SELECT COUNT(1) 
			 FROM dbo.[Address] A WITH(NOLOCK)
				INNER JOIN dbo.CustomerAddress CA WITH(NOLOCK) ON CA.AddrKey=A.AddrKey
			 WHERE AddrName= @Addrname AND City=@City AND [State]=@State AND ZipCode=@Zipcode) >0
		BEGIN
			SET @AddrKey=-1
			RETURN
		END

		INSERT INTO dbo.[Address](AddrName,Address1, Address2, City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
		VALUES (@Addrname,@Address1, @Address2, @City,@State,@Zipcode,@Country,@Website,@Phone,@Email,@Fax,@Phone2,@Email2,@CityKey) ;

		SET @AddrKey = ( SELECT SCOPE_IDENTITY());

		INSERT INTO dbo.CustomerAddress(CustKey,AddrKey,AddrType)
		VALUES( @CustomerKey,@AddrKey,@AddressType)
	END

	IF @AddressType = 'Bill To'
	BEGIN
		IF ( SELECT COUNT(1) 
			 FROM dbo.[Address] A WITH(NOLOCK)
				INNER JOIN dbo.CustomerAddress CA WITH(NOLOCK) ON CA.AddrKey=A.AddrKey
			 WHERE AddrName= @Addrname AND City=@City AND [State]=@State AND ZipCode=@Zipcode) >0
		BEGIN
			SET @AddrKey=-1
			RETURN
		END

		INSERT INTO dbo.[Address](AddrName,Address1, Address2, City,[State],ZipCode,Country,Website,Phone,Email,Fax,Phone2,Email2,CityKey)
		VALUES (@Addrname,@Address1, @Address2, @City,@State,@Zipcode,@Country,@Website,@Phone,@Email,@Fax,@Phone2,@Email2,@CityKey) ;

		SET @AddrKey = ( SELECT SCOPE_IDENTITY());

		INSERT INTO dbo.CustomerAddress(CustKey,AddrKey,AddrType)
		VALUES(@CustomerKey,@AddrKey,@AddressType)

	END
	SELECT @AddrKey AS AddrKey FOR JSON PATH, WITHOUT_ARRAY_WRAPPER

	SET @Status = 1
	SET @Reason = 'Success'
END