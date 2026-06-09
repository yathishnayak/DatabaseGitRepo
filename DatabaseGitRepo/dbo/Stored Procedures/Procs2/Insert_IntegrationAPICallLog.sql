CREATE PROCEDURE Insert_IntegrationAPICallLog
(
	@CustKey			INT,
	@AddressKey			INT,
	@RequestString		VARCHAR(MAX),
	@RepsonseString		VARCHAR(MAX),
	@ExceptionString	VARCHAR(MAX),
	@RequestSentAt		DATETIME,
	@ResponseReceivedAt	DATETIME,
	@ExceptionOccuredAt	DATETIME,
	@SiteID				VARCHAR(20),
	@IsAddrUpdate		BIT,
	@IsCustomer			BIT,
	@UserKey			INT
)
AS
BEGIN
	DECLARE @AddrKey INT=0
	SELECT @AddrKey=AddrKey FROM Consignee WHERE ConsigneeKey=@AddressKey
	IF @IsCustomer=0
	BEGIN
		SET @AddressKey=@AddrKey
	END
	INSERT INTO IntegrationApiCall_Log
			(CustKey, AddressKey, RequestString, RepsonseString, ExceptionString, RequestSentAt, ResponseReceivedAt, ExceptionOccuredAt, SiteID, IsAddrUpdate, IsCustomer, UserKey)			
	SELECT  @CustKey, @AddressKey, @RequestString,@RepsonseString, @ExceptionString, @RequestSentAt, @ResponseReceivedAt, @ExceptionOccuredAt, @SiteID, @IsAddrUpdate, @IsCustomer, @UserKey
END