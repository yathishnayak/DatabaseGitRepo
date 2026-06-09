/*
DECLARE 
	@UserKey INT = 1144,
	@JSONString NVARCHAR(MAX)= '{"DriverContactKey" : 16, "DriverKey" : 1838, "ContactName" : "Driver", "ContactNumber" : 1223, "ContactDesignation" : "designation", "ContactEmail" : "ph@gmail.com"}',
	@Status	BIT = 0, 
	@IsDebug BIT = 0, 
	@Reason	VARCHAR(100)=''
	EXEC [InsertUpdateDriverContact_V3] @UserKey,@JSONString,@Status OUTPUT,@Reason OUTPUT, @IsDebug
	SELECT @Status AS Status, @Reason AS Reason
*/
CREATE PROCEDURE [dbo].[InsertUpdateDriverContact_V3] -- [InsertUpdateDriverContact] @DriverKey = 1838, @ContactName = 'drivercontact1', @ContactNumber = 1223, @ContactDesig = 'designation' , @ContactEmail = 'ph@gmail.com'
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

	IF (ISNULL(LTRIM(RTRIM(@JSONString)) ,'') = '')
	BEGIN
		SET		@Status = 0
		SET		@Reason = 'Parameters not found'
		RETURN
	END	

	DECLARE
		@DriverContactKey	int = 0,
		@DriverKey			int = 0,
		@ContactName		varchar(100) = '',
		@ContactNumber		varchar(100) = '',
		@ContactDesig		varchar(100) = '',
		@ContactEmail		varchar(100) = ''

	SELECT 
		@DriverContactKey	=	DriverContactKey	,
		@DriverKey			=	DriverKey			,
		@ContactName		=	ContactName		,
		@ContactNumber		=	ContactNumber		,
		@ContactDesig		=	ContactDesig		,
		@ContactEmail		=	ContactEmail		
	FROM OPENJSON(@JSONString)
	WITH
	(
		DriverContactKey		INT					'$.DriverContactKey'	,
		DriverKey				INT					'$.DriverKey'			,
		ContactName				VARCHAR(100)		'$.ContactName'			,
		ContactNumber			VARCHAR(100)		'$.ContactNumber'		,
		ContactDesig			VARCHAR(100)		'$.ContactDesignation',
		ContactEmail			VARCHAR(100)		'$.ContactEmail'		
	)


	DECLARE @CNT int = 0
	SELECT @CNT = COUNT(1) 
	FROM DriverContacts WITH (NOLOCK) 
	WHERE DriverContactKey = @DriverContactKey
	BEGIN TRY
		IF(ISNULL(@CNT,0) = 0)
		BEGIN
			INSERT INTO DriverContacts(DriverKey, ContactName, ContactDesignation, ContactNumber, ContactEmail )
			SELECT @DriverKey, @ContactName, @ContactDesig, @ContactNumber, @ContactEmail
			SET @DriverContactKey = SCOPE_IDENTITY()
			SET @Status = 1
			SET @Reason = 'Contact Inserted Successfully'
		END
		ELSE
		BEGIN
			UPDATE DriverContacts set
				ContactName = @ContactName,
				ContactEmail = @ContactEmail,
				ContactDesignation = @ContactDesig,
				@ContactNumber = @ContactNumber
			WHERE DriverContactKey = @DriverContactKey
			SET @Status = 1
			SET @Reason = 'Contact Updated Successfully'
		END
			SELECT @DriverContactKey AS [Key] FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
	END TRY

	BEGIN CATCH
		SET @Reason = 'Technical Error'
		SET @Status = 0
	END CATCH
END