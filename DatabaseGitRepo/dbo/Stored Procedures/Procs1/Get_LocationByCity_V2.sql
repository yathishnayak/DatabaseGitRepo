/** 
Declare 
	@UserKey		INT = 1144,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"City":"Adams Basin"}'
	EXEC [Get_LocationByCity_Ruthu_20260220] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
	SELECT @Status, @Reason
**/
CREATE PROCEDURE [dbo].[Get_LocationByCity_V2]
(
	@UserKey		INT = 714,
	@JSONString		NVARCHAR(MAX) = '',
	@Status			BIT	= 0 OUTPUT,
	@Reason			VARCHAR(1000) = '' OUTPUT,
	@IsDebug		BIT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	SET FMTONLY OFF;

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

	DECLARE @City VARCHAR(20) = ''

	SELECT @City = City
	FROM OPENJSON(@JSONString)
	WITH(
	City	VARCHAR(20)		'$.City'
	)

	SELECT DISTINCT CityKey,Country,[State],City, ZipCode
	FROM dbo.LocationData A WITH (NOLOCK)
		INNER JOIN dbo.[Status] S WITH (NOLOCK) ON S.StatusKey=A.StatusKey
	WHERE S.StatusName='Active' AND A.City LIKE '%' +LTRIM(RTRIM(@City)) +'%'
	FOR JSON PATH;

	SET @Status = 1
	SET @Reason = 'Success'
END