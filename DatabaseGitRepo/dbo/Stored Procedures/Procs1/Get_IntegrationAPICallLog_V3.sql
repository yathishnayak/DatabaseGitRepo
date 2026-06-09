/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"CustKey":3241, "SiteID":"Melrose"}'
	EXEC [Get_IntegrationAPICallLog_V3] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status Status, @Reason Reason
**/
CREATE PROCEDURE [dbo].[Get_IntegrationAPICallLog_V3]
(
	@UserKey		INT = 1144,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0 
)
as
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

	Declare 
		@CustKey	INT=0,
		@SiteID		VARCHAR(20)=''

	SELECT 
		@CustKey	=	CustKey,
		@SiteID		=	SiteID
	FROM OPENJSON(@JSONString)
	WITH(
		CustKey		INT				'$.CustKey',
		SiteID		VARCHAR(20)		'$.SiteID'
	)


	SELECT IA.CustKey, C.CustID + ' - '+C.CustName As CustName, 
	(ISNULL(A.AddrName,'') +CHAR(10)+CHAR(13) +ISNULL(A.Address1,'') + CHAR(10)+CHAR(13)+ISNULL(A.Address2,'')
	+CHAR(10)+CHAR(13)+ISNULL(City,'')+CHAR(10)+CHAR(13)+ISNULL(ZipCode,'')+CHAR(10)+CHAR(13)+ISNULL([State],'')+CHAR(10)+CHAR(13)+ISNULL(Country,'') ) AS FullAddress,
		   AddressKey, RequestString, RepsonseString, ExceptionString, RequestSentAt,
		   ResponseReceivedAt, ExceptionOccuredAt, SiteID, IsAddrUpdate, IsCustomer, IA.UserKey,U.UserName
	FROM IntegrationApiCall_Log IA WITH (NOLOCK)
	LEFT JOIN Customer C WITH (NOLOCK) ON C.CustKey=IA.CustKey
	LEFT JOIN Address A WITH (NOLOCK) ON A.AddrKey=IA.AddressKey
	LEFT JOIN [User] U WITH (NOLOCK) ON IA.UserKey=U.UserKey
	WHERE (ISNULL(@CustKey,0)=0 OR IA.CustKey=@CustKey) 
		  AND (ISNULL(@SiteID,'')='' OR SiteID=@SiteID)
	ORDER BY RequestSentAt DESC
	FOR JSON PATH;

		SET @Status = 1
		SET @Reason = 'Success'
END