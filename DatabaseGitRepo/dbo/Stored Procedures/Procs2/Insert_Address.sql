

CREATE PROCEDURE [dbo].[Insert_Address]
@Addrname	VARCHAR(255),
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
@AddrKey		INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	DECLARE @PortKey INT
	DECLARE @CityKey INT

	SET @CityKey= ( SELECT top 1 CityKey FROM LocationData WHERE City=@City AND STate = @State AND ZipCode=@Zipcode)

	SET @AddrKey=0
	SET @PortKey=0
	--*******************************Import**************************
	IF @OrderTypeKey= 1 AND ( @AddressType='Pickup' OR @AddressType='Return' )
	BEGIN
		IF ( SELECT COUNT(1) 
			 FROM dbo.[Address] A 
				INNER JOIN [ShippingPort] SP ON SP.AddrKey=A.AddrKey
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
			 FROM dbo.[Address] A 
				INNER JOIN CustomerAddress CA ON CA.AddrKey=A.AddrKey
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
			 FROM dbo.[Address] A 
				INNER JOIN CustomerAddress CA ON CA.AddrKey=A.AddrKey
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
			 FROM dbo.[Address] A 
				INNER JOIN [ShippingPort] SP ON SP.AddrKey=A.AddrKey
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
			 FROM dbo.[Address] A
				INNER JOIN dbo.CustomerAddress CA ON CA.AddrKey=A.AddrKey
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
			 FROM dbo.[Address] A
				INNER JOIN dbo.CustomerAddress CA ON CA.AddrKey=A.AddrKey
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
END
