/** 
Declare 
	@UserKey		INT = 951,
	@Status			BIT	= 0,
	@Reason			NVARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING NVARCHAR(MAX)= '{
			"CustKey":1648,
			"AddressKey":46405,
			"RequestString":"{\"external_id\":\"46405\",\"name\":\"AGF01\",\"location_name\":\"66\",\"address\":{\"address_line_1\":\"22\",\"address_line_2\":\"-\",\"city\":\"Schenectady\",\"state\":\"NY\",\"country\":\"USA\",\"postal_code\":\"12301\"}}",
			"ResponseString":"{\"error\":\"Duplicate consignee\",\"message\":\"A consignee with this external ID already exists for your organization\"}",
			"ExceptionString":"",
			"RequestSentAt":"2026-02-26T11:13:30.7922469+05:30",
			"ResponseReceivedAt":"2026-02-26T11:13:31.2030562+05:30",
			"ExceptionOccuredAt":null,
			"SiteID":"Melrose",
			"IsAddrUpdate":false,
			"IsCustomer":false
	}'
	EXEC [Insert_IntegrationAPICallLog_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Insert_IntegrationAPICallLog_V2]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			NVARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
AS
BEGIN
	SET NOCOUNT ON
	SET FMTONLY OFF

	IF ISNULL(@JSONString, '') = ''
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'Parameters not found'
			RETURN
		END	
		
	IF (@IsDebug = 1)
		BEGIN
			SET		@Status = 0
			SET		@Reason = 'In Debug Mode'
		END	

	DECLARE 
		@CustKey			INT,
		@AddressKey			INT,
		@RequestString		NVARCHAR(MAX),
		@RepsonseString		NVARCHAR(MAX),
		@ExceptionString	NVARCHAR(MAX),
		@RequestSentAt		DATETIMEOFFSET(7),
		@ResponseReceivedAt	DATETIMEOFFSET(7),
		@ExceptionOccuredAt	DATETIMEOFFSET(7),
		@SiteID				NVARCHAR(20),
		@IsAddrUpdate		BIT,
		@IsCustomer			BIT
		-- @UserKey			INT
	SELECT 									   
		@CustKey			= 	CustKey		   ,
		@AddressKey			= 	AddressKey		   ,
		@RequestString		= 	RequestString	   ,
		@RepsonseString		= 	RepsonseString	   ,
		@ExceptionString	= 	ExceptionString   ,
		@RequestSentAt		= 	RequestSentAt	   ,
		@ResponseReceivedAt	= 	ResponseReceivedAt,
		@ExceptionOccuredAt	= 	ExceptionOccuredAt,
		@SiteID				= 	SiteID			   ,
		@IsAddrUpdate		= 	IsAddrUpdate	   ,
		@IsCustomer			= 	IsCustomer		   
		-- @UserKey			= 	UserKey		   
	FROM OPENJSON(@JSONString)
	WITH
	(														 
		CustKey				INT						'$.CustKey'			,	
		AddressKey			INT						'$.AddrKey'		,
		RequestString		NVARCHAR(MAX)  			'$.RequestString'	,
		RepsonseString		NVARCHAR(MAX)			'$.ResponseString'	,
		ExceptionString		NVARCHAR(MAX)			'$.ExceptionString'	,
		RequestSentAt		DATETIMEOFFSET(7)		'$.RequestSentAt'	,
		ResponseReceivedAt	DATETIMEOFFSET(7)		'$.ResponseReceivedAt',	
		ExceptionOccuredAt	DATETIMEOFFSET(7)		'$.ExceptionOccuredAt',	
		SiteID				NVARCHAR(20)			'$.SiteID'			,	
		IsAddrUpdate		BIT						'$.IsAddrUpdate'	,	
		IsCustomer			BIT						'$.IsCustomer'		
		-- @UserKey			INT
	)

	DECLARE @AddrKey INT=0
	SELECT @AddrKey=AddrKey FROM Consignee WHERE ConsigneeKey=@AddressKey
	IF @IsCustomer=0
	BEGIN
		SET @AddressKey=@AddrKey
	END
	INSERT INTO IntegrationApiCall_Log
			(CustKey, AddressKey, RequestString, RepsonseString, ExceptionString, RequestSentAt, ResponseReceivedAt, ExceptionOccuredAt, SiteID, IsAddrUpdate, IsCustomer, UserKey)			
	SELECT  @CustKey, @AddressKey, @RequestString,@RepsonseString, @ExceptionString, @RequestSentAt, @ResponseReceivedAt, @ExceptionOccuredAt, @SiteID, @IsAddrUpdate, @IsCustomer, @UserKey


	SET @Status = 1
	SET @Reason = 'Success'
END