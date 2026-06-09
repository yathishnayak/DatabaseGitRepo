CREATE PRocEDURE [dbo].[Get_DriverIDBy_PhoneNo]
(
	@UserKey		int,
	@JSONString		nvarchar(max),
	@Status			bit	= 0 output,
	@Reason			varchar(1000) = '' output,
	@IntError		VARCHAR(MAX) = '' OUTPUT,
	@FirebaseID		VARCHAR(100) = '',
	@IsLogout		BIT = 0 OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON
	SET FMTONLY OFF
	SET @IsLogout = 0
	IF(ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET @Status = 0
		SET @Reason = 'Parameters not found'
		SET	@IntError =   'User Not Found'
		SET @IsLogout = 0
		RETURN
	END

	CREATE TABLE #PhoneNoTemp
	(
		PhoneNo			VARCHAR(100)
	)

	INSERT INTO #PhoneNoTemp(PhoneNo)
	SELECT PhoneNo
	FROM OPENJSON(@JsonString, '$')
	WITH (
			PhoneNo			VARCHAR(100)			'$.PhoneNo'
		)

	SET @Status=1
	SET @Reason='Success'
	SET	@IntError =   'User Found'
	SELECT TOP 1 DriverID, DriverKey, FirstName, LastName 
	FROM Driver D
	INNER JOIN #PhoneNoTemp PT WITH (NOLOCK) ON D.CellNumber=PT.PhoneNo
	WHERE ISNULL(IsActive,1) = 1 AND StatusKey = 1
	FOR JSON PATH
END
