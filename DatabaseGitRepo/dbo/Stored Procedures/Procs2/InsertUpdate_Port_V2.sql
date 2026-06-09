/*
DECLARE @UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 0,
	@Status			BIT	= 0 ,
	@Reason			NVARCHAR(1000) = '' 
SET @JsonString='{"ShippingPortKey":1705,"ShippingPortID":" AMAZON REDLANDS","MarketLocationKey":"2","StatusKey":1,"IsActive":false,"IsDeleted":false,"AddrKey":33737,"MarketLocation":null,"Address":{"Address1":"  2125 W SAN BERNARDINO","Address2":" ","City":"Redlands","State":"CA","Zip":"92374","Phone":" ","Phone2":" ","Fax":" ","Email":" ","Email2":" ","Country":"USA","Website":" ","AddrKey":33737,"AddrName":" AMAZON REDLANDS"},"PriceGroupingKey":6,"CompanyKey":1}'
exec [InsertUpdate_Port_V2] @UserKey,@JsonString,@IsDebug,@Status output,@Reason output
select @Status,@Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdate_Port_V2]
(
	@UserKey		INT=512,
	@JsonString		VARCHAR(MAX)='',
	@IsDebug		BIT = 1,
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;
	SET ARITHABORT ON;

	IF(ISNULL(@JsonString,'')='')
	BEGIN
		SET @Status=0;
		SET @Reason='Parameter not found';
		RETURN;
	END
	
	DECLARE @ShippingPortKey		INT,-- OUTPUT,
			@ShippingPortID			VARCHAR(50),
			@AddrKey				INT,--output
			@StatusKey				SMALLINT,
			@CompanyKey				SMALLINT,
			@IsActive				BIT,
			@MarketLocationKey		INT,
			@PriceGroupingKey		INT,
			@AddressData			NVARCHAR(MAX)='',

			@AddrName				VARCHAR(255),
			@Address1				VARCHAR(255),
			@Address2				VARCHAR(255),
			@City					VARCHAR(255),
			@State					VARCHAR(255),
			@ZipCode				VARCHAR(50),
			@Country				CHAR(3),
			@WebSite				VARCHAR(255),
			@Phone					VARCHAR(255),
			@Email					VARCHAR(255),
			@Fax					VARCHAR(20),
			@Phone2					VARCHAR(20),
			@Email2					VARCHAR(255),
			@OutPut					BIT-- OUTPUT

			--SElect @JsonString
	SELECT @ShippingPortKey=ShippingPortKey,@ShippingPortID=ShippingPortID,@AddrKey=AddrKey,@StatusKey=StatusKey,
		   @CompanyKey=CompanyKey,@IsActive=IsActive,@MarketLocationKey=MarketLocationKey,
		   @PriceGroupingKey=PriceGroupingKey,@AddressData=AddressData
	FROM OPENJSON(@JsonString, '$')
	WITH(	
			ShippingPortKey			INT				'$.ShippingPortKey',
			ShippingPortID			VARCHAR(50)		'$.ShippingPortID',
			AddrKey					INT				'$.AddrKey',
			StatusKey				SMALLINT		'$.StatusKey',
			CompanyKey				SMALLINT		'$.CompanyKey',
			IsActive				BIT				'$.IsActive',
			MarketLocationKey		INT				'$.MarketLocationKey',
			PriceGroupingKey		INT				'$.PriceGroupingKey',
			--PriceGroupingKey		INT				'$.PriceGroupingKey',
			AddressData				NVARCHAR(MAX)	'$.Address'  AS JSON
		)
		--select @PriceGroupingKey
		--select @AddressData
	SELECT @AddrName=AddrName,@Address1=Address1,@Address2=Address2,@City=City,@State=[State],@ZipCode=ZipCode,
		   @Country=Country,@WebSite=WebSite,@Phone=Phone,@Email=Email,@Fax=Fax,@Phone2=Phone2,@Email2=Email2
	FROM OPENJSON(@AddressData, '$')
	WITH(	
			AddrName		VARCHAR(255)	'$.AddrName',
			Address1		VARCHAR(255)	'$.Address1',
			Address2		VARCHAR(255)	'$.Address2',
			City			VARCHAR(255)	'$.City',
			[State]			VARCHAR(255)	'$.State',
			ZipCode			VARCHAR(50)		'$.Zip',
			Country			CHAR(3)			'$.Country',
			WebSite			NVARCHAR(MAX)	'$.Website',
			Phone			VARCHAR(255)	'$.Phone',
			Email			VARCHAR(255)	'$.Email',
			Fax				VARCHAR(20)		'$.Fax',
			Phone2			VARCHAR(20)		'$.Phone2',
			Email2			VARCHAR(255)	'$.Email2'
		)

	BEGIN TRANSACTION
	BEGIN TRY
		IF(@AddrKey>0)
		BEGIN
			EXEC Update_Address @AddrKey,@AddrName,@Address1,@Address2,@City,@State,@ZipCode,@Country,@WebSite,@Phone,@Email,@Fax,@Phone2,@Email2,@OutPut OUTPUT
		END
		ELSE
		BEGIN
			EXEC Create_Address @AddrName,@Address1,@Address2,@City,@State,@ZipCode,@Country,@WebSite,@Phone,@Email,@Fax,@Phone2,@Email2,@AddrKey OUTPUT
		END
		EXEC InsertUpdate_Port @ShippingPortKey,@ShippingPortID,@AddrKey,@StatusKey,@CompanyKey,@IsActive,@MarketLocationKey,@UserKey,@PriceGroupingKey,
		@Status OUTPUT,@Reason OUTPUT
		SET @Reason='Success';
		SET @Status=1;
		COMMIT TRAN;
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN;
		print Error_message();
		SET @Reason='Failure';
		SET @Status=0;
	END CATCH

	



END
