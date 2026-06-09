/** 
Declare 
	@UserKey		INT,
	@Status			BIT	= 0,
	@Reason			VARCHAR(1000) = '',
	@IsDebug		BIT = 0,
	@JSONSTRING		NVARCHAR(Max) = '{"ZipCode":"9147"}'
EXEC [Get_LocationByZipCode_V2] @Userkey, @JSONSTRING, @Status OUTPUT, @Reason Output, @IsDebug
Select @Status, @Reason
**/

CREATE PROCEDURE [dbo].[Get_LocationByZipCode_V2]
(
	@UserKey		INT = 1144,
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

	DECLARE
	@ZipCode VARCHAR(20)

	SELECT 
		@ZipCode  = ZipCode

	FROM OPENJSON(@JSONString)
	WITH(
		ZipCode VARCHAR(20) '$.ZipCode'
	)

	SELECT DISTINCT
		CityKey,
		Country,
		[State],
		City,
		ZipCode
	FROM dbo.LocationData A WITH (NOLOCK)
	INNER JOIN dbo.[Status] S WITH (NOLOCK) ON S.StatusKey = A.StatusKey
	WHERE S.StatusName = 'Active'
	  AND A.ZipCode LIKE @ZipCode + '%'
	FOR JSON PATH;

	IF @@ROWCOUNT = 0
	BEGIN
		SET @Status = 0
		SET @Reason = 'No data found'
		RETURN
	END

	SET @Status = 1
	SET @Reason = 'Success'
END